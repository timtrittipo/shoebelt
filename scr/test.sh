#!/bin/bash

set -o pipefail
TIMEFORMAT="stats: %3R sec, %1U usr, %1S sys, %P%% CPU" #stats: 0.017 sec, 0.0 usr, 0.0 sys, 57.40% CPU
if type -P time > /dev/null 2>&1; then
  tbin=$(which time > /dev/null 2>&1)
  time_frmt="--format='stats: e%e P%P S%S I%I O%O W%W %M,%t,%K'"
elif [[ `type -t time` == keyword ]]; then
  tbin='time'
fi

#shellcheck disable=SC2034
log_action=/tmp/action.log
log_debug=/tmp/debug.log

# Column to start "[  OK  ]" label in:
RES_COL=60
# terminal sequence to move to that column:
MC0="echo -en \\033[${RES_COL}G"
# Terminal sequence to set color to a 'success' (bright green):
SC0="echo -en \\033[1;32m"
# Terminal sequence to set color to a 'failure' (bright red):
SC1="echo -en \\033[1;31m"
# Terminal sequence to set color to a 'warning' (bright yellow):
SC2="echo -en \\033[1;33m"
# Terminal sequence to set color to a 'passed' (cyan):
SCC="echo -en \\033[1;36m"
# Terminal sequence to reset to the default color:
SC3="echo -en \\033[0;39m"

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#  --Functions--
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#  ---- helper Fucntions ----

function getTS(){         # returns date & time
  ts=$(date +"%Y%m%d_%H%M%S")
}
function dlog(){          # send to console and logfile
  getTS
  echo "$ts ${FUNCNAME[1]} :: $*" | tee -a $log_debug
}
function logaction(){     # send to the script event log
  getTS
  echo "$ts $1 " >> $log_action
}
function statsme(){       # times a process
   $tbin "$time_frmt" "$@"
}
function jsonValue(){
  KEY=$1
  num=$2                  # jsonValue - get $KEY field from $configFile
  awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}

function echo_success() {
    $MC0 ; echo -n "["
    $SC0 ; echo -n $"  OK  "
    $SC3 ; echo -n "]"; echo -ne "\r"
    return 0
}
function echo_failure() {
    $MC0 ; echo -n "["
    $SC1 ; echo -n $"FAILED"
    $SC3 ; echo -n "]"; echo -ne "\r"
    return 1
}
function echo_passed() {
    $MC0 ; echo -n "["
    $SCC ; echo -n $"PASSED"
    $SC3 ; echo -n "]"; echo -ne "\r"
    return 0
}
function echo_warn() {
    $MC0 ; echo -n "["
    $SC2 ; echo -n $" WARN "
    $SC3 ; echo -n "]"; echo -ne "\r"
    return 1
}
function action() { # Run some action. Log its output.
    local STRING rc
    STRING=$1
    echo -n "$STRING "
    shift
    "$@" && echo_success || echo_failure
    rc=$?
    echo
    return $rc
}

echo
echo_success
echo
echo_failure
echo
echo_passed
echo
echo_warn
echo

#function   title                  command
action     "This will show OK"     true
action     "This will show FAILED" false
