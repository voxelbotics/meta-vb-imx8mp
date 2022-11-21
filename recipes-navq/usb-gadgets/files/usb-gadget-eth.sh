#!/bin/sh

# Setup Ethernet over USB.
# Parameters: <USB> <UTP#>

if [ $# -lt 1 ]; then
	echo "Not enough arhuments"
	echo "Usage: $0 <USB>"
	exit 1
fi

export PATH=/sbin:/bin:/usr/sbin:/usr/bin

# get parameters
USB_PORT=$1

UDC_DIR=/sys/class/udc
CFG_DIR=/sys/kernel/config/usb_gadget/ETH_$USB_PORT

# use debugfs to set device mode
if [ -e /sys/kernel/debug/usb/$USB_PORT/mode ]; then
	echo "Switching $USB_PORT to device mode..."
	echo device > /sys/kernel/debug/usb/$USB_PORT/mode
	sleep 1
else
	echo "Can't set device mode"
fi

# UDC device entry for USB port must exist
if [ ! -d $UDC_DIR/$USB_PORT ]; then
	echo "UDC device for $USB_PORT is not found"
	exit 1
fi

echo "Setting up Ethernet gadget at $USB_PORT..."

mkdir -p $CFG_DIR && cd $CFG_DIR
mkdir -p strings/0x409
mkdir -p configs/c.1
mkdir -p functions/ecm.usb0

# USB ids
echo 0x1d6b > idVendor
echo 0x104 > idProduct

# USB strings, optional
echo "Collabora" > strings/0x409/manufacturer
echo "ECM" > strings/0x409/product

# assign function to configuration
ln -s functions/ecm.usb0 configs/c.1/

echo $USB_PORT > UDC

echo "Done"
