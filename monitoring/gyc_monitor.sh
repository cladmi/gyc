#!/bin/sh

##################
# Configuration
##################

destination="____MAIL___DESTINATION____"
mailer="/usr/sbin/sendmail -t"
gyc="git --git-dir=____BARE____REPOSITORY____ --work-tree=____WORK____TREE____"



##################
# Check status
##################
$gyc status | grep "^\# Changes" > /dev/null
if [ "x$?" == "x$0" ]; then
    echo Nothing changes
    exit 1
else
    ###########################################
    # Warning: something change in gyc
    # Send mail with files and change
    ###########################################
    echo "Reply-to: <$(whoami)@$(hostname)>" > /tmp/gyc_monitor_mail
    echo "To: $destination" >> /tmp/gyc_monitor_mail
    echo "From: gycmonitor@$(hostname)" >> /tmp/gyc_monitor_mail
    echo "Subject: Gyc Alert $(date)" >> /tmp/gyc_monitor_mail
    echo "Content-type: text/plain" >> /tmp/gyc_monitor_mail
    $gyc status >> /tmp/gyc_monitor_mail
    echo -e "\n###############################################\n" >> /tmp/gyc_monitor_mail
    $gyc diff >> /tmp/gyc_monitor_mail

    $mailer < /tmp/gyc_monitor_mail
    rm /tmp/gyc_monitor_mail
fi
