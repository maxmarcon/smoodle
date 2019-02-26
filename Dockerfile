FROM elixir:1.8.1

ENV MIX_ENV=docker REPLACE_OS_VARS=true

RUN apt-get update -y
RUN apt-get -y install curl gnupg wait-for-it gawk
RUN curl -sL https://deb.nodesource.com/setup_11.x  | bash -
RUN apt-get -y install nodejs

COPY ./mix.exs ./mix.lock /app/
WORKDIR /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

COPY ./assets/package.json ./assets/package-lock.json /app/assets/
WORKDIR /app/assets
RUN npm install

COPY . /app

RUN npm run deploy

WORKDIR /app

RUN mix phx.digest

RUN mix release --env=prod

RUN chmod ug+x docker_entrypoint_wrapper.sh

ENTRYPOINT ["./docker_entrypoint_wrapper.sh", "_build/docker/rel/smoodle/bin/smoodle"]
CMD ["foreground"]

