# General Assumptions:

Some assumptions have been laid out in the Process section below, but in this section I will list some general assumptions.

## Authentication

At my last two jobs I had to implement authentication that orginated in other systems, one that used a custom dynamodb session manager and SPA that would sent a session token to validate against. Most recently, I'm using a system that includes Auth0, JWTs, Krakend, etc.

I didn't see any requirements for authentication, so if I have time, I will plan to implement guardian to allow for API auth.

# Process

First thing I wanted to do was create a Phoenix app. I almost thought of building just an elixir app and plug to make it more slim, but ultimately figured Papa is using Phoenix so why not just go ahead and use it. 

Since this app is API only, I went ahead and used a lot of the options that remove some of the extras that won't be needed, like assets, htmls, liveview, etc. I also have a prefernce for umbrealla apps and UUIDs, so I add those options as well.

```
mix phx.new --no-assets --no-html --no-dashboard --no-live --no-mailer --umbrella --binary-id papa
```

## Feature 1: Users must be able to create accounts

For the users and roles, I almost went down the route of User <-> Roles with a join table, but realized do we even need that. If anyone can be a member, and anyone can be a pal, at any given time do we really even need explict roles? 

One of the reasons why I decided on this was the sentence "If a member's account has a balance of 0 minutes, they cannot request any more visits until they fulfill visits themselves." To me, that gives the impression that memebers are going to be pals, and maybe quite often?

I'm also going to resist all temptations of scope creep and stick to the fisrt_name/last_name, and forget that I've ever read https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/ ;)

(Ask Vanessa sometime about her expertise in dealing with names and aliases)

Assumption: email address should be unique

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

At this point I want to write some test to make sure my test suite is all wired up correctly, and I can make sure we can validate a User changeset.

Assumption: validation of email format, exisitance, confirmation, etc will come in a future feature.

```
# add validate_unique on email in the User schema
|> unique_constraint(:email)

# create and write tests in apps/papa/test/user/user_test.exs

mix test apps/papa/test/user/user_test.exs
```

https://github.com/taelor/papa/pull/1/commits/390da4208f0d5c58769750f0ebe68c99d0789b30

Next I want to go ahead and write an API request to create a User. In the job description I noticed Papa uses GraphQL, so I'm going to go ahead and use absinthe for our GraphQL functionality. I used absinthe when I worked at Interfolio, so I'm fairly familiar with it. I also want to include GraphIQL so I can have an easy quick way to interact with the API.

```
# add absinthe to papa_web mix.exs deps
{:absinthe, "~> 1.7"},
{:absinthe_plug, "~> 1.5"}

mix deps.get
```

https://github.com/taelor/papa/pull/1/commits/b9e69ed687f75b84784d4bf842b2ed28691f6a0b

At this point, I have graphiql working, but the users query is returning an empty list. I'm going to go ahead and add some users to the seeds.exs file just as another sanity check that everything is wired up, and we can query for users.

```
# add some basic user inserts to the seeds.exs file.
User.changeset(%User{}, %{first_name: "John", last_name: "Doe", email: "john.doe@papa.com"})
|> Repo.insert!()

# run ecto.reset to tear down and rerun setup, this time running the non-empty seed file.
mix ecto.reset
```

