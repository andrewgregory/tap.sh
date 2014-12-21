# Copyright 2014 Andrew Gregory <andrew.gregory.8@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#
# Project URL: http://github.com/andrewgregory/tap.sh

declare -i tap_planned=0 tap_run=0 tap_failed=0 tap_passed=0
declare tap_todo=''

tap_plan() {
    tap_planned=$1;
    printf "1..%d\n" "$tap_planned"
}

tap_done_testing() {
    tap_plan $tap_run
}

tap_skip_all() {
    printf "1..0 # SKIP"
    _tap_print_reason " " "$@"
    printf "\n"
}

tap_diag() {
    printf "# "
    printf -- "$@"
    printf "\n"
}

tap_bail() {
    printf "Bail out!"
    _tap_print_reason " " "$@"
    printf "\n"
}

tap_finish() {
    (( tap_planned != tap_run )) && tap_diag "Looks like you planned %d tests but ran %d." $tap_planned $tap_run
    (( tap_planned == tap_run && tap_failed == 0 ))
}

tap_skip() {
    local -i count="$1"; shift
    while (( count-- )); do
        (( tap_run++ ))
        printf "ok %d # SKIP" "$tap_run"
        _tap_print_reason " " "$@"
        printf "\n"
    done
}

_tap_print_reason() {
    local sep="$1"; shift
    if [[ $# -gt 0 ]]; then
        printf "%s" "$sep"
        printf -- "$@"
    fi
}

tap_ok() {
    local ok="$1"; shift
    (( tap_run++ ))
    if [[ $ok -eq 0 ]]; then
        (( tap_passed++ ))
        printf "ok %d" "$tap_run"
    else
        (( tap_failed++ ))
        printf "not ok %d" "$tap_run"
    fi
    _tap_print_reason " - " "$@"
    if [[ -n $tap_todo ]]; then
        printf " # TODO %s" "$tap_todo"
    fi
    printf "\n"
    if [[ $ok -ne 0 ]]; then
        # TODO: there must be a less horrible way to do this
        local call ret line func file
        local -i i=0

        call=$(caller $i)
        ret=$?
        read line func file <<<"$call"
        while [[ $ret -eq 0 && ${file##*/} == 'tap.sh' ]]; do
            (( i++ ))
            call=$(caller $i)
            ret=$?
            read line func file <<<"$call"
        done

        if [[ $ret -eq 0 ]]; then
            file=${file##*/}
            if [[ -n $tap_todo ]]; then
                tap_diag "  Failed (TODO) test at %s line %d." "${file}" "$line"
            else
                tap_diag "  Failed test at %s line %d." "${file}" "$line"
            fi
        fi
    fi
    return $ok
}

tap_is_str() {
    local got="$1" expected="$2"; shift 2
    [[ $got == $expected ]]
    local ret=$?
    if ! tap_ok $ret "$@"; then
        tap_diag "         got: '%s'" "$got"
        tap_diag "    expected: '%s'" "$expected"
    fi
    return $ret
}

tap_is_int() {
    local got="$1" expected="$2"; shift 2
    [[ $got -eq $expected ]]
    local ret=$?
    if ! tap_ok $ret "$@"; then
        tap_diag "         got: '%s'" "$got"
        tap_diag "    expected: '%s'" "$expected"
    fi
    return $ret
}

tap_diff() {
    local got="$1" expected="$2"; shift 2
    local output ret
    output="$(diff -u --label got --label expected "$got" "$expected")"
    ret=$?
    if ! tap_ok $ret "$@"; then
        while IFS= read line; do
            tap_diag "$line"
        done <<<"$output"
    fi
    return $ret
}

tap_diff_str() {
    local got="$1" expected="$2"; shift 2
    local output ret
    output="$(diff -u --label got --label expected <(echo "$got") <(echo "$expected"))"
    ret=$?
    if ! tap_ok $ret "$@"; then
        while IFS= read line; do
            tap_diag "$line"
        done <<<"$output"
    fi
    return $ret
}

# vim: ft=sh
