# Ethics

Software has tremendous power to change the world for the better. It can also
change the world for worse, intentionally or [unintentionally][life-or-death].

I'm a human and I have a lot of biases, intentional or not.

### Technical limitations

The code I write will probably have errors in it. That's an unfortunate fact
of life for all software engineers; I certainly will try my best to write
error free code. Sometimes it might be too expensive in terms of time to fix a
particular error. It might require hours of additional feature work that aren't
worth the time, or the error might occur so rarely that would be appropriate to
handle if you were e.g. building a rocket ship, but not common web software.
I'll try to use my best judgment about this tradeoff, but I could make a
mistake.

When researching the right way to solve a problem, I need to make a tradeoff
between spending more time to research a solution, and beginning to implement
the best solution I have so far. I have been building software for a fair
amount of time, and have an idea of how to solve a lot of common problems. I've
also had to make this tradeoff a fair number of times in the past, and consider:

- the costs of getting the implementation wrong
- the current solution's ability to solve the problem
- the likelihood of a better solution
- the potential benefits of a better solution.

It's possible the solutions I've used in the past aren't optimal, or I might
get the tradeoff wrong.

I can give you an estimate of how long it will take to implement a feature.
This estimate [may be too low][estimate]. This is [a wider problem in software
engineering][estimation-problem]. I'll try to estimate based on how long
similar tasks took me last time, and break a large task into smaller tasks that
are easier to estimate. When I have been consulting longer, I will publish a
record of my estimates, and their accuracy (currently the sample size is too
small).

### Security

I may write code that has security vulnerabilities. These are worse than common
defects, because they may compromise company security or user privacy. I am not
a professional security engineer, nor do I have the mathematical background
to assess whether a cryptographic algorithm is implemented correctly. It's
unlikely that I will be able to write software that can protect your secrets
from a sophisticated government attacker.

That said, I am much more knowledgeable about security than the average
engineer, and have found and fixed security problems at every company I've
worked at. I try my best to ensure every piece of software I deploy does not
have security vulnerabilities in it, or unsafe interfaces. I try to use
security software that has been written by professionals.

### Conflicts of Interest

Occasionally I may do a short experiment with a new or unfamiliar technology,
even if I know I can implement something using an existing tool. I will benefit
more from this than you will - it might not work, and I might have wasted
a little time. In the long run, trying new things has made me a much more
effective consultant than always staying in my lane. (Also, it's possible the
new technology will work really well!)

If I have a choice between two solutions to a problem that are equivalent in
implementation time/error rate/etc, I will choose the one that is more likely
to advance my career, or lead to a future talk/blog post. I'm happy to credit
you as a sponsor if I develop a blog post or talk based on something I've
learned while working with you.

You might ask for a feature that I think is a bad idea. If I tell you I don't
think it's a good idea, will this jeopardize our working relationship? In the
past I have had success telling clients what I think; if you want to proceed
despite my objections, I have no problems implementing the feature in question.

Related: if you think something would take a long time, and I can get it done
quickly, I may be reducing the amount of time I can bill for! I'll never do
something more slowly on purpose. If this reduces the amount of future work,
beyond our contractual agreement, so be it; hopefully I can make up for it in
recommendations from happy clients, or by working on other projects in the
extra time we have.

### Unethical Requests

I won't agree to do work that I believe is unethical. I am a little hesitant to
define this too precisely, because there may be categories I don't define that
are obviously wrong. But here are some examples of things I won't do:

- Some amount of embellishment may be necessary in marketing ("X is the easiest
way to do Y", &c), but I won't deliberately lie to anyone - for example,
claiming a 80% success rate if the real number is 30%.

- Cheat people out of money they are owed. Steal other people's designs, or
software, without credit.

- Violate users reasonable expectations of security or privacy.

- Build software that may be used to violate people's fundamental rights. This
is slightly more specific than a general tool used for evil purposes - the Silk
Road was written using the programming language PHP, but that doesn't mean
PHP is inherently evil, or you shouldn't create new programming languages.

- Violate laws, except where those laws conflict with the point above. I would
note, for example, that [*Korematsu vs. United States*][korematsu] has not been
overturned.

### Wetware

We'll sign a contract for work for a period of time, usually a month or a
little more. I try to dedicate as much of my working hours as a I can to the
project, but I might not dedicate 100% to the project - I need to get coffee,
go to the bathroom, eat lunch, keep track of expenses, etc.

### Promises

I'll try my best to deliver the best product I can in the time that we have,
and to justify the trust you've placed in me. I care a lot about the products
I make, and will extend that same care to the products I build for you.

Thanks very much to [Kyle Kingsbury][jepsen-ethics] for the initial inspiration
for this document.

[life-or-death]: https://techcrunch.com/2016/11/16/when-bias-in-product-design-means-life-or-death/
[jepsen-ethics]: http://jepsen.io/ethics.html
[estimate]: https://en.wikipedia.org/wiki/Planning_fallacy
[estimation-problem]: https://en.wikipedia.org/wiki/Software_development_effort_estimation<Paste>
[korematsu]: https://en.wikipedia.org/wiki/Korematsu_v._United_States
