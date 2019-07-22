# https://hub.docker.com/_/debian
FROM debian:buster-slim

MAINTAINER Sergey Pashinin <sergey@pashinin.com>

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y dovecot-imapd dovecot-pgsql dovecot-sieve dovecot-lmtpd dovecot-ldap \
 && rm -rf /var/lib/apt/lists/* \
           /tmp/*

RUN   mkdir -p /etc/dovecot/sieve
RUN   chown dovecot:dovecot /etc/dovecot/sieve
USER  dovecot

EXPOSE 110 143 993 995

CMD ["/usr/sbin/dovecot", "-F"]
