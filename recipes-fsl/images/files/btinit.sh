#!/bin/bash

function increase_port_speed
{
    rate=${1:-3000000}

    echo "change the speed to $rate"
    rateStr=$(printf "0x3f 0x0009 0x%x 0x%x 0x%x 0x%x" \
        $((rate & 255)) $((rate>>8 & 255)) $((rate>>16 & 255)) $((rate>>24 & 255)))
    /usr/bin/hcitool -i hci0 cmd $rateStr
    /usr/bin/killall hciattach
    /usr/bin/hciattach /dev/ttymxc0 any -s $rate $rate flow
    /usr/bin/hciconfig hci0 up 
}

/usr/bin/hciattach /dev/ttymxc0 any -s 115200 115200 flow
/usr/bin/hciconfig hci0 up

# Increase the BT baud rate
increase_port_speed 3000000
