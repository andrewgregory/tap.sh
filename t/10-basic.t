#!/usr/bin/bash

dir="$(dirname "$0")"
source "$dir/../tap.sh" || exit 1

runtest() {
    tap_plan 0
    tap_plan 1
    tap_plan 2

    tap_skip_all
    tap_skip_all "foo %s" "bar"

    tap_skip 0
    tap_skip 1 "foo %s" "bar"
    tap_skip 2

    tap_diag "foo"
    tap_diag "foo %s" "bar"

    tap_bail
    tap_bail "foo %s" "bar"

    tap_ok 1
    tap_ok 0
    tap_ok 1 "%s" "foo"
    tap_ok 0 "%s" "foo"

    tap_is_str "foo" "foo"
    tap_is_str "foo" "bar"
    tap_is_str "foo" "foo" "foo %s" "bar"
    tap_is_str "foo" "bar" "foo %s" "bar"
    tap_is_str "" ""
    tap_is_str "" "bar"

    tap_is_int 1 1
    tap_is_int 1 0 
    tap_is_int 1 1 "foo %s" "bar"
    tap_is_int 1 0 "foo %s" "bar"

    tap_diff <(printf "1\n2\n3\n") <(printf "1\n2\n3\n") "tap_diff"
    tap_diff <(printf "1\n2\n3\n") <(printf "3\n2\n1\n") "tap_diff"

    tap_like "foo"    "^\<(foo|bar)\>$"
    tap_like "bar"    "^\<(foo|bar)\>$"
    tap_like "foobar" "^\<(foo|bar)\>$"
    tap_like "foo"    "^\<(foo|bar)\>$" "foo %s" "bar"
    tap_like "bar"    "^\<(foo|bar)\>$" "foo %s" "bar"
    tap_like "foobar" "^\<(foo|bar)\>$" "foo %s" "bar"
    tap_like "" ""
    tap_like "" "^\<(foo|bar)\>"

    tap_done_testing
}

run() {
    runtest
    tap_todo="FOO TODO"
    runtest
}

output="$(diff -u --label got --label expected <(run 2>&1) "$dir/expected/10-basic.t.out")"
ret=$?

printf "1..1\n"
if [[ $ret -eq 0 ]]; then
    printf "ok 1\n"
    exit 0
else
    printf "not ok 1\n"
    sed -e 's/^/   # /' <<<"$output"
    exit 1
fi

# vim: ft=sh
