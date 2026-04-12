#!/bin/bash
{
	# Import shaughvOS-Globals ---------------------------------------------------------------
	. /boot/shaughvos/func/shaughvos-globals
	readonly G_PROGRAM_NAME='shaughvOS-WiFi_Monitor'
	G_CHECK_ROOT_USER "$@"
	G_INIT
	# Import shaughvOS-Globals ---------------------------------------------------------------

	readonly ADAPTER=$(G_GET_NET -t wlan iface)
	[[ $ADAPTER ]] || { G_SHAUGHVOS-NOTIFY 1 'No WiFi adapter has been found. Exiting...'; exit 1; }
	[[ $TICKRATE =~ ^[1-9][0-9]*$ ]] || readonly TICKRATE=10
	GATEWAY=

	#-------------------------------------------------------------------------------------
	# Main
	#-------------------------------------------------------------------------------------
	G_SHAUGHVOS-NOTIFY 2 "Checking connection for $ADAPTER via ping to default gateway every $TICKRATE seconds"

	while G_SLEEP "$TICKRATE"
	do
		if [[ ! -e /sys/class/net/$ADAPTER ]]
		then
			G_SHAUGHVOS-NOTIFY 1 "WiFi adapter $ADAPTER has been unplugged. Exiting..."
			exit 1

		elif ! GATEWAY=$(G_GET_NET -i "$ADAPTER" gateway) || ! ping -nqc 1 -I "$ADAPTER" "$GATEWAY" &> /dev/null
		then
			G_SHAUGHVOS-NOTIFY 2 "Detected $ADAPTER connection loss. Reconnecting..."
			ifdown "$ADAPTER"
			G_SLEEP 1
			ifup "$ADAPTER"
			G_SHAUGHVOS-NOTIFY 0 'Completed'
		fi
	done

	exit 0
}
