# https://hub.docker.com/_/debian
FROM debian:buster-slim

MAINTAINER Sergey Pashinin <sergey@pashinin.com>

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y dovecot-imapd dovecot-pgsql dovecot-sieve dovecot-lmtpd dovecot-ldap \

 # Set Dovecot logging to STDOUT/STDERR
 && sed -i -e 's,#log_path = syslog,log_path = /dev/stderr,' \
           -e 's,#info_log_path =,info_log_path = /dev/stdout,' \
           -e 's,#debug_log_path =,debug_log_path = /dev/stdout,' \
        /etc/dovecot/conf.d/10-logging.conf \
 # Set default passdb to passwd and create appropriate 'users' file
 # && sed -i -e 's,!include auth-system.conf.ext,!include auth-passwdfile.conf.ext,' \
 #           -e 's,#!include auth-passwdfile.conf.ext,#!include auth-system.conf.ext,' \
 #        /etc/dovecot/conf.d/10-auth.conf \
 # && install -m 640 -o dovecot -g mail /dev/null \
 #            /etc/dovecot/users \
 # Change TLS/SSL dirs in default config and generate default certs
 && sed -i -e 's,^ssl_cert =.*,ssl_cert = </etc/ssl/dovecot/server.pem,' \
           -e 's,^ssl_key =.*,ssl_key = </etc/ssl/dovecot/server.key,' \
        /etc/dovecot/conf.d/10-ssl.conf \
 && install -d /etc/ssl/dovecot \
 && openssl req -new -x509 -nodes -days 365 \
                -config /etc/dovecot/dovecot-openssl.cnf \
                -out /etc/ssl/dovecot/server.pem \
                -keyout /etc/ssl/dovecot/server.key \
 && chmod 0600 /etc/ssl/dovecot/server.key \
 # Tweak TLS/SSL settings to achieve A grade
 && sed -i -e 's,^#ssl_prefer_server_ciphers =.*,ssl_prefer_server_ciphers = yes,' \
           -e 's,^#ssl_cipher_list =.*,ssl_cipher_list = ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:!DSS,' \
           -e 's,^#ssl_protocols =.*,ssl_protocols = !SSLv3,' \
           -e 's,^#ssl_dh_parameters_length =.*,ssl_dh_parameters_length = 2048,' \
        /etc/dovecot/conf.d/10-ssl.conf \
 # Pregenerate Diffie-Hellman parameters (heavy operation)
 # to not consume time at container start
 && mkdir -p /var/lib/dovecot \
 # && /usr/libexec/dovecot/ssl-params \

 && rm -rf /var/lib/apt/lists/* \
           /tmp/*


EXPOSE 110 143 993 995

CMD ["/usr/sbin/dovecot", "-F"]
