ARG node_version
ARG elixir_version

FROM node:${node_version}
COPY . /app
WORKDIR /app/webapp
RUN yarn install
RUN yarn build

FROM elixir:${elixir_version}

RUN apt-get update -y && \
  apt-get -y install \
  wait-for-it \
  gawk

ENV MIX_ENV=docker
COPY . /app
WORKDIR /app
COPY --from=0 /app/webapp/dist/ ./priv/static

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

RUN mix release

RUN chmod ug+x docker_entrypoint_wrapper.sh

ENTRYPOINT ["./docker_entrypoint_wrapper.sh", "_build/docker/rel/smoodle/bin/smoodle"]
CMD ["start"]
