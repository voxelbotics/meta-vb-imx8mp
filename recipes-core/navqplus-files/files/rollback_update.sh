#!/bin/sh

if [ "`fw_printenv -n mmcpart 2>/dev/null`" = 2 ]; then
    fw_setenv mmcpart 1
    echo Rollback to Image \#1
else
    fw_setenv mmcpart 2
    echo Rollback to Image \#2
fi

reboot
