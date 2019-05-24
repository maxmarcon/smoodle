# Smoodle

Smoodle (the web application has been released under the name *Let's meet*, but throughout the codebase
the initial, tentative name *Smoodle* is still used),
is a responsive, mobile first single page web app that allows users to create events and share them with
the participants to find out the best date for them. *"Best"* here means the date that works best for the
most people.

Organizers create an event and then share a link with the participants. Each participant can specify which
dates or weekdays do not work for them or which ones they prefer.

The app does not require the creation of any account. The only thing required is the email address of the
event organizer to send them a secret link used to organize the event.

## Where can I try it out?

The web application is available [here](https://go.lets-meet.app).

## How is this different from Doodle?

While Doodle works well for meetings with relatively few participants, we think that *Let's meet* is better suited
for events such as parties, dinners, conferences and jaunts with a potential large number of participants.
In such cases it can be difficult and unnecessary for the organizer to follow the detailed availability of each participant and instead
what is required is a compact overview of how many people can attend or prefer a given date.

## What technology does it use?

Elixir/Phoenix in the backend, Vue.js in the frontend.

## How to run it locally

### With docker in "almost production" mode

By far the easiest way, this will run a distillery release similar to the one used in production with optimized
front-end assets. Just run:

```docker compose up```

And be patient :) After a while, the application will be available at (http://localhost:4000)

### Dev mode with mix

1. Install npm packages: `cd assets && npm install`
2. Install hex packages: `cd ../ && mix deps.get`
3. Start the local postgres dev db with `docker-compose -f docker-postgres-dev.yaml up`
4. Set up the database and run the migrations: `mix ecto.setup`
5. Start the server with `mix phx.server`. This will also compile the app and build the front-end assets (it will need some time...)

The application will be available at (http://localhost:4000)

Note: if you want to use an existing postgres server, then skip step 3 and update `config/dev.exs` with the credentials
and database name for your server.

### Emails in local mode

The emails "sent" by the local applications will be available under: (http://localhost:4000/sent_emails)

## Running tests

The application comes with extensive unit testing for both back and front-end.

### Running the back end tests

1. Start the local postgres test db with `docker-compose -f docker-postgres-test.yaml up`
2. Run: `mix test`

Note: as usual, if you want to use an existing postgres server, then skip step 1 and update config/test.exs with the credentials and database name for your server.

### Running the front end tests

Run: `cd assets && npm run test`
