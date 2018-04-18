#!/bin/bash

        # verbose ->> very (very!) old bootup look (prior to RHL-6.0?)
        # color ->> default bootup look
        # other ->> default bootup look without ANSI colors or positioning
        BOOTUP=color
        # Column to start "[  OK  ]" label in:
        RES_COL=60
        # terminal sequence to move to that column:
        MOVE_TO_COL="echo -en \\033[${RES_COL}G"
        # Terminal sequence to set color to a 'success' (bright green):
        SETCOLOR_SUCCESS="echo -en \\033[1;32m"
        # Terminal sequence to set color to a 'failure' (bright red):
        SETCOLOR_FAILURE="echo -en \\033[1;31m"
        # Terminal sequence to set color to a 'warning' (bright yellow):
        SETCOLOR_WARNING="echo -en \\033[1;33m"
        # Terminal sequence to reset to the default color:
        SETCOLOR_NORMAL="echo -en \\033[0;39m"

        # Verbosity of logging:
        LOGLEVEL=1
   
echo_success() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
    echo -n $"  OK  "
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 0
}

echo_success_b() {
    echo -n "["
    echo -n $"  OK  "
    echo -n "]"
    echo -ne "\r"
    return 0
}

echo_failure() {
    echo -n "["
    echo -n $"FAILED"
    echo -n "]"
    echo -ne "\r"
    return 0
}

# Log that something succeeded
success() {
    echo_success
    return 0
}

# Log that something failed
failure() {
    local rc=$?
    [ "$BOOTUP" != "verbose" -a -z "${LSB:-}" ] && echo_failure
    [ -x /bin/plymouth ] && /bin/plymouth --details
    return $rc
}

# Run some action. Log its output.
action() {
    local STRING rc

    STRING=$1
    echo -n "$STRING "
    shift
    "$@" && success $"$STRING" || failure $"$STRING"
    rc=$?
    echo
    return $rc
}

action "find 7 char hash" git rev-parse --short HEAD
exit
gitHash7=$(git rev-parse --short HEAD || :)                # $gitHash7 is a 7 char hash from git eg: a1b2c3d
gitTagExact=$(git describe --exact-match 2>/dev/null || :) # fatal: no tag exactly matches '010000000000000..'
gitTag=$(git describe --tags 2>/dev/null || :)             #1.1.2222-123-abcdef4

echo " -- "
printf "%-9s %-18s %-8s\n" gitHash7 tagExct tag
printf "%-9s %-18s %-8s\n" ${#gitHash7} ${#gitTagExact} ${#gitTag}
printf "%-9s %-18s %-8s\n" ${gitHash7} ${gitTagExact:-NA} ${gitTag}
echo " -- "

if [[ ${gitTag} =~ -[[:digit:]]-[[:alnum:]] ]]; then
  echo "commit after tag"
elif [[ ${gitTag} =~ ^[[:digit:]]+\.[[:digit:]]+\.[[:alpha:]]+\.[[:digit:]]+\.[[:digit:]]+$ ]]; then
  echo "good tag"
fi

if [[ "$1" ]]; then
  gitTag="${1}"
  [[ ${gitTag} =~ -[[:digit:]]-[[:alnum:]] ]] && echo "commit after tag"
  [[ ${gitTag} =~ ^[[:digit:]]+\.[[:digit:]]+\.[[:alpha:]]+\.[[:digit:]]+\.[[:digit:]]+$ ]] &&  echo "good tag"
  # [[ ${gitTag} =~ ^([[:digit:]]+\.){2}[[:alpha:]]+\.[[:digit:]]+\.[[:digit:]]+$ ]] &&  echo "good tag regex 2"
fi
