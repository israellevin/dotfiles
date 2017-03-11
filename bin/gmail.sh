#!/bin/sh
gmail_login=""
gmail_password=""
while true
do
    wget --secure-protocol=TLSv1 --timeout=3 -t 1 -q -O - "https://${gmail_login}:${gmail_password}@mail.google.com/mail/feed/atom" --no-check-certificate > "$HOME/unreadgmail.xml"
    sleep 666
done
