#!/usr/bin/env bash

#
#TITLE       : λ::template-sh
#DESCRIPTION : Template.
#AUTHOR      : John Murowaniecki <john@compilou.com.br>
#DATE        : 20170825
#VERSION     : 0.0-1
#USAGE       : bash template.sh or ./template.sh or ..
#

DEFAULT_ERROR_MESSAGE="Warning: ${Cb}$1${Cn} is an invalid command."

function help {
    # Show this content.

    success message $EMPTY

    $_e "
${Cb}λ${Cn}::template-sh

Usage: ${Cb}$0${Cn} [${Cb}help${Cn}|..] ..

Parameters:
"
    $_e $(cat $0 | \
        grep 'function ' -A1 | \
        awk -F-- '{print($1)}' | \
        sed -r 's/^fu''nction (.*) \{$/\\t\\'$Cb'\1\\'${Cn}'\\t/' | \
        sed -r 's/\s+# (.*)$/@ok\1/' | \
        grep '@ok' -B1 | \
        sed -e 's/\@ok//' | sed -e 's/--/\\n/' )

    success || fail "Something horrible happens."
}

function example {
    # Explains how documentation works
    #

    echo "I don't know what to do"
}

function foo {
    # Explains how documentation works
    #

    echo "I don't know what to do"
}


#
#
# Try not edit below this line ...............................................
#
# HELPERS
         confirmYesNo=
function confirmYesNo {
    Y=y; N=n
    if [ $# -gt 1 ]
    then case ${1^^} in
        -DY) Y=${Y^}; d=Y;;
        -DN) N=${N^}; d=N;;
        esac
        m=$2
    else
        m=$1
    fi
     $_e -n "$m ($Y/$N)? "
    read -n 1 m -r;c=${m^}
    case $c in
        Y|N) n=$c;;
          *) n=$d;;
    esac
    export confirmYesNo=$n;
}

function success {
    if [ "$1"  == "message" ]
    then   success_message="$2"; return 0; fi
    $_e "${success_message}"
    $_e && success_message=
}

function fail {
    $_e "$@" && exit -1
}

function functionExists {
    [ "$(typeset | grep "${1} ()" | awk '{print($1)}')" != "" ] && $_e YES
}

#
# DECORATION
COLORS=$(tput colors 2> /dev/null)
if [ $? = 0 ] && [ "$COLORS" -gt 2 ]; then
    Cn="\e[0m"
    Cb="\e[1m"
    Cd="\e[2m"
    Cg="\e[32m"
    Cr="\e[31m"
    Cy="\e[33m"
    Ci="\e[34m"
fi

function _x {
    $_e "\t${Cb}$1${Cn}\t$@"
}

#
# ALIAS TO COMMON RESOURCES
    _e='echo -e'

#
# FUNCTION CALLER
if [ ${#} -eq 0 ]
then help
else [ "$(functionExists "$1")" != "YES" ] \
        && help \
        && fail $DEFAULT_ERROR_MESSAGE

    "$@"
fi
