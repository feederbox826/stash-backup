FROM debian:stable-slim
COPY . /app
WORKDIR /app
RUN apt update && \
    apt install curl jq sqlite3 -y && \
    chmod +x *.sh && \
    echo "0 0 * * * /app/backup.sh" > /etc/cron.d/backup
CMD ["cron", "-f"]