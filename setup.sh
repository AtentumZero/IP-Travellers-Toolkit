#!/bin/bash

# Script to take a user-defined path to the script's location on the system
# then adds it as a working directory variable to all modules

echo "Please enter the path to the Traveller's Toolkit directory..."
echo "e.g. /home/user/IP-Travellers-Toolkit (No leading / at end of path)"
read dir

TOOLKIT=$dir/toolkit.sh
TOOLKITTMP=$dir/results/toolkit-tmp.txt

# Adds variable into every .sh script in the Modules directory
# Reason for $f being deleted before a .tmp being renamed to $f
# is because $f cannot be overwritten with $f - it errors out
for f in $dir/modules/*.sh; do
	cat $f | sed '3a\WORKINGDIR='$dir'/results' > $f.tmp
	rm $f
	mv $f.tmp $f
done

# Defines MODULESDIR variable for toolkit.sh
cat $TOOLKIT | sed '3a\MODULESDIR='$dir'/modules' > $TOOLKITTMP
rm $TOOLKIT
mv $TOOLKITTMP $TOOLKIT

# The VNC script requires the WORKINGDIR to be where toolkit.sh is, so the
# below line removes #results from the path added by the above code
sed -e "s/results//g" -i $dir/modules/vnc.sh

# Python screenshot script needs a variable to be defined
cat $dir/modules/screenshot.py | sed "5a\IPFILE = '$dir/results/vnc-ips.txt'" > $dir/results/setup-tmp.txt
rm $dir/modules/screenshot.py
mv $dir/results/setup-tmp.txt $dir/modules/screenshot.py
