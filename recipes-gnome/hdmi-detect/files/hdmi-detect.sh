#!/bin/sh
# traverse HDMI links and look if any of them is connected

links=$(find /sys/class/drm -name card*-*)

for l in $links; do
	# skip if no status attribute
	[ -f $l/status ] || continue

	status=$(cat $l/status)

	# detected if status is connected
	[ "$status" = "connected" ] && exit 0
done

# no connected links found
exit 1
