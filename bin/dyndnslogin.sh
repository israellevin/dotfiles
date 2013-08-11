#!/bin/dash
user=''
pass=''
cook=$(mktemp --tmpdir='/tmp' -t dyndnscookieXXX)
agnt='Mozilla/5.0'

mfrm=$(curl -s -A $agnt -c $cook https://account.dyn.com | awk -F\' '/multiform/{ print $6 }')

curl -s --location -A "$agnt" -b $cook -c $cook --data "username=$user&password=$pass&iov_id=&submit=Log+in&multiform=$mfrm" https://account.dyn.com/ | grep -i welcome

rm $cook
exit 0
