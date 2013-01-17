#!/bin/dash

pdate=$(date '+%a %d %b %Y - %H:%M')

psens=$(sensors | grep °C | cut -d+ -f2 | cut -d ' ' -f1 | awk '{if(""==max){max=$1}; if($1>max){max=$1};} END {printf "%.0f", max}')
if [ "$psens" != "0" ]; then
    psens="$psens° "
else
    psens=''
fi

pvolm=$(amixer get Master | grep % | cut -d [ -f4 | cut -d ] -f1)
if [ "$pvolm" != 'off' ]; then
    pvolm="$(amixer get Master | grep % | cut -d [ -f2 | cut -d ] -f1) "
else
    pvolm=''
fi

pplay=$(mpc status | grep "\[playing\]")
if [ "$pplay" ]; then
    pplay="$(mpc current -f '[%title%]|[%file%]' | sed -e 's|.*/||' -e 's|\....$||' -e 's|\(.\{1,40\}\).*|\1|;q').. "
else
    pplay=''
fi

pmail=$(grep 'fullcount' < ~/unreadgmail.xml | sed 's/<fullcount>\(.*\)<\/fullcount>/\1/')
if [ "$pmail" \> "0" ]; then
    pmail="[$pmail] "
else
    pmail=''
fi

pbatt=$(acpi)
if [ "$pbatt" ]; then
    if [ D = $(echo $pbatt | cut -c 12) ]; then
        pbatt="$conct$(echo $pbatt | cut -d ' ' -f 5) "
    else
        pbatt=$(echo $pbatt | cut -d ',' -f 2 | sed 's/ /⌁/')' '
    fi
fi

echo -n "$pbatt$pmail$pplay$pvolm$psens$pdate"
