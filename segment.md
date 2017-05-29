# Case study: Segment

Segment is an analytics company. You put Segment's tracking code on your
website and they'll send the data to any other analytics tool you want (Google
Analytics, Mixpanel, Salesforce, etc.)

This entails proxying a lot of customer traffic and Segment has [a
correspondingly large AWS bill][bill]. Segment had two problems relating to this
large bill.

One, it was difficult to notice if one part of the engineering organization
suddenly started spending a lot more on AWS. Segment's AWS bill is six figures
per month. The charges for each AWS component making up the bill change as
customers churn, cost inefficiencies are found and fixed, and the engineering
organization deploys new tools. In this environment it can be difficult to
notice that, say, a single team spent $20,000 more on S3 this month than they
did last month.

Two, it's difficult for Segment to predict how much new customers will cost.
Customers are good at predicting how much traffic they will have, the Segment
products they want to use, and the mix of traffic they will send to different
services. Segment had trouble translating this usage information to a dollar
figure. Ideally they wanted to be able to say "1 million new API calls will
cost us $X so we should make sure we are charging at least $Y."

Segment hired [me][burke] to help them make sense of their AWS bill and help
them determine how much new customers would cost, so they could get out ahead
of their bill and avoid accidental undercharging instead of reacting to
increases in costs. The main goal was to figure out how much of the AWS bill was
attributable to Segment's different product areas, widely defined as:

- integrations (the code that writes from Segment to various analytics providers)
- API (customers browsers sending data to Segment)
- warehouses (writing data from Segment [to a customer's data warehouse][warehouses])
- the website and CDN
- internal (Support logic for the four above)

[warehouses]: https://segment.com/warehouses

### The AWS Billing CSV

There's a setting in the billing portal you can enable where Amazon will write
a CSV with detailed billing information to S3 every day. By detailed I mean
VERY detailed. Here is a typical billing row.

```
record_type       | LineItem
record_id         | 60280491644996957290021401
product_name      | Amazon DynamoDB
rate_id           | 0123456
subscription_id   | 0123456
pricing_plan_id   | 0123456
usage_type        | USW2-TimedStorage-ByteHrs
operation         | StandardStorage
availability_zone | us-west-2
reserved_instance | N
item_description  | $0.25 per GB-Month of storage used beyond first 25 free GB-Months
usage_start_date  | 2017-02-07 03:00:00
usage_end_date    | 2017-02-07 04:00:00
usage_quantity    | 6e-08
blended_rate      | 0.24952229400
blended_cost      | 0.00000001000
unblended_rate    | 0.25000000000
unblended_cost    | 0.00000001000
resource_id       | arn:aws:dynamodb:us-west-2:012345:table/a-table
statement_month   | 2017-02-01
```

That's a charge for a whopping $0.00000001, or one one-millionth of a penny, for
DynamoDB storage on a single table between 3AM and 4AM on February 7th. There
are about six million rows in Segment's billing CSV for a typical month.

Segment was already using [Heroku's `awsdetailedbilling` tool][awsbilling]
to copy the billing data from S3 to Redshift. This was a good first step but
lacking in one crucial way. Different parts of Segment's infrastructure used
the same AWS products, and Segment didn't have a great way to break out an AWS
product's costs into its own product area groups. For example, many different
teams use DynamoDB, Elasticache and S3, so it's hard to look at an increased
DynamoDB bill and ascribe it to a given team.

Crucially, about 60% of the bill is for EC2. Segment's engineering team makes
heavy use of [ECS (Elastic Container Service)][ecs] instances, running on hosts
in several different pools. A typical pool may have 20 EC2 c1.xlarge instances,
running 200 containers.

    (insert fancy diagram of ECS pools here)

Amazon bills *only* for the EC2 instance costs, so Segment had zero visibility
into the costs of its container services - how many containers they were running
at a typical time, how much of the pool they were using, and how many CPU and
memory units they were using.

[ecs]: https://aws.amazon.com/ecs/

### Cost Allocation Tags

The most obvious thing to start doing was to use AWS's [cost allocation
tags][cost-allocation-tags]. These let you apply a tag to a resource, like an
S3 bucket or a DynamoDB table. Toggle a setting in the AWS billing console and
after a day or so, your chosen tag (we chose `product_area`) will start showing
up as a new column next to the associated resources in the billing CSV.

There were two challenges: 1) tagging all of the existing infrastructure, and 2)
ensuring that any new resources would automatically have tags. Tagging all of
the infrastructure was pretty easy: For a given AWS product, ask Redshift for
the highest cost resources, then bug people in Slack until they tell you how
they should be tagged, and stop when you've tagged 90% or more of the resources
by cost.

Ensuring that new resources would be tagged as they were added was a little
trickier. Segment uses [Terraform][terraform] to manage AWS resources. In most
cases, Terraform's configuration supports adding the same cost allocation tags
that you can add via the AWS console. Here's an example Terraform configuration
for a S3 bucket:

```hcl
resource "aws_s3_bucket" "staging_table" {
  bucket = "segment-tasks-to-redshift-staging-tables-prod"

  tags {
    product_area = "data-analysis"
  }
}
```

So I wanted to verify that every time someone wrote `resource "aws_s3_bucket"`
into a Terraform file, they included a `product_area` tag. Fortunately Terraform
configurations are written in [HCL][hcl], which ships with [a comment preserving
configuration parser][more-comment-parsers]. So I wrote a checker that walks
every Terraform file looking for taggable resources lacking a `product_area`
tag.

```go
func checkItemHasTag(item *ast.ObjectItem, resources map[string]bool) error {
	// looking for "resource" "aws_s3_bucket" or similar
	if len(item.Keys) < 2 { return nil }
	resource, ok := hclchecker.StringKey(item.Keys[1].Token)
	if !ok { return nil }
	if resource != "aws_s3_bucket" { return nil }
	t, ok := item.Val.(*ast.ObjectType)
	if !ok {
		return fmt.Errorf("bad type: %#v", item.Val)
	}
	tags, ok := hclchecker.GetNodeForKey(t.List, "tags")
	if !ok {
		return fmt.Errorf("aws_s3_bucket resource has no tags", resource)
	}
	t2, ok := tags.(*ast.ObjectType)
	if !ok {
		return fmt.Errorf("expected 'tags' to be an ObjectType, got %#v", tags)
	}
	productNode, ok := hclchecker.GetNodeForKey(t2.List, "product_area")
	if !ok {
		return errors.New("Could not find a 'product_area' tag for S3 resource. Be sure to tag your resource with a product_area")
	}
}
```

I set up continuous integration for the repo with Terraform configs, and then
added these checks, so the tests will fail if anyone tries to check in a
taggable resource that's not tagged with a product area. This isn't perfect
since people can still create resources in the AWS console, but it's good enough
for now.

#### Rolling up cost allocation tag data

Once you've tagged resources, accounting for them is pretty simple.

1. Find the `product_area` tags for each resource, so you have a map of resource
   id => product area tags.
2. Sum the unblended costs for each resource.
3. Sum those costs by product area, and write the result to a rollup table.

We were able to account for about 35% of the bill using traditional cost
allocation tags.

### No Cost Allocation Tags

Other AWS resources, notably ECS, _don't_ support cost allocation tags. These
involved a much more Rube Goldberg-ian workflow to get the data into Redshift.
The core of it is:

1. Set up a [Cloudwatch subscription][subscription] any time an ECS task gets
started or stopped.

2. Push the relevant data (Service name, CPU/memory usage, starting or stopping,
EC2 instance ID) from the event to Kinesis Firehose (to aggregate individual
events).

3. Push the data from Kinesis Firehose to Redshift.

[subscription]: http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Subscriptions.html

Then we multiply the amount of time a given ECS task ran (say, 120 seconds)
by the number of CPU units it used on that machine (up to 4096 - this info is
available in the [task definition][definition]), to get a number of CPU-seconds
for each service that ran on the instance. The total bill for the instance is
then divided across services according to the number of CPU-seconds each one
used.

That's not a perfect method. EC2 instances aren't running at 100% capacity all
the time, and the excess currently gets divided across the services running on
the instance, which may or may not be the right culprits for that overhead. But
(and you may recognize this as a common theme in this post), it's good enough.

[definition]: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html

#### Product areas per service

We want to figure out the right product area for each ECS service, but we can't
tag those services in AWS because ECS doesn't support cost allocation tags.

Instead we added a `product_area` key to the Terraform module for each ECS
service. These don't lead to any metadata being sent to AWS, since we can't. But
I wrote a script that reads the `product_area` keys for each service, and then
publishes the service name => product area mappings to DynamoDB on every new
push to the master branch. Tests validate that each service has been tagged
with a product area.

It's not perfect, and it's not great that it's not hooked in to the existing
Terraform or AWS infrastructure in any way - the parser has required a lot of
massaging to avoid false positives as people add new module definitions. But
it's good enough for now.

#### EBS

Elastic Block Storage (EBS) makes up a significant part of the bill. EBS volumes
are typically attached to an EC2 instance, and for accounting purposes it makes
sense to consider the instance and the volume as a single cost. But the AWS
billing CSV doesn't show you which EBS volume was attached to which instance,
and we can't tag the majority of EBS volumes with a single product area, since
they're supporting the many different ECS services running on an EC2 instance.

We again used Cloudwatch for this - we subscribe to any "volume attached"
or "volume unattached" events, and then record the EBS => EC2 mappings in a
DynamoDB table. We can then add EBS volume costs to the relevant EC2 instances
before accounting for ECS costs.

#### Cross account writes

Segment uses a separate AWS account for staging, and staging costs are a
significant percentage of the overall AWS bill. We need to write the data
about ECS services in the stage realm to the production Redshift cluster.
This requires allowing the Cloudwatch subscription handlers to assume a role
in production that can write to Firehose (for ECS) or to DynamoDB (for EBS).
These are tricky to set up because you have to add the correct permissions to
the right role in the staging account (`sts.AssumeRole`) and in the production
account, and any mistake will lead to a confusing permission error.

This also means that you don't have a staging realm for your accounting code,
since the accounting code in stage is writing to the production database.
You can add a second service in stage that subscribes to the same data but
doesn't write it, add extra tests, or decide that you can swallow the occasional
problems with the stage accounting code.

## Rolling up the statistics

Finally we have all of the pieces we need: tagged resources in the AWS billing
CSV, data about when every ECS event started and stopped, a mapping between ECS
service names and the relevant product areas, and EBS mapping data.

To roll all of this up, I broke out the analysis by AWS product. For each AWS
product, I totaled the Segment product areas, and their costs, for that AWS
product. I recommend breaking out the analysis by AWS product area because each
required a fair amount of massaging - in some cases, an automated tagging rule
that needed to be applied to a subset of resources that were not managed via
Terraform, or in other cases (like the AWS support bill), manually tagging the
entire AWS product with a single product area. EC2 was the most complex because
we also needed to aggregate the EBS and the ECS data.

The data gets rolled up into three different tables:

- Total costs for a given ECS service in a given month
- Total costs for a given product area in a given month
- Total costs for a (AWS product, Segment product area) in a given month. For
example, "The warehouses product area used $1000 worth of DynamoDB last month."

For each of these tables, we have a `finalized` table that contains the
finalized numbers for each month, and a `rollup` append-only table that writes
new data for a month as it updates every day. A unique identifier in the
`rollup` table identifies a given run, so you can sum the AWS bill by finding
all of the rows in a given run.

### Errata

- Scripts that aggregate data, or copy it from one place to another, are often
infrequently touched and under monitored. For example, Segment had a script that
copied the Amazon billing CSV from one S3 bucket to another, but it failed on
the 28th of each month because the Lambda handler doing the copying ran out of
memory as the CSV got large. It took a while to notice this because the Redshift
database had a lot of data and the right-ish numbers for each month.

    Be sure these scripts are well documented, especially with information about
    how they are deployed and what configuration they need. Link to the source
    code in other places where they are referenced - for example, any place you
    pull data out of an S3 bucket, link to the script that puts the data in the
    bucket. Also consider putting a README in the S3 bucket root.

- Redshift queries can be really slow without optimization. Consult with the
Redshift specialist at your company, and think about the queries you need,
before creating new tables in Redshift. In my case we were missing the right
sortkey on the billing CSV tables. _You cannot add sortkeys after you create the
table_, so if you don't do it up front you have to create a second table with
the right keys, send writes to that one and then copy all the data over.

    Using the right sortkeys took the query portion of the rollup run from about
    7 minutes to 10-30 seconds.

- Initially I planned to run the rollup scripts on a schedule - Cloudwatch would
trigger an AWS Lambda function a few times a day. However the run length was
variable (especially when it involved writing data to Redshift) and exceeded
the maximum Lambda timeout, so I moved it to an ECS service instead.

- Any time you start writing new data to Redshift, the data in Redshift changes
  (say, new columns are added), or you fix integrity errors in the way the data
  is analyzed, add a note in the README with the date and information about what
  changed. This will be extremely helpful to your data analytics team.

- The blended costs are not useful for this type of analysis - stick to the
unblended costs which show what AWS actually charged you for a given resource.

- There are 8 or 9 rows in the billing CSV that don't have an Amazon product
name attached. These represent the total invoice amount, but throw off any
attempt to sum the unblended costs for a given month. Be sure to exclude these
before trying to sum costs.

- Your company may have paid AWS up front to reserve a certain amount of
  capacity. In Segment's case this means several large charges that show up in
  the December billing CSV need to be amortized across each month in the year;
  the start date for these charges is December 2016 and the end date is December
  2017. To find all costs, for, say, March, you need to write a query for all
  charges where the start date is before midnight on April 1, and the end date
  is on or after midnight on March 1. Then you need to find the percentage of
  the unblended cost that was incurred in the time period you care about. Check
  with your accounting/analysis team as they may want you to divide a yearly
  charge by 12, instead of multiplying by 31/365, to get the percentage that
  should apply for a given month.

    Subscription costs take the form "$X0000 of DynamoDB," so they are
    impossible to attribute to a single resource or product area. Instead we sum
    the per-resource costs by product area and then amortize the subscription
    costs according to the percentages. This isn't perfect. If a large
    percentage of your bill is reserved up front, this amortization strategy
    will be distorted by small changes in the on-demand costs. In that case
    you'll want to amortize based on the usage for each resource, which is more
    difficult to sum than the costs.

- AWS does not "finalize" your bill until several days after the end of the
month. You can detect when the bill becomes "final" because the `invoice_id`
field in the billing CSV will be an integer instead of the word "Estimated".

- I chose Javascript for the rollup code initially because it runs on Lambda and
most of the other scripts at the company were in Javascript. If I had realized
I was going to need to switch it to ECS, I would have chosen a language with
better support for 64 bit integer addition, and parallelization and cancellation
of work.

- It will be difficult to measure the entire bill. Target a percentage of the
costs in the bill, say, 80%, and try to get that measurement working end-to-end.
It's better to deliver business value analyzing 80% of the bill than to shoot
for 100%, get bogged down in the collection step, and never deliver any results.
Again, saying "this is good enough for now" and documenting improvements is
going to be your friend.

### Conclusion

This was a lot of hard work but at the end Segment has a lot better visibility
into the components of their AWS bill, and the costs of bringing on new
customers. They'll be able to see if a single service or a single product area
is suddenly costing a lot more, before that causes too much of a hit to their
bottom line.

Hopefully this case study will be useful for helping you get a better sense of
your costs!

[bill]: https://segment.com/blog/the-million-dollar-eng-problem/
[burke]: https://burke.services
[awsbilling]: https://github.com/heroku/awsdetailedbilling
[cost-allocation-tags]: http://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html
[terraform]: https://www.terraform.io/
[more-comment-parsers]: https://kev.inburke.com/kevin/more-comment-preserving-configuration-parsers/
[hcl]: https://github.com/hashicorp/hcl
