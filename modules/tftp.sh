#!/bin/sh

#If there is no 'WORKINGDIR' variable on line 4, setup.sh must be run first
IPFILE=$WORKINGDIR/tftp-ips.txt
TMP=$WORKINGDIR/tftp-tmp.txt
SCANRESULTS=$WORKINGDIR/tftp-scanresults.txt
EXCLUDE=$WORKINGDIR/exclude.txt
PORT=69

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

  # Attempts to connect to TFTP server and pull a random file 'asd23e32412esASd'
  printf "connect\n%s\nstatus\nget asd23e32412esASd\nquit\n" "$line"| tftp > $TMP

  # Outputs results to log files based on whether there's a responding TFTP server at that IP
  # If a TFTP server responds stating file 'asd23e32412esASd' does not exist, then that IP is noted as having
  # a responding TFTP server at that address.
  if [ -f $TMP ]
  then
      if grep 'Error code 1' $TMP; then
          echo "POSITIVE MATCH: There is an accessible TFTP server at $line" >> $WORKINGDIR/tftp-positives.log
      else
          echo "NEGATIVE MATCH: There is no accessible TFTP server at $line" >> $WORKINGDIR/tftp-negatives.log
      fi
  else
      echo "$TMP is not readable or does not exist" >> $WORKINGDIR/tftp-errors.log
  fi

rm $WORKINGDIR/asd23e32412esASd

done <&3 # Finishes reading IP and moves onto the next IP in $IPFILE until there are no more IPs left

# Cleans up temporary files
rm $TMP
rm $IPFILE
rm $SCANRESULTS

echo "Operation complete. Successful and Unsuccessful connection logs have been saved in: $WORKINGDIR/"
