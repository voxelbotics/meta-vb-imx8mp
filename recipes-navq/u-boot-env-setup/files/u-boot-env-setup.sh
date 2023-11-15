#!/bin/sh
EMMC="mmcblk2"

rm -f /etc/fw_env.config
grep -q $EMMC /proc/cmdline
if [ $? -eq 0 ]; then
	ln -s /etc/fw_env.config_emmc /etc/fw_env.config
else
	ln -s /etc/fw_env.config_sd /etc/fw_env.config
fi
