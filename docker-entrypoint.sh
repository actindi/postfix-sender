#!/bin/bash

function postfix_conf() {
  local key=${1}
  local value=${2}
  [ "${key}" == "" ] && return 1
  [ "${value}" == "" ] && return 1
  echo "postconf -e ${key} = ${value}"
  postconf -e "${key} = ${value}"
}

postfix_conf 'allow_min_user' 'yes'

if [ -n "${TZ}" ]; then
  cp -f /usr/share/zoneinfo/${TZ} /etc/localtime
  echo ${TZ} > /etc/timezone
  echo "TZ: ${TZ}"
fi

postfix_conf 'myhostname' "${MYHOSTNAME}"
postfix_conf 'mydomain' "${MYDOMAIN}"
postfix_conf 'inet_interfaces' "${INET_INTERFACE}"
postfix_conf 'mynetworks' "${MYNETWORKS}"

if [ -n "${RELAYHOST}" ]; then
  postfix_conf 'relayhost' "${RELAYHOST}"
fi

if [ -n "${SASL_USER}" ]; then
  postfix_conf 'smtpd_sasl_auth_enable' 'yes'
  postfix_conf 'broken_sasl_auth_clients' 'yes'
  postfix_conf 'smtpd_recipient_restrictions' 'permit_sasl_authenticated,reject_unauth_destination'

  echo ${SASL_USER} | tr , \\n > /tmp/passwd
  while IFS=':' read -r _user _pwd; do
    echo $_pwd | saslpasswd2 -p -c -u ${MYHOSTNAME} $_user
  done < /tmp/passwd
  chown postfix /etc/sasl2/sasldb2
fi

if [ -n "${DKIM_KEY}" ]; then
  sed -i -e "s/^Domain.\+$/Domain  ${MYDOMAIN}/" /etc/opendkim/opendkim.conf
  echo "${DKIM_KEY}" > /var/db/dkim/default.private
  chmod 600 /var/db/dkim/default.private

  postfix_conf 'smtpd_milters' 'inet:127.0.0.1:8891'
  postfix_conf 'non_smtpd_milters' '$smtpd_milters'
  postfix_conf 'milter_default_action' 'accept'
else
  opendkim-genkey -D /var/db/dkim/ -d example.com
fi

postfix_conf 'smtp_use_tls' 'yes'
postfix_conf 'smtpd_use_tls' 'yes'
postfix_conf 'smtp_tls_security_level' 'may'
postfix_conf 'smtpd_tls_security_level' 'may'
postfix_conf 'smtp_tls_cert_file' '/etc/secret-volume/tls.crt'
postfix_conf 'smtp_tls_key_file' '/etc/secret-volume/tls.key'
postfix_conf 'smtpd_tls_cert_file' '/etc/secret-volume/tls.crt'
postfix_conf 'smtpd_tls_key_file' '/etc/secret-volume/tls.key'

newaliases

exec "$@"
