FROM alpine:edge as build
RUN apk add --no-cache --update zig
WORKDIR /src/app
COPY . .
RUN zig build --release=small

FROM gcr.io/distroless/static-debian12
COPY --from=build /src/app/zig-out/bin/zig-htmx-tailwind-example /
ENV ADDR "0.0.0.0"
ENTRYPOINT [ "/zig-htmx-tailwind-example" ]
