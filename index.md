# Kevin Burke - Consulting

<br/>
<p>
<img width=200 height=250 src="https://burke.services/profile-small.jpg" alt="Profile photo">
</p>

[Email Me](mailto:kevin@burke.services)

I'm available for hire as a consultant. Here are some of the things I can do
for your company:

- **Solve complex problems in production.** I helped Segment analyze their
6-million line AWS bill and allocate each line item to the team that incurred
it. [Read more about this here][segment].

[segment]: /segment.html

- **Teach your team about consistency.** At <a href="https://shyp.com">Shyp</a>
the biggest oncall problem we had was in driver assignment; two drivers
would get assigned the same pickup, or a pickup would get "assigned" but
have no driver, and a driver would get stuck. I wrote a state machine and a
[transaction library](https://github.com/Shyp/pg-transactions) to fix these. I
can teach your team [the same techniques to write faster, more correct database
queries](https://kev.inburke.com/kevin/faster-correct-database-queries/).

- **Productionize your culture.** You shipped a bad error last week; how can you
minimize the likelihood of shipping another one next week? Does the oncall
rotation feel like an overwhelming burden for your team? The answer goes deeper
than "focus more when writing the code", into a lot of human factors areas.
I implemented a lot of tools and procedures at Shyp that helped the team
learn from its mistakes, ship reliable code, and brought the number of pager
incidents to an extremely low value. I'll work with your team to figure out
where the problem areas are, and recommend/implement solutions.

- **Rewrite it in Go.** Do you have a server that no one understands, that needs
better throughput, or fails in unpredictable ways? Is your team interested
in kicking the tires with Go for a new project? I'm a contributor to the Go
programming language, I've written (and rewritten) several services in Go for
several companies, and can do the same for you. This will include a testing and
deployment strategy, a method for loading configuration from the environment,
and for starting and testing a local server.

- **Find problems in the build.** Intermittent build failures train your team
that build failures are okay, and then you might miss a more important error
that comes through. Or, an intermittent build failure might represent a real
problem. I can teach your team how to isolate and force an intermittent problem
to repeat on demand, then figure out how to fix it.

- **Speed up the build.** When I started at Shyp it took up to 100 seconds
to boot up the database for a single test. That's [down to about 3-5
seconds][speed-tests]. I can apply the same techniques to your team's build,
production codebase, or framework. I can also teach your team how to write
faster tests.

- **Write**. I can help kickstart your company's engineering blog, or work with
your team on story/content ideas. In the past I've had lots of success
attracting [a wide audience][hn] to [stories I've written][reddit].

[hn]: https://hn.algolia.com/?query=inburke.com&sort=byPopularity&prefix=false&page=0&dateRange=all&type=story
[reddit]: https://www.reddit.com/r/programming/search?q=url%3Akev.inburke.com&sort=top&restrict_sr=on&t=all

- **Find errors in production.** I have lots of experience debugging and fixing
issues, often on the fly, while oncall. Here is an example from Shyp's eBay
integration - our integration server was throwing errors on maybe 1 out of
every 500 eBay requests, and it was very difficult to reproduce. I [nailed down
the issue and submitted a fix, in a matter of hours][fix].

[fix]: https://github.com/Shyp/nodejs-ebay-api/commit/bd7e3835ee453404a7e05084dd7abf0b17762198

- **Find performance problems in production.** Let's figure out
why that page loads so slowly. Here's a sample of what I can
do - I found [a 10-20% speedup in Go's JSON encoding library
recently](https://go-review.googlesource.com/#/c/24466/).

- **Run design/content strategy reviews for your documentation.** I maintained
the documentation for the Twilio API from 2011 to 2014. I ran user tests to
figure out where people got stuck when figuring out how to use Twilio. We used
a lot of the lessons from that to design great documentation. I talk more about
this in ["How to Write Documentation for Users that Don't Read"][write-docs] at
Write the Docs 2015.

- **Run design/strategy/correctness reviews for client libraries**. I maintained
Twilio's helper libraries from 2012 to 2014 and have written many API
clients; I gave a talk about [designing great client libraries at Twiliocon
in 2013][great-client-libraries]. I can work with your team on API and client
library design.

- **Other Stuff.** This is not an exclusive list! I've learned a ton on the
fly, and can probably do that with your company as well.

I have experience with an array of languages, notably Go, Javascript, Python,
Bash, PHP. I've maintained API clients in more languages than that. Here's
my [resume](https://kev.inburke.com/resume/kevinburke.pdf). Here's [a list of
talks that I've given][talks], with links to video.

[Contact Me](mailto:kevin@burke.services)

### Rates

A typical contract is for 1 month of work. I am normally booked 1 to 3 months
in advance.

I'm open to shorter contracts, but prefer longer ones. For a shorter contract,
we'll divide my monthly rate by the number of days you want, and add a small
amount of overhead.

Please note that work will be conducted in accordance with my [ethics
policy][ethics].

### Previous Engagements

#### [Otto](https://meetotto.com)

Massively improved the team's velocity and ability to identify and fix errors,
and deploy them two production. Rewrote two unmaintained C servers in Go.
Transitioned server-side software stack from physical machines to AWS.

Code reviewed, identified, fixed, and shipped features for a Node.JS app serving
the Otto API. Added several libraries to improve team velocity, ease testing and
standardize the codebase.

#### [Segment](https://www.segment.com)

Built a billing pipeline to help Segment [account for its AWS costs][segment].
Built an admin dashboard with fine-grained permissions for viewing data about
accounts.

#### [Notion Labs][notion]

> "Kevin came in for a week and went over our entire backend. He found a bunch
> of security holes, helped us set up better ops practices, and figured out
> ways to improve our database performance. In the end, everything was running
> smoother and more secure. We call him the one-man S.W.A.T. team for SF
> startups, and already booked his next available slot 👍" - [Ivan Zhao][ivan],
> Co-founder

#### A Twilio customer

Built [Logrole][logrole], an extremely fast, fine-grained Twilio log viewer, in
a one month engagement.

#### [Ngrok LLC][ngrok]

Feature development and improving the testing/local development infrastructure.

[Contact Me](mailto:kevin@burke.services)

[speed-tests]: https://shyp.github.io/2015/07/13/speed-up-your-javascript-tests.html
[write-docs]: https://www.youtube.com/watch?v=sQP_hUNCrcE
[great-client-libraries]: https://www.youtube.com/watch?v=C_UJHqR_2Mo
[talks]: https://github.com/kevinburke/talks/blob/master/videos.md
[notion]: https://www.notion.so/
[ivan]: http://ivzhao.com/
[ngrok]: https://ngrok.com
[logrole]: https://github.com/saintpete/logrole
[ethics]: https://burke.services/ethics.html
