#!/bin/sh

##################
# Configuration
##################

destination="____MAIL___DESTINATION____"
repolocation="____BARE____REPOSITORY____"
worktree="____WORK____TREE____"
mailer="/usr/sbin/sendmail -t"
gyc="git --git-dir=$repolocation --work-tree=$worktree"
# Available value is text or html
output="html"

__gyc_status() {
    # Process gyc status output
    count=0
    $gyc status > /tmp/gyc_status
    while read line; do
        echo $line | grep "modified" > /dev/null
        if [ "x$?" == "x0" ]; then
            modified_file=$(readlink -f $(echo $line | sed -e "s|\#[ \t]*modified: |$(pwd)/|"))
            mf[$count]=$modified_file
            df[$count]=$($gyc diff "$modified_file")
            count=$(( $count + 1 ))
        fi
    done < /tmp/gyc_status
    rm /tmp/gyc_status


    # Generate mail
    if [ "x$output" == "xhtml" ]; then
        cat >> $1 <<EOF
<html>
    <head>
        <title>Gyc Alert</title>
        <style>
        .left {
            text-align: right;
        }
        </style>
    </head>
    <body>
        <h1>Gyc Report $(date +"%Y-%m-%d")</h1>
        <h2><a name="top">List of modified files:</a>            (${#mf[@]})</h2>
        <ul>
EOF
        for i in $(seq 0 $(( ${#mf[@]} - 1 )) ); do
            echo -e "            <li><a href='#${mf[$i]}'>${mf[$i]}</a></li>" >> $1
        done
        cat >> $1 <<EOF
        </ul>
        <br />
        <hr />
        <br />
EOF
        for i in $(seq 0 $(( ${#mf[@]} - 1 )) ); do
            echo "        <h3><a name=\"${mf[$i]}\">${mf[$i]}</a></li><h3>" >> $1
            echo "        <pre>" >> $1
            echo "${df[$i]}" >> $1
            echo "        </pre>" >> $1
            echo "        <br />" >> $1
            echo "        <div class='left'><a href='#top'>back to top</a></div>" >> $1
            echo "        <hr />" >> $1
            echo "        <br />" >> $1
        done
        cat >> $1 <<EOF
    </body>
</html>
EOF

    else
        echo "######################### GYC Report $(date +"%Y-%m-%d") ###########################" >> $1
        echo "" >> $1
        echo "" >> $1
        echo "---------------- Modified files (${#mf[@]}) ----------------------" >> $1
        echo "" >> $1
        echo "" >> $1



        for i in $(seq 0 $(( ${#mf[@]} - 1 )) ); do
            echo "-> ${mf[$i]}" >> $1
                echo "" >> $1
                echo "${df[$i]}" >> $1
                echo "" >> $1
                echo "" >> $1
        done

        echo "--------------------------------------------------------------------------------" >> $1
    fi
}

__build_mail_header() {
    echo "Reply-to: <do-not-reply@$(hostname)>" > $1
    echo "To: $destination" >> $1
    echo "From: gycmonitor@$(hostname)" >> $1
    echo "Subject: Gyc Alert $(date)" >> $1
    if [ "x$output" == "xhtml" ]; then
        echo "Content-type: text/html" >> $1
    else
        echo "Content-type: text/plain" >> $1
    fi
}

##################
# Check status
##################
$gyc status | grep "^\# Changes" > /dev/null
if [ "x$?" == "x1" ]; then
    echo Nothing changes
    exit 1
else
    ###########################################
    # Warning: something change in gyc
    # Send mail with files and change
    ###########################################
    tmp_mail="/tmp/gyc_monitor_mail"

    __build_mail_header $tmp_mail
    __gyc_status $tmp_mail
    cat $tmp_mail
    $mailer < /tmp/gyc_monitor_mail
    rm $tmp_mail
fi
