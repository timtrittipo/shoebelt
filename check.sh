#!/bin/bash

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
