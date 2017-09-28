#!/usr/bin/env bash
#
# TITLE       : Template title.
# DESCRIPTION : Template description.
# AUTHOR      : Your Name <your@email>
# DATE        : 20170825
# VERSION     : 0.1.0-0
# USAGE       : bash template.sh or ./template.sh or ..
# REPOSITORY  : https://github.com/YOUR_USER/your_project
#
# -----------------------------------------------------------------------------
#
APP=$0
APP_PATH=$(pwd)
APP_TITLE="${Cb}λ${Cn} Template"
APP_MAJOR=0
APP_MINOR=1
APP_REVISION=0
APP_PATCH=0
APP_VERSION="${APP_MAJOR}.${APP_MINOR}.${APP_REVISION}-${APP_PATCH}"
APP_RECIPES=YES

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

function multi {
    # Try multi options (with helper)

    function one {
        #multi: Function one must return success
        success message "This returns success"

        [[ "$FAILURE" != "" ]] && fail "Fail message"

        success
    }

    function two {
        #multi: Function two must return success
        success message "This must return fail"

        fail "That will fail"

        success
    }

    # Ensure multilevel
    checkOptions "$@"
}

#
# Try not edit below this line # ----------------------------------------------

function show_header {
    title="${APP_TITLE} v${APP_VERSION}"
    $_e "\n\n$title\n$(printf "%${#title}s" |tr ' ' '-')\n"
}

SHORT=

function help {
    # Show this content.
    success message "${EMPTY}"
    filter=' '
    scope='0x99'

    [[ "$1"     != "" ]] && filter="$1: " && scope=${filter}
    [[ "$SHORT" == "" ]] && show_header && $_e "Usage: ${Cb}$0${Cn} $1 [${Cb}help${Cn}|..] ..

Parameters:
"
    commands=$(grep 'function ' -A1 < "${APP_PATH}/${APP}" | \
        awk -F-- '{print($1)}'  | \
        sed -r 's/fu''nction (.*) \{$/\1/' | \
        sed -r "s/\s+#${filter}(.*)$/@ok\1/g" | \
        grep '@ok' -B1 | \
        sed -e 's/\@ok//' | \
        sed -e "s/${scope}//" )
    commands=$($_e "${commands}" | tr '\n' '\ ' | sed -e 's/--/\n/g')

    function parseThis {
        method=$1;shift
        $_e "${space}${Cb}${method}${Cn}$(fill "$method")${space}$($_e "$@")"
    }

    n=1
    max_size=0
    space=$(fill four)

    while read -r line
    do  size=$(strlen "$($_e "$line" | awk '{print($1)}')")
        [[ $size -gt $max_size ]] && max_size=$size
    done <<< "$commands"

    # shellcheck disable=SC2086
    while read -r line
    do parseThis $line
    done <<< "$commands"

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

function strlen {
    $_e ${#1}
}

function str_repeat {
    printf '%*s' "$1" | tr ' ' "$2"
}

function fill {
    str_repeat $((max_size - ${#1})) ' '
}

function functionExists {
    name="^${1} ()"
    [[ $(typeset | grep "$name" | awk '{print($1)}') != '' ]] && $_e YES
}

#
#
function autocomplete {
    SHORT=on;Cn=;Cb=;Cd=;Ci=;Cr=;Cg=;Cy=;Cc=
    $_e "$(help "$1" | awk '{print($1)}')"
}

function install {
    # Installs autocomplete features (need sudo).
    success message "Autocomplete instalado com sucesso. Reinicialize o terminal para que as mudanças façam efeito."

    function _autocomplete_Template {
        local curr prev

        curr="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        APP='%APP%'

        [[ "${prev}" == "$APP" ]] && prev=;

        options=$($APP autocomplete ${prev})
        COMPREPLY=( $(compgen -W "${options}" -- "${curr}"))
        return 0
    }

    clean=$($_e "$APP" | sed -r 's/([a-z0-9A-Z]*).*$/\1/')
    target="/etc/bash_completion.d/$APP"

    [[ $UID -eq 0 ]] &&  $_e "Configuring autocomplete.." && \
        $_e "$(declare -f _autocomplete_Template)
            \ncomplete -F _autocomplete_Template %APP%" | \
                sed -e "s/%APP%/\.\/${APP}/" | \
                sed -e "s/_Template/${clean}/" > "$target" && \
                source "$target" && \
                success
}

function checkOptions {
    [[ "$APP_RECIPES" == "YES" ]] && search_for_recipes
    if [ ${#} -eq 0 ]
    then help "$__$*"
    else [ "$(functionExists "$1")" != "YES" ] \
            && help \
            && fail "Warning: ${Cb}$1${Cn} is an invalid command."
        [[ "${__}" == "" ]] && __="$1"
        "$@"
    fi
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

function search_for_recipes {
    APP=$($_e "/$APP" | sed -r 's/.*\/(.*)$/\1/')
    if [   -e ".$APP/recipes.bash" ]
    then src  ".$APP/recipes.bash"
        APP_RECIPES="$(pwd)/.$APP/recipes.bash"
        cd ${APP_PATH}
        return
    fi
    case "$1" in
        wow)  R=so;;
        so)   R=many;;
        many) R=levels;;
        levels)
            cd ${APP_PATH}
            APP_RECIPES=NO
            return
            ;;
        *) R=wow;;
    esac
    cd ..
    search_for_recipes $R
}

function src {

    # shellcheck disable=SC1090
    source "$1"
}

#
# ALIAS TO COMMON RESOURCES
    _e='echo -e'
    __=

#
# FUNCTION CALLER
checkOptions "$@"
