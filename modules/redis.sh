#!/bin/sh

#If there is no 'WORKINGDIR' variable on line 4, setup.sh must be run first
IPFILE=$WORKINGDIR/redis-ips.txt
TMP=$WORKINGDIR/redis-tmp.txt
SCANRESULTS=$WORKINGDIR/redis-scanresults.txt
EXCLUDE=$WORKINGDIR/exclude.txt
PORT=6379

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

  # Attempts to connect to server and query to see if a Redis server is running
  # If no response is received in 5 seconds, then the connection times out
  printf "INFO\n"| nc -w 5 $IP 6379 > $TMP

  # Outputs results to log files based on whether there's a responding Redis server at that IP
  # If a server responds with Redis version information then the address is noted as having an active server
  if [ -f $TMP ]
  then
      if grep 'redis_version' $TMP; then
          echo "POSITIVE MATCH: There is an accessible Redis server at $line" >> $WORKINGDIR/redis-positives.log
      else
          echo "NEGATIVE MATCH: There is no accessible Redis TFTP server at $line" >> $WORKINGDIR/redis-negatives.log
      fi
  else
      echo "$TMP is not readable or does not exist" >> $WORKINGDIR/redis-errors.log
  fi

done <&3 # Finishes reading IP and moves onto the next IP in $IPFILE until there are no more IPs left

# Cleans up temporary files
rm $TMP
rm $IPFILE
rm $SCANRESULTS

echo "Operation complete. Successful and Unsuccessful connection logs have been saved in: $WORKINGDIR/"
