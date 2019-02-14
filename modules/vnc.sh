#!/bin/sh

#If there is no 'WORKINGDIR' variable on line 5, setup.sh must be run first
RESULTSDIR=$WORKINGDIR/results
IPFILE=$RESULTSDIR/vnc-ips.txt
TMP=$RESULTSDIR/vnc-tmp.txt
SCANRESULTS=$RESULTSDIR/vnc-scan.txt
PORT=5900

echo "Please enter an IP address or range to scan..."
read IP

# Scans specified IP address(es) and outputs  to a file
sudo masscan -p$PORT $IP >> $SCANRESULTS

# Reads $SCANRESULTS, extracts IP addresses only and outputs to a file
perl -lne 'print $& if /(\d+\.){3}\d+/' $SCANRESULTS > $IPFILE

# Cleans up temporary file
rm $SCANRESULTS

# Runs Python script to grab screenshots - no slash needed between variable & script name
python $WORKINGDIR/modules/screenshot.py
