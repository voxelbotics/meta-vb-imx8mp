#!/bin/sh

# Setup fastboot daemon.
# Parameters: <USB> <UTP#>

if [ $# -lt 2 ]; then
	echo "Not enough arhuments"
	echo "Usage: $0 <USB> <UTP#>"
	exit 1
fi

export PATH=/sbin:/bin:/usr/sbin:/usr/bin

# get parameters
USB_PORT=$1
UTP_NUM=$2

UDC_DIR=/sys/class/udc
CFG_DIR=/sys/kernel/config/usb_gadget/UUC_$USB_PORT

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

echo "Setting up UUC gadget at $USB_PORT..."

mkdir -p $CFG_DIR && cd $CFG_DIR
mkdir -p strings/0x409
mkdir -p configs/c.1
mkdir -p functions/ffs.utp$UTP_NUM

echo 0x066F > idVendor
echo 0x9BFF > idProduct

if [ -e /sys/devices/soc0/soc_uid ]; then
	cat /sys/devices/soc0/soc_uid > strings/0x409/serialnumber
elif [ -e /sys/devices/soc0/serial_number ]; then
	cat /sys/devices/soc0/serial_number > strings/0x409/serialnumber
else
	echo 0000000000000000 > strings/0x409/serialnumber
fi

echo "FSL i.MX Board" > strings/0x409/product
echo 5 > configs/c.1/MaxPower

echo 1 > os_desc/use
echo "MSFT100" > os_desc/qw_sign
echo 0x40 > os_desc/b_vendor_code

mkdir -p /dev/usb-utp$UTP_NUM
mount -t functionfs utp$UTP_NUM /dev/usb-utp$UTP_NUM

ln -sf functions/ffs.utp$UTP_NUM configs/c.1/
ln -sf configs/c.1 os_desc

mkdir functions/mass_storage.1
ln -sf functions/mass_storage.1 configs/c.1/
echo "/fat" > functions/mass_storage.1/lun.0/file

ufb /dev/usb-utp$UTP_NUM/ep0 &

echo run utp at /dev/usb-utp$UTP_NUM/ep0;
while [ ! -e /dev/usb-utp$UTP_NUM/ep1 ]; do
	echo "."
	sleep 1;
done

echo $USB_PORT > UDC

[ "$UTP_NUM" = "0" ] && UTP_DEV=/dev/utp || UTP_DEV=/dev/utp$UTP_NUM

uuc $UTP_DEV &

echo "Done"
