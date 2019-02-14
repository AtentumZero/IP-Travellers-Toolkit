#!/bin/bash

#If there is no 'MODULESDIR' variable on line 4, setup.sh must be run first
PS3='Please enter your choice: '
options=("VNC" "TFTP" "MongoDB" "Elasticsearch" "Redis" "Emby" "WordPress" "Help" "Quit")

echo "**************************************************************"
echo "* The IP Traveller's Tookit                                  *"
echo "*                                                            *"
echo "* A series of scripts for finding Internet-facing servers.   *"
echo "* For more information, see the 'Help' command.              *"
echo "**************************************************************"

select opt in "${options[@]}"
do
    case $opt in
        "VNC")
            echo "Running VNC module..."
	    bash $MODULESDIR/vnc.sh
            break
	    ;;
        "TFTP")
            echo "Running TFTP module..."
	    bash $MODULESDIR/tftp.sh
	    break
            ;;
        "MongoDB")
            echo "Running MongoDB module..."
            bash $MODULESDIR/mongo.sh
            break
            ;;
        "Elasticsearch")
            echo "Running Elasticsearch module..."
            bash $MODULESDIR/elasticsearch.sh
            break
            ;;
        "Redis")
            echo "Running Redis module..."
            bash $MODULESDIR/redis.sh
            break
            ;;
        "Emby")
            echo "Running Emby module..."
	    bash $MODULESDIR/emby.sh
            break
	    ;;
       	"WordPress")
            echo "Running WordPress module..."
            bash $MODULESDIR/wordpress.sh
            break
            ;;
	"Help")
            echo "Running Help module..."
            cat $MODULESDIR/help.txt
	    ;;
        "Quit")
            break
            ;;
        *) echo "Error: Invalid module $REPLY specified.";;
    esac
done
