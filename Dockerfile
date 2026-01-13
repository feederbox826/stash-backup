FROM alpine:3.23 as final
WORKDIR /app
VOLUME /app/backup
RUN apk add --no-cache \
    bash coreutils jq sqlite-tools tar wget zstd && \
    echo "check_certificate = off" >> ~/.wgetrc
COPY --chmod=0755 app /app
CMD ["/app/docker-entrypoint.sh"]