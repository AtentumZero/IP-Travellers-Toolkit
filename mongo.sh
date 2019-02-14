#!/bin/sh

#If there is no 'WORKINGDIR' variable on line 4, setup.sh must be run first
WORKINGDIR=/home/sion/IP-Travellers-Toolkit/results
IPFILE=$WORKINGDIR/mongo-ips.txt
TMP=$WORKINGDIR/mongo-tmp.txt
SCANRESULTS=$WORKINGDIR/mongo-scanresults.txt
PORT=27017

echo "Please enter an IP address or range to scan..."
read IP

# Scans specified IP address(es) and outputs results to a file
sudo masscan -p$PORT $IP >> $SCANRESULTS

# Reads $SCANRESULTS, extracts IP addresses only and outputs to a file
perl -lne 'print $& if /(\d+\.){3}\d+/' $SCANRESULTS >> $IPFILE

# Required for while read line
exec 3<$IPFILE

# Ensures script is run in the working directory
cd $WORKINGDIR/

# Reads every IP address in $IPFILE and enters the below while do loop

while read line
  do

  # Attempts to connect to Mongo server 
 echo "show dbs\n" | mongo --host $IP > $TMP

  # Outputs results to log files based on whether there's a responding MongoDN server at that IP
  # If the server responds with local database information then it's marked as accessible
  if [ -f $TMP ]
  then
      if grep 'local' $TMP; then
          echo "POSITIVE MATCH: There is an accessible MongoDB server at $line" >> $WORKINGDIR/mongo-positives.log
      else
          echo "NEGATIVE MATCH: There is no accessible MongoDB server at $line" >> $WORKINGDIR/mongo-negatives.log
      fi
  else
      echo "$TMP is not readable or does not exist" >> $WORKINGDIR/mongo-errors.log
  fi

done <&3 # Finishes reading IP and moves onto the next IP in $IPFILE until there are no more IPs left

# Cleans up temporary files
rm $TMP
rm $IPFILE
rm $SCANRESULTS

echo "Operation complete. Successful and Unsuccessful connection logs have been saved in: $WORKINGDIR/"
