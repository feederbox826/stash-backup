FROM alpine:3.20 as final
WORKDIR /app
VOLUME /app/backup
RUN apk add --no-cache \
    bash coreutils jq sqlite-tools tar zstd
COPY --chmod=0755 app /app
CMD ["/app/docker-entrypoint.sh"]