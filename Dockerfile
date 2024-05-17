FROM alpine:edge as final
WORKDIR /app
VOLUME /app/backup
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "0 0 1 * * cd app && /app/consolidate.sh" > /etc/crontabs/root && \
    apk add --no-cache \
    bash coreutils curl jq sqlite sqlite-tools tar zstd
COPY --chmod=0755 app /app
CMD ["/app/docker-entrypoint.sh"]