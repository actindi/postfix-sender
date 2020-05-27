FROM alpine:3.11.6

USER root
WORKDIR /tmp
EXPOSE 25

RUN apk update \
 && apk add \
    bash \
    ca-certificates \
    cyrus-sasl \
    cyrus-sasl-login \
    cyrus-sasl-plain \
    cyrus-sasl-crammd5 \
    iproute2 \
    mailx \
    opendkim \
    opendkim-utils \
    postfix \
    postfix-pcre \
    rsyslog \
    supervisor \
    tzdata \
 && (rm "/tmp/"* 2>/dev/null || true) && (rm -rf /var/cache/apk/* 2>/dev/null || true)

ADD supervisord.conf /etc/supervisord.conf
ADD rsyslog.conf /etc/rsyslog.conf
ADD smtp.conf /etc/sasl2/smtp.conf
ADD opendkim.conf /etc/opendkim/opendkim.conf

RUN mkdir -p /var/spool/rsyslog \
 && mkdir -p /var/db/dkim \
 && mkdir -p /var/lib/opendkim

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD /usr/bin/supervisord -c /etc/supervisord.conf
