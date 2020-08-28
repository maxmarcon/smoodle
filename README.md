<!--ts-->
   * [About](#about)
   * [Where can I try it out?](#where-can-i-try-it-out)
   * [How is this different from Doodle?](#how-is-this-different-from-doodle)
   * [What technology does it use?](#what-technology-does-it-use)
   * [How to run the application locally](#how-to-run-the-application-locally)
      * [With docker in "almost production" mode](#with-docker-in-almost-production-mode)
      * [Dev mode with mix](#dev-mode-with-mix)
      * [Emails in local mode](#emails-in-local-mode)
   * [Running tests](#running-tests)
      * [Running the back end tests](#running-the-back-end-tests)
      * [Running the front end tests](#running-the-front-end-tests)

<!-- Added by: max, at: Fri Aug 28 11:09:58 CEST 2020 -->

<!--te-->

# About

Smoodle (the web application has been released under the name *Let's meet*, but throughout the codebase
the initial, tentative name *Smoodle* is still used),
is a responsive, mobile-first single page web app that allows users to create events and share them with
the participants to find out the best date for them. *"Best"* here means the date that works best for the
most people.

Organizers create an event and then share a link with the participants. Each participant can specify which
dates or weekdays do not work for them or which ones they prefer.

The app does not require the creation of any account. The only thing required is the email address of the
event organizer to send them a secret link used to organize the event.

# Where can I try it out?

[Here](https://go.lets-meet.app) 👈

# How is this different from Doodle?

While Doodle works well for meetings with relatively few participants, we think that *Let's meet* is better suited
for events such as parties, dinners, conferences and jaunts with a potentially large number of participants.
In such cases, it can be difficult and unnecessary for the organizer to follow the detailed availability of each participant and instead
what is required is a compact overview of how many people can attend or prefer a given date.

# What technology does it use?

Elixir/Phoenix in the backend, Vue.js in the frontend.

# How to run the application locally

## With docker in "almost production" mode

By far the easiest way, this will run a release similar to the one used in production with optimized
frontend assets. Just type:

```docker-compose up```

And be patient :) After a while, the application will be available at (http://localhost:4000)

## Dev mode with mix

1. Install webapp packages: `cd webapp && yarn install`
2. Start the webapp: `yarn serve`
3. Install hex packages: `cd ../ && mix deps.get`
4. Start the local postgres dev db with `docker-compose -f docker-postgres-dev.yaml up`
5. Set up the database and run the migrations: `mix ecto.setup`
6. Start the server with `mix phx.server`.

The application will be available at (http://localhost:8080)

Note: if you want to use an existing postgres server, then skip step 3 and update `config/dev.exs` with the credentials
and database name for your server.

## Emails in local mode

The emails "sent" by the local applications will be available under: (http://localhost:4000/sent_emails)

# Running tests

The application comes with extensive unit testing for both back- and frontend.

## Running the back end tests

1. Start the local postgres dev db with `docker-compose -f docker-postgres-dev.yaml up`
2. Run: `mix test`

Note: as usual, if you want to use an existing postgres server, then skip step 1 and update config/test.exs with the credentials and database name for your server.

## Running the front end tests

Run: `cd webapp && yarn test-once`
