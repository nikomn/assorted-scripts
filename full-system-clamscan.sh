#!/bin/bash

# nb. sudo needed for reading all files
# Whole script can be run as sudo, ie. sudo ./full-system-clamscan.sh
# If script is run without sudo you have to insert your password 
# at every command in the script that uses sudo, while script is running.

folder=$(pwd)
time=$(date +"%Y%m%d%H%M")
user=$SUDO_USER

if [ -n "${user}" ]; then
    echo "Script run as sudo..."
fi

if [ -z "${user}" ] && [ "${USER}" != "root" ]; then
    echo "Script run as normal user..."
    user=$USER
fi

if [ -z "${user}" ] && [ "${USER}" == "root" ]; then
    echo "Script run as root..."
    user=$USER
fi

echo "Running full system clamscan check."
echo "Log saved in file $folder/clamscanlog_$time.log"
echo ""
echo "This will take some time, please be patient..."
echo ""
echo ""

#echo "folder: $folder"
#echo "time: $time"
#echo "user: $user"

# create a trap to stop clamscan with Ctrl+C without stopping whole script
trap ' ' INT
sudo clamscan -r / -i --exclude-dir="^/sys" -l $folder/clamscanlog_$time.log 2> $folder/clamscan_errorlog_$time.log

# '-r /'                  == Scan recursively starting from root (/)
# '-i'                    == Print only filenames that are contaminated (if any)
# '--exclude-dir="^/sys"' == Skip /sys which is a virtual filesystem, that does not
#                            contain any real files. If not skipped it causes numerous
#                            file read error messages.


# Log files created by clamscan which might be run as sudo so
# log files not even readable by normal user.
# Change logfile ownership to normal user who ran the script.
sudo chown $user $folder/clamscanlog_$time.log
sudo chown $user $folder/clamscan_errorlog_$time.log

echo ""
echo "Done! Log files can be found at "
echo "$folder/clamscanlog_$time.log"
echo "and $folder/clamscan_errorlog_$time.log"

echo ""

