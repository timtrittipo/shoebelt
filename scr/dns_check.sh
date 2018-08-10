#!/bin/bash

echo "pid is $$"
trap 'echo caught $?; exit' SIGINT EXIT SIGQUIT SIGILL SIGTRAP SIGABRT SIGBUS SIGTERM

case "$OSTYPE" in
  solaris*) echo "SOLARIS" ;;
  darwin*)  echo "OSX" ;;
  linux*)   echo "LINUX" ;;
  bsd*)     echo "BSD" ;;
  msys*)    echo "WINDOWS" ;;
  *)        echo "unknown: $OSTYPE" ;;
esac


# set dig args
TYPE="ANY"
digArgs="+timeout=2 +tries=1 +nofail +nocmd +nostats +nocomments +nottl +answer +noadditional "
  #-4 +noauthority +noqr

usage(){
  echo "  $0 file_with_dns_servers-onePerLine file_with_hostnames-onePerLine"
  echo "     defaults to reading files named 'servers' and 'hosts' in $PWD"
  exit 1
}

#shellcheck disable=2046,2206
function timer() # use 'unique-timer-name=$(timer)' at start and 'showtimer $unique-timer-name at end
{                # ie: timedb=$(timer); command you want timed; showtimer $timedb;
    if [[ $# -eq 0 ]]; then
        echo $(date "+%s")
    else
        local stime=$1; etime=$(date '+%s');
        if [[ -z "$stime" ]]; then stime=$etime; fi
        dt=$((etime - stime)); ds=$((dt % 60)); dm=$(((dt / 60) % 60)); dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}

function showtimer()
{
printf '\t\t\t ---- Elapsed time: %s\n' "$(timer $1) ----"
}

msg(){
  echo -e "  ..........................................................................."
  showtimer $eT
  echo -e "  ..........................................................................."
  echo -e "  > $* "
  echo -e "  ***************************************************************************"
}

serverInfo(){
  n=1
  for i in $serverList; do
    echo -e "\n * Server $n : $i"
    dig -x ${i} ${digArgs}  | egrep '\WA\W|PTR|CNAME' | grep -v ';'|sort
    let $(( n++ ))
  done
}

testDNS(){
  eT=$(timer)
  n=1
  msg "DNS servers being tested: \n $(serverInfo)"
  msg "testing these names: $hostList \n for record type: $TYPE"

  for i in $serverList; do

    # msg "Server $n : $i ANY"
    # dig @${i} ${digArgs} -f ${hosts} -t $TYPE | egrep -v '^;|root.net|root-servers.net' |sort -u | column -t
    # DEBUG+=( "$(echo;dig @${i} ${digArgs} -f ${hosts} -t $TYPE;echo)" )

    # msg "Server $n : $i ANY (without recursion)"
    # dig @${i} ${digArgs} +norecurse -f ${hosts} -t $TYPE | egrep -v ';|root.net|root-servers.net' | sort -u | column -t

    msg "Server $n : $i NS"
    dig @${i} ${digArgs} -f ${hosts} -t NS
    DEBUG+=( "$(echo;dig @${i} ${digArgs} -f ${hosts} -t NS;echo)" )
    msg "Server $n : $i NS (without recursion)"
    dig @${i} ${digArgs} +norecurse -f ${hosts} -t NS | egrep -v ';|root.net|root-servers.net' | sort -u | column -t
    DEBUG+=( "$(echo;dig @${i} +norecurse ${digArgs} -f ${hosts} -t NS;echo)" )
    let $(( n++ ))cd
  done
}

hosts="${2:-${PWD}/hosts}"
servers="${1:-${PWD}/servers}"

if [ ! -f ${servers} ] || [ ! -f ${hosts} ]; then
  usage
fi

serverList=$(egrep -v '#' ${servers}  | tr '\n' ' ' )
hostList=$(egrep -v '#' ${hosts} | tr '\n' ' ' )

time testDNS
msg end
msg debug
msg "${DEBUG[*]}" |  sort
