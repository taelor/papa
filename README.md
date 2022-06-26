# General Assumptions:

Some assumptions have been laid out in the Process section below, but in this section I will list some general assumptions.

## Authentication

At my last two jobs I had to implement authentication that orginated in other systems, one that used a custom dynamodb session manager and SPA that would sent a session token to validate against. Most recently, I'm using a system that includes Auth0, JWTs, Krakend, etc.

I didn't see any requirements for authentication, so if I have time, I will plan to implement guardian to allow for API auth.

## Performance

This is not an optomized application. There are things that would not scale, like the GraphQL requests with associations. There is no pagination, we could use something like Relay (https://hexdocs.pm/absinthe/relay.html) for built in pagination functionality so the API couldn't request the world. There are also other liberties and shortcuts taken because this is a sample application, I added a few indexes here and there, but I might have missed some. I'm not using select statements to trim down the amount of columns queried from a table, etc. Batch Resolution in Absinthe (https://hexdocs.pm/absinthe/batching.html) is not something I worried about in this application, but someting I would absolutely do in a produciton app.

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

