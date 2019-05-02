#!/usr/bin/env python
import socket
import os

# If there is no IPFILE variable below, run setup.sh first
TCP_PORT = 5900
CURRENT_INDEX = 0

# Connect to designated IP over port 5900
# If no authentication is required, a 1 is written to log file, and adds up incrementally
# A 0 is written to file if authentication is required or there is no detectable VNC instance

def get_security(TCP_IP):
    snapshot_flag = 0
    vnc_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    vnc_socket.settimeout(0.5)
    try:
        vnc_socket.connect(( TCP_IP,TCP_PORT ))
        RFB_VERSION = vnc_socket.recv(12)
        if "RFB" not in RFB_VERSION:
            return snapshot_flag
        vnc_socket.send(RFB_VERSION)
        num_of_auth = vnc_socket.recv(1)
        if not num_of_auth:
            return snapshot_flag
        for i in xrange(0,ord(num_of_auth)):
            if ord(vnc_socket.recv(1)) == 1:
                snapshot_flag = 1
            else:
                pass
        vnc_socket.shutdown(socket.SHUT_WR)
        vnc_socket.close()
    except socket.error:

        vnc_socket.close()
        pass
    except socket.timeout:
        vnc_socket.close()
        pass
    return snapshot_flag

# Read IP file and takes a screenshot for each IP where no authentication is required
# This script must be run from the workind directory in order for the below code to work

if __name__ == '__main__':
    print "Attempting screenshots..."
    with open(IPFILE) as file:
        for line in file:
	    ip_addr = line.strip('\n')
            vncsnap_flag = get_security(ip_addr)
            CURRENT_INDEX = CURRENT_INDEX + 1
            os.system("echo " + str(CURRENT_INDEX) + " > results/vnc-log.txt")
            if vncsnap_flag == 1:
                CMD = "timeout 60 vncsnapshot -allowblank " + ip_addr + ":0 " + ip_addr + ".jpg > /dev/null 2>&1"
                os.system(CMD)
            else:
                pass

print "Operation complete. Screenshots (if there are any) have been saved to working directory."
