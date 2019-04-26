# IP-Travellers-Toolkit

Find servers running services/applications known to be running without authentication and/or with common vulnerabilities.

![Alt text](/screenshot.png)

The IP Traveller's Toolkit is a collection of Shell and Python scripts that allows you to a scan a single IP address, range or the entire Internet for servers running a particular type of service or application. 

The services featured in the Toolkit are all known to have very common vulnerabilities associated with them - some do not have authentication setup by default (e.g. MongoDB) and others are known to be rife with vulnerabilities unless regularly patched (e.g. WordPress).

Rob Graham's excellent Masscan TCP port scanner is used to scan the Internet/IP ranges for servers on a particular port, each script then performs some kind of test to identify whether that server is running the applciation/server it's looking for. Results are then outputted to Positive and Negative log files.

This is primarily designed for use on Linux, although all scripts should run on macOS, BSD(Free/Open/Net/Dragonfly) and Solaris if you add the path to applications into the script (e.g. change all instances of 'masscan' in each script to '/usr/local/etc/masscan' for it to work on FreeBSD).

This Toolkit is designed for use in performing risk assessments, Internet vulnerability research and red-team penetration testing excercises.

## Wiki:

* [Modules](https://github.com/apacketofsweets/IP-Travellers-Toolkit/wiki/Modules)
* [Requirements](https://github.com/apacketofsweets/IP-Travellers-Toolkit/wiki/Requirements)
* [Instructions for use](https://github.com/apacketofsweets/IP-Travellers-Toolkit/wiki/Instructions-for-use)
* [Disclaimer](https://github.com/apacketofsweets/IP-Travellers-Toolkit/wiki/Disclaimer)
