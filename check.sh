#!/bin/bash

gitHash7=$(git rev-parse --short HEAD || :)                # $gitHash7 is a 7 char hash from git eg: a1b2c3d
gitTagExact=$(git describe --exact-match 2>/dev/null || :) # fatal: no tag exactly matches '010000000000000..'
gitTag=$(git describe --tags 2>/dev/null || :)             #1.1.2222-123-abcdef4

echo "0 ${#gitHash7}"
echo "1 ${#gitTagExact}"
echo "2 ${#gitTag}"
echo "0 ${gitHash7}"
echo "1 ${gitTagExact}"
echo "2 ${gitTag}"

if [[ ${gitTag} =~ -[[:digit:]]-[[:alnum:]] ]]; then
  echo "commit after tag"
elif [[ ${gitTag} =~ ^[[:digit:]]+\.[[:digit:]]+\.[[:alpha:]]\.[[:digit:]]\.[[:digit:]]$ ]]; then
  echo "good tag"
  # 3.0.A.5.4, so that the regex [[:digit:]]+.[[:digit:]]+.[[:alpha:]]
fi

gitTag="${1}"
if [[ ${gitTag} =~ -[[:digit:]]-[[:alnum:]] ]]; then
  echo "commit after tag"
fi
[[ ${gitTag} =~ ^[[:digit:]]+\.[[:digit:]]+\.[[:alpha:]]+\.[[:digit:]]+\.[[:digit:]]+$ ]] &&  echo "good tag"
  # 3.0.A.5.4, so that the regex [[:digit:]]+.[[:digit:]]+.[[:alpha:]]
# [[ ${gitTag} =~ ^([[:digit:]]+\.){2}[[:alpha:]]+\.[[:digit:]]+\.[[:digit:]]+$ ]] &&  echo "good tag regex 2"
