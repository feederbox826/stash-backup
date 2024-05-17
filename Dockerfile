FROM alpine:latest as sqldiff
WORKDIR /home/builder
RUN adduser builder --disabled-password && \
    addgroup builder abuild && \
    apk add alpine-sdk
USER builder
COPY build .
RUN ls -la
RUN abuild-keygen -an && \
    abuild checksum && \
    abuild -r
USER root
RUN cd /home/builder/packages/home/x86_64 && \
    apk add *.apk --allow-untrusted

FROM alpine:latest as final
WORKDIR /app
VOLUME /app/backup
RUN apk add --no-cache \
    bash coreutils curl jq sqlite
COPY --from=sqldiff /usr/bin/sqldiff /usr/bin/sqldiff
COPY --chmod=0755 *.sh .
CMD ["/app/entrypoint.sh"]