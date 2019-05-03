#!/bin/sh

useage () { echo "Usage: $0 [on]/[off] ([array of VM names])."; echo "e.g.: $0 on PE1 PE2 or $0 off"; exit 1 ; }

[ $# -eq 0 ] && useage;

if [ $1 == "on" ]; then
	nstate=$1
	ostate="off"
elif [ $1 == "off" ]; then
	nstate=$1
	ostate="on"
else
	useage;
fi

shift;

vmids=`vim-cmd vmsvc/getallvms | awk '{print $1";"$2}' | grep -v "Vmid"`

for vms in $vmids; do
	vmid=`echo $vms | cut -d ";" -f 1`
	name=`echo $vms | cut -d ";" -f 2`
	powerstate=`vim-cmd vmsvc/power.getstate $vmid | grep "Power" | cut -d " " -f 2`
        if [ "$name" != "VMware" ] && [ "$powerstate" == "$ostate" ]; then
		if [ $# -eq 0 ]; then
			echo "Trying to power $nstate $name"
			state=`vim-cmd vmsvc/power.$nstate $vmid`
		else
			for var in $@; do
				if test "${name#*$var}" != "$name"; then
					echo "Trying to power $nstate $name"
					state=`vim-cmd vmsvc/power.$nstate $vmid`
				fi
			done
		fi
	fi
done
