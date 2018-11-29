#!/usr/bin/env bash
#
# TITLE       : Jump Start Bash Boilerplate.
# DESCRIPTION : .
# AUTHOR      : John Murowaniecki <john@compilou.com.br>
# DATE        : 20170825
# VERSION     : 0.1.0-1 silly package
# USAGE       : bash jumpstart.sh or ./jumpstart.sh or ..
# REPOSITORY  : https://github.com/jmurowaniecki/jumpstart
# -------------------------------------------------------------------
#
# General/global application variables
APP=${0/[\$\.\/]*\//}
APP_PATH=$(pwd)                     # Although can be $(dirname "$0")
APP_TITLE="${Cb}λ${Cn} Jumpstart"
APP_RECIPES=${RECIPES:-YES}

DEBUG=${DEBUG:-false}

# Semantic versioning
APP_VERSION_MAJOR=0
APP_VERSION_MINOR=1
APP_VERSION_BUILD=0
APP_VERSION_REVISION=1
APP_VERSION_CODENAME=silly
APP_VERSION_NICKNAME=package

function example {
    # Explains how documentation works

    $_e "I don't know what to do"
}

function colors {
    # Show color/style variable table

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
#       AVOID change above the safety line.
#
# -------------------------------------------------- SAFETY LINE ----

function show_header {
    TITLE="${Cb}${APP_TITLE}${Cn} v$(version print)"
    LABEL=$($_e -E "${TITLE}" | sed 's/\\[\e0-9]*\[[0-9;]*\m//g')

    $_e "\n\n$TITLE\n$(printf "%${#LABEL}s" | tr ' ' '-')\n"
}

function version {
    # Semantic versioning tool.

    function print {
        #version: Prints semantic version.

        TEXT="${APP_VERSION_MAJOR}"
        NICK="${APP_VERSION_CODENAME}"

        for O in \
            $APP_VERSION_MINOR \
            $APP_VERSION_BUILD
        do  [ ! -z "${O}" ] && \
            TEXT+=".${O}"
        done

        [ ! -z "${APP_VERSION_REVISION}" ] && TEXT+="-${APP_VERSION_REVISION}"
        [ ! -z "${APP_VERSION_NICKNAME}" ] && NICK+=" ${APP_VERSION_NICKNAME}"

        if ! there '--no-nick' in "$@" && \
            [[ ! -z "${NICK}" ]]; then
            TEXT+=" '${NICK}'"
        fi

        $_e "${TEXT}"
    }

    function check {
        #version: Check if current version matches last (actual) GIT tag.
        require versioning

        VERSION=$(version print --no-nick)
        GIT_TAG=$(git tag -l)

        success message "Não existe nenhuma TAG para a versão ${Cb}${VERSION}${Cn}."

        there "${VERSION}" in "${GIT_TAG}" && \
            fail "A versão ${Cb}${VERSION}${Cn} já possui tag versionada."

        success
    }

    function init {
        #version: Start semantic versioning.
        require versioning

        # check if there are some versioning data;
        # check if there aren't inconsistency;
        # check git history and propose versioning (check for existent tags);

        # check for release file

        declare -a OPTIONS
        OPTIONS=(target major minor build revision codename nickname)
        OPTION=0

        IS_DIRECTORY=
        VERSION_LETTER=v
        OVERIDE_VERSION=

        TARGET_PROJECT='./'      # targeted project folder or script
        TARGET_VERSION='VERSION' # targeted VERSION file

        GENERATE_TAG=YES
        GENERATE_RELEASE=YES

        if [[ $# -gt 0 ]]
        then    for     option   in "$@"
            do  case "${option}" in
                    --version-file=*   ) TARGET_VERSION="${option/--version-file=/}" ;;
                    --no-v|--no-letter*) VERSION_LETTER=        ;;
                    --no-tag           ) GENERATE_TAG=false     ;;
                    --no-release       ) GENERATE_RELEASE=false ;;
                    *)
                    NEED=true

                    while $NEED
                    do  ARG=${OPTIONS[$OPTION]}
                        OPTION=$((OPTION + 1))

                        case  $ARG in
                            target)       TARGET_PROJECT="${option}"
                            if [[ ! -d "${TARGET_PROJECT}" ]]
                            then
                                TARGET_PROJECT='./'
                                NEED=true
                                continue
                            fi
                            ;;

                            major)    TARGET_MAJOR="${option}"
                            if $_e "${TARGET_MAJOR}" | grep -q '.'
                            then declare -a \
                                SEMANTIC_VERSIONING_STRUCTURE
                                SEMANTIC_VERSIONING_STRUCTURE=(TARGET_MAJOR TARGET_MINOR TARGET_BUILD TARGET_REVISION)

                                POS=1
                                TARGET_TMP=$(sed -E 's/[v\.\:]*([0-9]*)[\.|\-]([0-9]*)[\.|\-|rc|a|b]*([0-9]*)[\.|\-|b|a|r|c]*([0-9]*)/\1 \2 \3 \4/' <<< "${TARGET_MAJOR}")

                                for SEM in "${SEMANTIC_VERSIONING_STRUCTURE[@]}"
                                do  VAL=$($_e "${TARGET_TMP}" | awk '{print($'${POS}')}')
                                    POS=$((POS + 1))
                                    export "${SEM}"="${VAL/-/}"
                                done
                                OPTION=$((OPTION + 3))
                                OVERIDE_VERSION=true
                            fi
                            ;;
                            minor   ) TARGET_MINOR="${option}";;
                            build   ) TARGET_BUILD="${option}";;
                            revision) TARGET_REVISION="${option}";;
                            codename) TARGET_CODENAME="${option}";;
                            nickname) TARGET_NICKNAME="${option}";;
                        esac
                        NEED=false
                    done
                esac
                $_e "$option ${ARG}"
            done
        fi

        TARGET_MAJOR=$(cat "$APP" | grep -e '# VERSION.*:' | head -n 1)

        declare -a \
        SEMANTIC_VERSIONING_STRUCTURE
        SEMANTIC_VERSIONING_STRUCTURE=(TARGET_MAJOR TARGET_MINOR TARGET_BUILD TARGET_REVISION TARGET_CODENAME TARGET_NICKNAME)

        POS=1
        TARGET_TMP=$(sed -E 's/[v|\ |\.|\:|\#A-Z]*([0-9]*)[\.|\-]([0-9]*)[\.|\-|rc|a|b]*([0-9]*)[\.|\-|b|a|r|c]*([0-9]*)/\1 \2 \3 \4/' <<< "${TARGET_MAJOR/.*\:/}")

        for SEM in "${SEMANTIC_VERSIONING_STRUCTURE[@]}"
        do  VAL=$($_e "${TARGET_TMP}" | awk '{print($'${POS}')}')
            POS=$((POS + 1))
            export "${SEM}"="${VAL/-/}"
        done

        $_e "checking for $0 where $* turns to
        git tag '${VERSION_LETTER}${TARGET_MAJOR}.${TARGET_MINOR}.${TARGET_BUILD}-${TARGET_REVISION}' -m '${TARGET_CODENAME} ${TARGET_NICKNAME}'
"
    }

    checkOptions "$@"
}

function bash4 {
    [[ ! "${BASH_VERSINFO[0]}" -lt 4 ]]
}

function versioning {
    require git

    git status > /dev/null 2>&1
}

function there {
    SOMETHING=
    COLLECTION=

    for argument in SOMETHING IN COLLECTION
    do export $argument="$1"; shift
    done

    $_e "${COLLECTION[@]}" | grep -q "\\$SOMETHING"
}

function require {
    for required in "$@"
    do  binary='' \
        method='' \
        return=true

        binary=$(which "${required}")

        # Verificar a possibilidade de validação com `command -v` sem perda do
        # propósito da validação do retorno.
        if [ ! -n "$binary" ]; then
            method=$(set|grep "${required} ()")
            return=$(${required} && ($_e true))
        fi

        $DEBUG "require b:${binary} m:${method} r:${return}"

        [[   !   -n  "${binary}" ]] && \
        [[ 'true' != "${return}" ]] && \
            fail "${Cb}${required}${Cn} required as a binary or defined function."
    done
}

#
# A tip for those who want some `try .. catch` we strongly suggest: DON`T,
# but if you really we're here to help.
#
# [1] https://www.biostars.org/p/300840/
# [2] https://stackoverflow.com/questions/1378274/in-a-bash-script-how-can-i-exit-the-entire-script-if-a-certain-condition-occurs/25515370#25515370
#
function yell { $_e "$0: $*" >&2; }
function die  { yell "$*"; exit 111; }
function try  { "$@" || die "${Cr}>${Cn} Error: $*"; }


SHORT=

declare -a commands
commands=()

function help {
    # Show this content.
    success message "${EMPTY}"
    filter='\ '

    [[ "$1"     != "" ]] && filter="$1: "
    [[ "$SHORT" == "" ]] && show_header && $_e "Usage: ${Cb}$0${Cn} $1 [${Cb}help${Cn}|..] ..

Parameters:
"
    scope=$filter

    function parse_help {
        content="$1"

        [ ! -e "$content" ] && content=$(which "$APP" | which "./$APP")
        [ ! -d "$content" ] || return 0

        list=$(grep 'fun''ction ' -A1 < "$content" | \
            awk -F-- '{print($1)}'  | \
            $_sed 's/fu''nction (.*) \{$/\1/' | \
            $_sed "s/.+#${filter}(.*)$/@ok\1/g" | \
            grep '@ok' -B1 | \
            $_sed 's/\@ok//' | \
            $_sed "s/^${scope}//" | tr '\n' '\ ' | $_sed 's/-- /\\n/g')

        OIFS="$IFS"
        IFS=$'\n' temporary=(${list//\\n/$'\n'})
        IFS="$OIFS"

        for command in "${temporary[@]}"
        do  commands[  "${#commands[@]}"  ]="$command"
        done
    }

    function fill {
        size=${#1}
        str_repeat $((max_size - size)) ' '
    }

    function parseThis {
        [[ "$1" == "" ]] && return
        method="$1";shift
        $_e "${space}${Cb}${method}${Cn}$(fill "$method")${space}${*}"
    }

    parse_help

    if  [[ "NO"  != "${APP_RECIPES}" ]] && \
        [[ "YES" != "${APP_RECIPES}" ]] && \
        [[    -e    "${APP_RECIPES}" ]]; then
        for info in "${APP_RECIPES}"/*
        do parse_help "${info}"
        done
    fi

    max_size=0
    space=$(fill four)

    for command in "${commands[@]}"
    do  size=$(strlen "$($_e "$command" | awk '{print($1)}')")
    [[ $size -gt $max_size ]] && max_size=$size
    done

    for line in "${commands[@]}"
    do
        # shellcheck disable=SC2086
        parseThis $line
    done

    # check for custom_help
    more_info=$(custom_help 2> /dev/null)

    if [[ -n "$more_info" ]]
    then
        oldCb=$Cb
        oldCn=$Cn
        Cn=$oldCn$Cd
        Cb=$oldCn; $_e "\nExtended help:${Cn}\n\n$more_info"
        Cn=$oldCn
        Cb=$oldCb
    fi

    success || fail 'Something terrible happens.'
}

#
# HELPERS
#
# TODO:
#   Utilizar códigos de retorno (0, 1, ..)
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
    eval "$d=\\${Cb}$d\\${Cn}"
    option="($Y/$N)? "
    $_e -n "$m ${option}"
    read -n 1 -r m; c=${m^}
    case $c in
        Y|N) n=$c;;
          *) n=$d;;
    esac
    $_e
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
#  when  success.
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

function config {
    # Configure application.

    function install {
        #config: Installs autocomplete features (need sudo).
        success message "Autocomplete instalado com sucesso.

        Reinicialize o terminal para que as mudanças façam efeito.

        Você pode utilizar o comando \`${Cb}reset${Cn}\` para realizar esse processo."

        function _autocomplete_Template {
            local curr prev

            curr="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[COMP_CWORD-1]}"
            APP='%APP%'

            [[ "${prev}" ==   "$APP" ]] && prev=;
            [[ "${prev}" == "./$APP" ]] && prev=;

            options=$($APP autocomplete ${prev})
            COMPREPLY=( $(compgen -W "${options}" -- "${curr}"))
            return 0
        }

        [[ $UID -eq 0 ]] || fail "${Cb}Atenção${Cn}: é necessário executar esse procedimento com privilégios de administrador."

        clean=$($_e "$APP" | $_sed 's/([a-z0-9A-Z]*).*$/\1/')
        target="/etc/bash_completion.d/$APP"

        cp "$APP" "/bin/$APP"
        chmod +x  "/bin/$APP"
        $_e "$(declare -f _autocomplete_Template)\n\n" | \
            sed -e "s/%APP%/${APP}/" | \
            sed -e "s/_Template/${clean}/"  > "$target"

        for each in ${APP}
        do [[ $UID -eq 0 ]] && $_e "Configuring autocomplete.." && \
            $_e "complete -F _autocomplete_Template %APP%" | \
                sed -e "s/%APP%/${each}/" | \
                sed -e "s/_Template/${clean}/" >> "$target" && \
            src "$target" && \
            success
        done
    }

    checkOptions "$@"
}

function checkOptions {
    [[ "$APP_RECIPES" != "NO" ]] && search_for_recipes

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
# shellcheck disable=SC2181
if [ $? = 0 ] && [ "${COLORS}" -gt 2 ]; then
    # shellcheck disable=SC2034
    C="\033"
    Cn="$C[0m"  # normal/reset
    Cb="$C[1m"  # bold
    # shellcheck disable=SC2034
    Cd="$C[2m"  # dark/gray
    # shellcheck disable=SC2034
    Ci="$C[3m"  # italic
    # shellcheck disable=SC2034
    Cr="$C[31m" # red
    # shellcheck disable=SC2034
    Cg="$C[32m" # green
    # shellcheck disable=SC2034
    Cy="$C[33m" # yellow
    # shellcheck disable=SC2034
    Cc="$C[34m" # blue
fi

function search_for_recipes {
    RCP="$(pwd)/.$($_e "/$APP" | $_sed 's/.*\/(.*)$/\1/')"
    FSO=()
    for recipe in "$RCP"/*
    do  if  [ -e "$recipe" ]
        then src "$recipe"
            FSO+=($recipe)
            APP_RECIPES="$RCP"
        fi
    done

    [[ ${#FSO[@]} -gt 0 ]] && return

    case "$1" in
        wow)  i=so;;
        so)   i=many;;
        many) i=levels;;
        levels)
            cd "${APP_PATH}" || exit 1
            APP_RECIPES=NO
            return
            ;;
        *) i=wow;;
    esac
    cd ..
    search_for_recipes "$i"
}

function src {

    # shellcheck disable=SC1090
    source "$1"
}

#
# ALIAS TO COMMON RESOURCES
    max_size=
    _sed='sed -E'
    _e='echo -e'
    __=

#
# FUNCTION CALLER
checkOptions "$@"
