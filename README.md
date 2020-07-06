# Postfix sender for Docker

Simple Postfix SMTP docker image with SASL and DKIM authentication.<br>
It also includes syslog to enable logging to stdout.

## Usage
```
docker run \
  -p 25:25 \
  -e MYHOSTNAME="mail.example.com" \
  -e MYDOMAIN="example.com" \
  -e INET_INTERFACE="all" \
  -e MYNETWORKS="172.16.0.0/12" \
  -e RELAYHOST="[172.16.0.1]" \
  -e TZ="Asia/Tokyo" \
  -e SASL_USER="test:foobar" \
  -e DKIM_KEY="dkim private key include LF" \
  actindi/postfix-sender:latest
```

### OpenDKIM
Create a private key on other host.
```
opendkim-genkey -b 2048 -d example.com
```
Set private key to DKIM_KEY, and public key set to DNS.

## Environment variable
- `MYHOSTNAME`: Postfix main.cf 'myhostname' setting. And SASL realm.
- `MYDOMAIN`: Postfix main.cf 'mydomain' setting. And OpenDKIM 'Domain' setting.
- `INET_INTERFACE`: Postfix main.cf 'inet_interface' setting.
- `MYNETWORKS`: Postfix main.cf 'mynetworks' setting.
- `RELAYHOST`: Postfix main.cf 'relayhost' setting.
- `TZ`?: time zone. default is UTC.
- `SASL_USER`?: If use SASL authentication, set 'user:password' format. Only one user.
- `DKIM_KEY`?: If use DKIM authentication, set RSA key.
