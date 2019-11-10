FROM elixir:1.9.1

ENV MIX_ENV=docker REPLACE_OS_VARS=true

RUN apt-get update -y && \
  apt-get -y install \
  curl \
  gnupg \
  wait-for-it \
  gawk

RUN curl -sL https://deb.nodesource.com/setup_11.x  | bash - && \
	apt-get update -y && apt-get -y install \
	nodejs

RUN	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
	apt-get update -y && apt-get -y install \
	yarn

COPY . /app

WORKDIR /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

WORKDIR /app/webapp
RUN yarn install
RUN yarn build

WORKDIR /app

RUN mix distillery.release --env=prod

RUN chmod ug+x docker_entrypoint_wrapper.sh

ENTRYPOINT ["./docker_entrypoint_wrapper.sh", "_build/docker/rel/smoodle/bin/smoodle"]
CMD ["foreground"]

