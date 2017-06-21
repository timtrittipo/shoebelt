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


