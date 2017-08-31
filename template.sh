#!/usr/bin/env bash
#
# TITLE       : Template title.
# DESCRIPTION : Template description.
# AUTHOR      : Your Name <your@email>
# DATE        : 20170825
# VERSION     : 0.0-1
# USAGE       : bash template.sh or ./template.sh or ..
#
# -----------------------------------------------------------------------------
#

function example {
    # Explains how documentation works
    #

    $_e "I don't know what to do"
}

function colors {
    # Show color/style variable table
    #
    $_e "Color/style variables:

    ${Cb}Cn${Cn}     ${Cn}Normal/reset${Cn}
    ${Cb}Cb${Cn}     ${Cb}Bold${Cn}
    ${Cb}Ci${Cn}     ${Ci}Italic${Cn}
    ${Cb}Cd${Cn}     ${Cd}Dark/gray${Cn}
    ${Cb}Cr${Cn}     ${Cr}Red${Cn}
    ${Cb}Cg${Cn}     ${Cg}Green${Cn}
    ${Cb}Cc${Cn}     ${Cc}Cian/Blue${Cn}
    ${Cb}Cy${Cn}     ${Cy}Yellow${Cn}"
}





#
# Try not edit below this line # ----------------------------------------------

DEFAULT_ERROR_MESSAGE="Warning: ${Cb}$1${Cn} is an invalid command."

function help {
    # Show this content.

    success message "${EMPTY}"

    $_e "
${Cb}λ${Cn}/template.sh

Usage: ${Cb}$0${Cn} [${Cb}help${Cn}|..] ..

Parameters:
"
    commands="$(grep 'function ' -A1 < "$0" | \
        awk -F-- '{print($1)}'  | \
        sed -r 's/fu''nction (.*) \{$/\\t\\'"${Cb}"'\1\\'"${Cn}"'\\t/' | \
        sed -r 's/\s+# (.*)$/@ok\1/' | \
        grep '@ok' -B1 | \
        sed -e 's/\@ok//')"
    $_e "${commands}" | tr '\n' '\ ' | sed -e 's/--/\n/g'

    success || fail 'Something terrible happens.'
}

#
# HELPERS
#
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
     option="($Y/$N)? "
     $_e -n "$m ${option}"
    read -n 1 m -r;c=${m^}
    case $c in
        Y|N) n=$c;;
          *) n=$d;;
    esac
    export confirmYesNo=$n;
}

#
# Hold a success message.
#
# Ex.:
#       success message "all commands executed"
#       command1
#       command2
#       command3 || fail "command 3 fail"
#       success
#
#  will execute command1, command2, command3 and print: "all commands executed"
#  when success.
function success {
    if [ "$1"  == "message" ]
    then   success_message="$2"; return 0; fi
    $_e "${success_message}"
    $_e && success_message=
}

#
# Trigger a failure message with exit.
#
# Ex.:
#       success message "all commands executed"
#       command1
#       command2
#       command3 || fail "command 3 fail"
#       success
#
#  will execute command1, command2, command3 and print: "command 3 fail"
#  when command 3 fails.
function fail {
    $_e "$@" && exit 1
}

function functionExists {
    [ "$(typeset | grep "${1} ()" | awk '{print($1)}')" != "" ] && $_e YES
}

#
# DECORATION
COLORS=$(tput colors 2> /dev/null)
if [ $? = 0 ] && [ "${COLORS}" -gt 2 ]; then
    Cn="\e[0m"  # normal/reset
    Cb="\e[1m"  # bold
    Cd="\e[2m"  # dark/gray
    Ci="\e[3m"  # italic
    Cr="\e[31m" # red
    Cg="\e[32m" # green
    Cy="\e[33m" # yellow
    Cc="\e[34m" # blue
fi

function _x {
    $_e "\t${Cb}$1${Cn}\t$*"
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
        && fail "${DEFAULT_ERROR_MESSAGE}"

    "$@"
fi