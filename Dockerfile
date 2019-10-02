FROM elixir:1.9.1 as build

# Ensure latest versions of Hex/Rebar are installed on build
RUN mix do local.hex --force, local.rebar --force

COPY config ./config
COPY lib ./lib
COPY mix.exs ./mix.exs
COPY mix.lock ./mix.lock

ENV MIX_ENV=prod
RUN mix deps.get
RUN mix deps.compile 
RUN mix release

FROM erlang:22

ENV LC_ALL=en_US.UTF-8

COPY --from=build /_build/prod/rel/derivcotest ./app
COPY data ./data

ENTRYPOINT ["/app/bin/derivcotest"]
CMD ["start"]