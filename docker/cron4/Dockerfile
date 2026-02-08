FROM ubuntu:latest

RUN apt-get update && apt-get install -y cron

WORKDIR /src

COPY . .

RUN chmod +x /src/scripts/*.sh
COPY Crontab /etc/cron.d/

CMD cron && tail -f /var/log/cron.log
