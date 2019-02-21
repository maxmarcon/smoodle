FROM elixir:1.7.4

ENV MIX_ENV=docker REPLACE_OS_VARS=true

WORKDIR /app

COPY . /app

RUN apt-get update -y
RUN apt-get -y install curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_11.x  | bash -
RUN apt-get -y install nodejs

WORKDIR /app/assets

RUN npm install
RUN npm run deploy

WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

RUN mix phx.digest

RUN mix release --env=prod

RUN chmod ug+x docker_entrypoint_wrapper.sh

ENTRYPOINT ["./docker_entrypoint_wrapper.sh", "_build/docker/rel/smoodle/bin/smoodle"]
CMD ["foreground"]

