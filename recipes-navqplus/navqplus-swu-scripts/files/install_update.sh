#!/bin/sh

if [ -z '$1' ]; then
    echo install_update.sh requires .swu file name as the only parameter
fi

if [ "`fw_printenv -n mmcpart 2>/dev/null`" = 2 ]; then
    mode=copy1
    echo Updating Image \#1
else
    mode=copy2
    echo Updating Image \#2
fi

if swupdate -L -i $1 -e "stable,$mode" -v; then
    echo Update succeeded, rebooting...
    reboot
else
    echo Update failed
fi
