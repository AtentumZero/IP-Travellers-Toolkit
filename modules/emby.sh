#!/bin/sh

#If there is no 'WORKINGDIR' variable on line 4, setup.sh must be run first
IPFILE=$WORKINGDIR/emby-ips.txt
TMP=$WORKINGDIR/emby-tmp.txt
SCANRESULTS=$WORKINGDIR/emby-scanresults.txt
INDEXFILE=$WORKINGDIR/emby.html
EXCLUDE=$WORKINGDIR/exclude.txt
PORT=8096

echo "Please enter an IP address or range to scan..."
read IP

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

  # Removes previous Index files
  rm $INDEXFILE*

  # Attempts to download a web page from IP
  # Timeout (-T) is set to 5 seconds. wget does not retry a failed connection (-t option)
  wget -T 5 -t 1 http://$line:$PORT -O $INDEXFILE

  # Outputs wget results with 'emby' in the file to a temporary file
  cat $INDEXFILE | grep emby > $TMP

  # Outputs results to log files based on whether an Emby server is available at that IP
  if [ -f $TMP ]
  then
      if [ -s $TMP ]
      then
          echo "POSITIVE MATCH: There is an accessible Emby server at $line" >> $WORKINGDIR/emby-positives.log
      else
          echo "NEGATIVE MATCH: There is no accessible Emby server at $line" >> $WORKINGDIR/emby-negatives.log
      fi
  else
      echo "$TMP is not readable or does not exist" >> $WORKINGDIR/emby-errors.log
  fi

done <&3 # Finishes reading IP and moves onto the next IP in $IPFILE until there are no more IPs left

# Cleans up temporary files
rm $INDEXFILE
rm $TMP
rm $IPFILE
rm $SCANRESULTS

echo "Operation complete. Successful and Unsuccessful connection logs have been saved in: $WORKINGDIR/"
