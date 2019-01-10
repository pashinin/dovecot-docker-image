# https://hub.docker.com/_/debian
FROM debian:buster-slim

MAINTAINER Sergey Pashinin <sergey@pashinin.com>

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y dovecot-imapd dovecot-pgsql dovecot-sieve dovecot-lmtpd dovecot-ldap \
 && rm -rf /var/lib/apt/lists/* \
           /tmp/*


EXPOSE 110 143 993 995

CMD ["/usr/sbin/dovecot", "-F"]
