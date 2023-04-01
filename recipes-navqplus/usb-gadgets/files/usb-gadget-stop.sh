#!/bin/sh

# Disable USB Gadget.
# Parameters: <Gadget>

if [ $# -lt 1 ]; then
	echo "Not enough arguments"
	echo "Usage: $0 <Gadget>"
	exit 1
fi

# get parameters
GADGET=$1
CFG_DIR=/sys/kernel/config/usb_gadget/

cd $CFG_DIR

[ -d $GADGET ] || exit

echo "Disabling USB gadget $GADGET"
echo '' > $GADGET/UDC

