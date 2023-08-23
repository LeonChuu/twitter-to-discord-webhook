FROM elixir:1.13.1 as builder
WORKDIR /build
ADD config config 
ADD lib lib 
ADD mix.exs .
ENV MIX_ENV=prod
RUN ["ls"]
RUN ["mix", "local.hex", "--force"]
RUN ["mix", "local.rebar", "--force"]
RUN ["mix", "deps.get", "--force"]
RUN ["mix", "release", "--force"]

FROM elixir:1.13.1
LABEL org.opencontainers.image.authors="LeonChuu<https://github.com/LeonChuu>"
WORKDIR /app
COPY --from=builder /build/_build/prod/ .
ENTRYPOINT ["./rel/release/bin/release","start"]



