# Running the app

You should be able to run this just like any normal phoenix application. Checkout the code, run the setup, mix test, and then the server. You will need postgres installed.

```
mix setup

mix test

mix phx.server
```

After this you should be able to use the graphiql interface at http://localhost:4000/graphiql. Below is a set of sample queries you can use to interact with the API using graphiql. You will need to change some of the mutations to use UUIDs that are specific to your local setup.

```
query queryUsers{
  users {
    id
    firstName
    lastName
    email
    balance
  }
}

query queryUsersWithVisits{
  users {
    balance
    id
    firstName
    lastName
    email
    requestedVisits{
      id
      minutes
      tasks
    }
    fulfilledVisits{
      id
      minutes
      tasks
    }
  }
}

mutation createUser {
  createUser(firstName: "test", lastName: "user", email: "test.user@papa.com"){
    email
    firstName
    id
    lastName
  }
}

mutation requestVisitBadDate {
  requestVisit(date: "20200701", tasks: "", memberId:""){
    id
    tasks
  }
}

mutation requestVisitBadMember {
  requestVisit(date: "2020-07-01", tasks: "Just hang out", memberId:""){
    id
    tasks
  }
}

mutation requestVisit {
  requestVisit(date: "2020-07-01", tasks: "Just hang out", memberId:"1084354a-bb01-4588-b120-45597e29bfb4"){
    id
    tasks
  }
}

mutation fulfillVisit {
  fulfillVisit(visitId:"c1b6ff1e-add1-42cc-9fc9-d45fd7d40cf9", palId:"16296900-fea1-4bfa-b2e0-cc20bacc0d36", minutes:100){
    id
    tasks
  }
}
```

# General Assumptions:

Some assumptions have been laid out in the Process section below, but in this section I will list some general assumptions.

## Authentication

At my last two jobs I had to implement authentication that orginated in other systems, one that used a custom dynamodb session manager and SPA that would sent a session token to validate against. Most recently, I'm using a system that includes Auth0, JWTs, Krakend, etc.

I didn't see any requirements for authentication, so if I have time, I will plan to implement guardian to allow for API auth. Otherwise, I think there is enough in the sample app to "show us how you think and put your engineering values on display". I'll gladly discuss authentication strategies at any time.

## Performance

This is not an optomized application. There are things that would not scale, like the GraphQL requests with associations. There is no pagination, we could use something like Relay (https://hexdocs.pm/absinthe/relay.html) for built in pagination functionality so the API couldn't request the world. There are also other liberties and shortcuts taken because this is a sample application, I added a few indexes here and there, but I might have missed some. I'm not using select statements to trim down the amount of columns queried from a table, etc. Batch Resolution in Absinthe (https://hexdocs.pm/absinthe/batching.html) is not something I worried about in this application, but someting I would absolutely do in a produciton app.

## Typespecs and Dialyzer

I'm usually really diligent about typespecs and dialyzer, but to save me some time, I omitted this part of my development cycle. This would 100% be something I do for an actual application that would get used and not thrown away.

## Full Refactoring and DRY

Not everything is fully refactored and completely dry. Things like the Resolvers format_errors/1 I just copy/pasted for time. There might be others I just ignored for now for speed and sample app reasons.

## Docker

I just did this on my host machine to save time on getting a docker container setup for local developement. It would make it easier to run on different machines.

# Process

First thing I wanted to do was create a Phoenix app. I almost thought of building just an elixir app and plug to make it more slim, but ultimately figured Papa is using Phoenix so why not just go ahead and use it. 

Since this app is API only, I went ahead and used a lot of the options that remove some of the extras that won't be needed, like assets, htmls, liveview, etc. I also have a prefernce for umbrealla apps and UUIDs, so I add those options as well.

```
mix phx.new --no-assets --no-html --no-dashboard --no-live --no-mailer --umbrella --binary-id papa
```

## Feature 1: Users must be able to create accounts

Assumptions: email address should be unique

For the users and roles, I almost went down the route of User <-> Roles with a join table, but realized do we even need that. If anyone can be a member, and anyone can be a pal, at any given time do we really even need explict roles? 

One of the reasons why I decided on this was the sentence "If a member's account has a balance of 0 minutes, they cannot request any more visits until they fulfill visits themselves." To me, that gives the impression that memebers are going to be pals, and maybe quite often?

I'm also going to resist all temptations of scope creep and stick to the fisrt_name/last_name, and forget that I've ever read https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/ ;)

(Ask Vanessa sometime about her expertise in dealing with names and aliases)

```
mix ecto.create

cd apps/papa_web/

mix phx.gen.schema User users first_name:string last_name:string email:string

# add unique constraint to email in migration 
#
# create unique_index(:users, [:email])

cd ../../

mix ecto migrate

# sanity check to make sure everything is wired up correctly.

mix phx.server
```

At this point we want to write some test to make sure my test suite is all wired up correctly, and make sure we can validate a User changeset.

Assumption: validation of email format, exisitance, confirmation, etc will come in a future feature.

```
# add validate_unique on email in the User schema
|> unique_constraint(:email)

# create and write tests in apps/papa/test/user/user_test.exs

mix test apps/papa/test/user/user_test.exs
```

https://github.com/taelor/papa/pull/1/commits/390da4208f0d5c58769750f0ebe68c99d0789b30

Next we want to go ahead and write an API request to create a User. In the job description I noticed Papa uses GraphQL, so I'm going to go ahead and use absinthe for our GraphQL functionality. I used absinthe when I worked at Interfolio, so I'm fairly familiar with it. We also want to include GraphIQL so we can have an easy quick way to interact with the API.

```
# add absinthe to papa_web mix.exs deps
{:absinthe, "~> 1.7"},
{:absinthe_plug, "~> 1.5"}

mix deps.get
```

https://github.com/taelor/papa/pull/1/commits/b9e69ed687f75b84784d4bf842b2ed28691f6a0b

At this point, we have graphiql working, but the users query is returning an empty list. I'm going to go ahead and add some users to the seeds.exs file just as another sanity check that everything is wired up, and we can query for users.

```
# add some basic user inserts to the seeds.exs file.
User.changeset(%User{}, %{first_name: "John", last_name: "Doe", email: "john.doe@papa.com"})
|> Repo.insert!()

# run ecto.reset to tear down and rerun setup, this time running the non-empty seed file.
mix ecto.reset
```

Now we can go back to the GraphIQL interface and query for Users, and we see the three users we added to the seed file are now showing up properly with their attributes and the auto generated UUID.

https://github.com/taelor/papa/pull/1/commits/ea42598956c6381346e2885a06f550c56d262634

Next, we need to go ahead and get our testing framework setup for querying the graphql api, we can do something simple for now, and expand on it later.

When writing this test, we need to get some data in the database before we make the query. We could continue manually inserting ecto changeset via repo, but I usually start to reach for factories as soon as possible.

Usually I roll my own factories following the ecto guide here: https://hexdocs.pm/ecto/test-factories.html

But since this is a sample app, I thought we could experiment with a package I've always wanted to use, ex_machina. (https://github.com/thoughtbot/ex_machina) I've used thoughtbot's factories for ruby in the past, and while sometimes they were cumbersome or led to particular setup problems, I feel like they've learned a lot in their history, as well as me, and if used properly, factories can be quite helpful in test.

We can go ahead and refactor the Repo.insert in the user_test.exs to use a factory as well.

https://github.com/taelor/papa/pull/1/commits/45ed89f8b63079c9d05b1aa86eea2d5043b47a75

Finally, I think we have everything to setup to actually do the feature now, which is creating a user.

We are going to want to add a mutatation for the GraphQL API, and write a test for it.

https://github.com/taelor/papa/pull/1/commits/d5d51d8c2ff0d5550e4c0a2053245737c203c7f0

## Feature 2: As a member, a user can request visits. 

Assumptions: I'm only using a date here from the data model, but it might be better to use datetime for more specific scheduling, but as this is a simplified model, we can just use date for now. Also, tasks would probably end up being its own schema/table if we wanted more granular tracking/reporting, but for this simple model. I'm just going to make it a text field, and it will represent what the Member is requesting for their visit. A more complex model would have requested tasks and completed tasks (maybe the same row with a boolean to denote if it was completed). I'm also going to implement this exactly as the specifictions for the second item say, without any balance validation which will come in feature 4. One other assumption is the person requesting the visit isn't going to be estimating how long that visit is going to be, and the minutes field is for how long the visit took.

For this feature the first thing we need to do is create the Visit schema and add the relationships between User and Visit. I will go ahead and add some requested visits to the seeds, and make sure we can see those in the query_users graphql request to make sure the associations are working properly.

```
cd apps/papa_web/

mix phx.gen.schema Visit visits member_id:references:users date:date minutes:integer tasks:text

cd ../../apps/papa

# run a reset to make sure we pick up the new seeds
mix ecto.reset
```

https://github.com/taelor/papa/pull/2/commits/7a325b18664f7f9ea687040c6fc452478d1fc48a

I wanted to show one small (premature) performance optomization we could make here. We could inspect on the graphql query coming in, and only preload the visits table when actually requested. If its not asked for, its not queried for.

https://github.com/taelor/papa/pull/2/commits/e441d19199de1121331994536ac93845d8052809

Now that we can see visits for a user, we can write the mutation for a member to request a visit.

https://github.com/taelor/papa/pull/2/commits/012903d24b8a9d0a8e3085a0c86ee71621befea7

## Interlude: Github Actions

Oh no, a failing test made its way into main!

Testing is super important to me. Early on in my career, I worked on a Rails application with absolutely zero tests. We were constantly putting out fires, fixings regressions, and deploying with no confidence. After a year of that, I couldn't take it anymore, and demanded that we spend time refactoring and writing tests. As you can imagine, it was a huge win.

I've gotten to the point, where I almost don't know how to write code, without writing tests. So now, early on in creating an application, I like to get github actions setup for PRs to run the test suite, check for compile warnings, as well as run dialyzer.

To deploy with confidence, you must have a good test suite, it is a necessary (but not sufficient) condition.

https://github.com/taelor/papa/pull/4

## Feature 3: Visit Fulfillment

At this point, I'm having a hard time understanding how this system would bootstrap itself. When a user signs up, there is nothing the documentation about a user would get minutes, except by fulfilling visits. But if no user can request a visit if their balance is 0, then there would be no visits able to be fulfilled.

So for this example application, we're going simulate the "health plans allow them a certain number of visit hours per year", by giving everyone 1000 hours for free when they sign up! We'll ignore entropy of the system with 15% overhead eventually draining all the minutes from everyone like the heat death of the universe.

> side note: if it wasn't for the 15% overhead, this would almost be something like a LETS or Timebank. 
> 
> https://en.wikipedia.org/wiki/Local_exchange_trading_system
>
> https://en.wikipedia.org/wiki/Time-based_currency

Now we haven't discussed "account balance", and it isn't listed anywhere in the database. Also, I haven't really been able to use OTP yet. So I'm going to try something.

I want to create a GenServer for each user. And that GenServer is going to hold the state of a user's minutes balance. All actions of requesting and fulfilling are going to go through this GenServer. So we should be able to maintain that account balance as visit come in.

Now what about when the application goes down and back up? For each user, we can load all their fullfilled visits, and recalcuate their balance.

The first thing we can do, is add some more requested and fullfilled visits to our seeds, create our genserver initialization process, and see if we can get the balances correct.

After that, it was just kind of one of those moments where you get in the zone, go heads down and blast it all out.

For this setup, we can use a DynamicSupervisor to Manage these Account servers, and create/supervise them dynamically when a user is created. They properly ledger a user's balance when they spin up (using continue to not block), and will debit/credit upon visit fulfillment.

There is a lot to this PR, and I would absolutely love to talk about it more in person, so we can discuss the reason why some decisions were made, and what improvements you could make to a system like this (there are some comments scattered throughout)

https://github.com/taelor/papa/pull/5

## Feature 4: Prevent Visit Request on Zero Balance or Less

This one was fairly easy now that all the heavy lifting was done.

One thing to note, I did put this check fairly low down in the stack for the Visit.Create as opposed to higher up in the resolver or something. This would be the time where I would discuss with the team a holistic approach to this validation, and maybe have a ticket to refactor and tighten up the error handling and validation.

https://github.com/taelor/papa/pull/6