#!/bin/sh
export PATH=/sbin:/bin:/usr/sbin:/usr/bin

cmdline=`cat /proc/cmdline`

# disable turn off display
#echo -e "\033[9;0]" > /dev/tty0

UDC_DIR=/sys/class/udc

function launch_uuc() {
	echo $1 $2
	mkdir /sys/kernel/config/usb_gadget/$1
	cd /sys/kernel/config/usb_gadget/$1
	echo 0x066F > idVendor
	echo 0x9BFF > idProduct

	mkdir strings/0x409

	if [ -e /sys/devices/soc0/soc_uid ]; then
		cat /sys/devices/soc0/soc_uid > strings/0x409/serialnumber
	else
		echo 0000000000000000 > strings/0x409/serialnumber
	fi

	echo "FSL i.MX Board" > strings/0x409/product
	mkdir configs/c.1
	echo 5 > configs/c.1/MaxPower

	echo ffs.utp$2

	echo 1 > os_desc/use
	echo "MSFT100" > os_desc/qw_sign
	echo 0x40 > os_desc/b_vendor_code

	mkdir functions/ffs.utp$2
	mkdir /dev/usb-utp$2
	mount -t functionfs utp$2 /dev/usb-utp$2
	ln -s functions/ffs.utp$2 configs/c.1/
	ln -s configs/c.1 os_desc

	mkdir functions/mass_storage.1
	ln -s functions/mass_storage.1 configs/c.1/
	echo "/fat" > functions/mass_storage.1/lun.0/file

	ufb /dev/usb-utp$2/ep0 &

	echo run utp at /dev/usb-utp$2/ep0;
	while [ ! -e /dev/usb-utp$2/ep1 ]
	do
		echo "."
		sleep 1;
	done

	echo $1 > UDC

	if [ $2 == "0" ]; then
		echo uuc /dev/utp
		uuc /dev/utp &
	else
		echo uuc /dev/utp$2
		uuc /dev/utp$2 &
	fi

	return 0;

}

function launch_mtp() {
    mkdir /sys/kernel/config/usb_gadget/g1
    cd /sys/kernel/config/usb_gadget/g1

    mkdir configs/c.1

    mkdir functions/ffs.mtp

    mkdir strings/0x409
    mkdir configs/c.1/strings/0x409

    echo 0x0100 > idProduct
    echo 0x1D6B > idVendor

    cat /sys/devices/soc0/serial > strings/0x409/serialnumber

    echo "VoxelBotics" > strings/0x409/manufacturer
    echo "Navq+" > strings/0x409/product

    echo "Conf 1" > configs/c.1/strings/0x409/configuration
    echo 120 > configs/c.1/MaxPower

    mkdir /dev/ffs-mtp
    mount -t functionfs mtp /dev/ffs-mtp
    ln -s functions/ffs.mtp configs/c.1

    # Start the umtprd service
    /usr/sbin/umtprd &

    cd ../..

    sleep 1

    # enable the usb functions
    ls /sys/class/udc/ > usb_gadget/g1/UDC
}

# Enable gadget mode, ignore error if it's already a gadget.
echo device > /sys/kernel/debug/usb/38100000.usb/mode || true

if echo $cmdline | grep mfgboot - > /dev/null; then
	entry=$(ls -A $UDC_DIR)
	launch_uuc $entry 0
else
	echo "Booting from eMMC"
	launch_mtp
fi

echo bye
