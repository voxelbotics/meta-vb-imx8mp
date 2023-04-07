#!/bin/sh
# Setup MTP daemon.
# Parameters: <USB>

if [ $# -lt 1 ]; then
	echo "Not enough arhuments"
	echo "Usage: $0 <USB>"
	exit 1
fi

export PATH=/sbin:/bin:/usr/sbin:/usr/bin

# get parameters
USB_PORT=$1

UDC_DIR=/sys/class/udc
CFG_DIR=/sys/kernel/config/usb_gadget/MTP_$USB_PORT

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

echo "Setting up MTP gadget at $USB_PORT..."

mkdir -p $CFG_DIR && cd $CFG_DIR
mkdir -p configs/c.1
mkdir -p functions/ffs.mtp
mkdir -p strings/0x409
mkdir -p configs/c.1/strings/0x409

echo 0x0100 > idProduct
echo 0x1D6B > idVendor

cat /sys/devices/soc0/serial_number > strings/0x409/serialnumber

echo "VoxelBotics" > strings/0x409/manufacturer
echo "NavqPlus" > strings/0x409/product

echo "Conf 1" > configs/c.1/strings/0x409/configuration
echo 120 > configs/c.1/MaxPower

mkdir /dev/ffs-mtp
mount -t functionfs mtp /dev/ffs-mtp
ln -s functions/ffs.mtp configs/c.1

# Start the umtprd service
/usr/sbin/umtprd &

sleep 1

# enable the usb functions
echo $USB_PORT > UDC

echo bye
