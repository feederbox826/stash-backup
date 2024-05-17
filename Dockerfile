FROM alpine:edge as final
WORKDIR /app
VOLUME /app/backup
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache \
    bash coreutils curl jq sqlite sqlite-tools
COPY --chmod=0755 app /app
CMD ["/app/docker-entrypoint.sh"]