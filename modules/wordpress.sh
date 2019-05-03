#!/bin/sh

#If there is no 'WORKINGDIR' variable on line 4, setup.sh must be run first
IPFILE=$WORKINGDIR/wordpress-ips.txt
TMP=$WORKINGDIR/wordpress-tmp.txt
SCANRESULTS=$WORKINGDIR/wordpress-scanresults.txt
INDEXFILE=$WORKINGDIR/wp-login.php
EXCLUDE=$WORKINGDIR/exclude.txt

echo "Please enter an IP address or range to scan..."
read IP

echo "Please enter the port to target (e.g. 80 & 443)..."
read PORT

echo "Please enter a packet-per-second rate to scan with... (Slow: 10pps, Fast: 10000pps)"
read RATE

# Scans specified IP address(es) and outputs  to a file
sudo masscan -p$PORT $IP --rate $RATE --excludefile $EXCLUDE >> $SCANRESULTS

# Reads $SCANRESULTS, extracts IP addresses only and outputs to a file
perl -lne 'print $& if /(\d+\.){3}\d+/' $SCANRESULTS >> $IPFILE

# Required for while read line
exec 3<$IPFILE

# Ensures script is run in the working directory
cd $WORKINGDIR/

# Reads every IP address in $IPFILE and enters the below while do loop

while read line
  do

  # Attempts to download a web page from IP - certificates ignored as we're communicated directly with IPs
  # Timeout (-T) is set to 5 seconds. wget does not retry a failed connection (-t option)
  wget -T 5 -t 1 --no-check-certificate $line/wp-login.php

  # Outputs wget results with 'Powered by WordPress' in the file to a temporary file
  grep "Powered by WordPress" $INDEXFILE > $TMP

  # Outputs results to log files based on whether a WordPress server is available at that IP
  if [ -f $TMP ]
  then
      if [ -s $TMP ]
      then
          echo "POSITIVE MATCH: There is an WordPress server at $line" >> $WORKINGDIR/wordpress-positives.log
      else
          echo "NEGATIVE MATCH: There is no WordPress server at $line" >> $WORKINGDIR/wordpress-negatives.log
      fi
  else
      echo "$TMP is not readable or does not exist" >> $WORKINGDIR/wordpress-errors.log
  fi
  
  rm $INDEXFILE
  rm $TMP

done <&3 # Finishes reading IP and moves onto the next IP in $IPFILE until there are no more IPs left

  # Cleans up temporary files
  rm $IPFILE
  rm $SCANRESULTS

echo "Operation complete. Successful and Unsuccessful connection logs have been saved in: $WORKINGDIR/"
