#!/usr/bin/bash

# just verify the library can be sourced
source "$(dirname "$0")"/../tap.sh || exit 1
printf "1..1\n"
printf "ok 1 - source tap.sh\n"

# vim: ft=sh
