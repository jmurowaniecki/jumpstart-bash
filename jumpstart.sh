#!/usr/bin/env bash
#
# TITLE       : Jump Start Bash Boilerplate.
# DESCRIPTION : An easy and lightweight boilerplate for your tools.
# AUTHOR      : John Murowaniecki <john@compilou.com.br>
# DATE        : 20170825
# VERSION     : 0.1.0-4 gracious mistake
# USAGE       : bash jumpstart.sh or ./jumpstart.sh or …
# REPOSITORY  : https://github.com/jmurowaniecki/jumpstart
# -------------------------------------------------------------------
#
# <GENERAL hash="300315eeab1b8dc5bcffbf6ca6640775"> // General/global application variables
APP_TITLE="${Cb}λ${Cn} Jumpstart"
APP_RECIPES=${RECIPES:-YES}
# </GENERAL>

# <VERSION hash="7f58df162ecf09365ea4badb20ce311d"> // Semantic versioning.
APP_VERSION_MAJOR=0
APP_VERSION_MINOR=1
APP_VERSION_BUILD=0
APP_VERSION_REVISION=4
APP_VERSION_CODENAME=gracious
APP_VERSION_NICKNAME=mistake
# </VERSION>

example() {
    # Explains how documentation works

    $_e "I don't know what to do"
}

colors() {
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

multi() {
    # Try multi options (with helper)

    one() {
        #multi: Function one must return success
        success message "This returns success"

        [[ "$FAILURE" != "" ]] && fail "Fail message"
        success
    }

    two() {
        #multi: Function two must return success
        success message "This must return fail"

        fail "That will fail"

        success
    }

    # Ensure multilevel
    checkOptions "$@"
}


#
# -------------------------------------------------- SAFETY LINE ----
#          AVOID change above the safety line.
# <CORE hash="a98aa1223bfdf6f23c68e9ed8bd6cec9">
APP=${0/[\$\.\/]*\//}
APP_PATH=$(pwd)                     # Although can be $(dirname "$0")
DEBUG=${DEBUG:-false}
ENGINE=${ENGINE:-$(basename "$(which php || which python || which nodejs || which node)")}

show_header() {
    TITLE="${Cb}${APP_TITLE}${Cn} v$(version print)"
    LABEL=$($_e -E "${TITLE}" | sed 's/\\[\e0-9]*\[[0-9;]*\m//g')

    $_e "\n\n$TITLE\n$(printf "%${#LABEL}s" | tr ' ' '-')\n"
}

version() {
    # Semantic versioning tool.

    declare -a OPTIONS
    OPTIONS=(target major minor build revision codename nickname)
    OPTION=0

    VERSION_LETTER=v
    OVERIDE_VERSION=

    TARGET_PROJECT='./'      # targeted project folder or script
    TARGET_VERSION='VERSION' # targeted VERSION file

    GENERATE_TAG=YES
    GENERATE_RELEASE=YES

    print() {
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

        #print-option: --no-nick  Shows only semantic versioning.
        if ! there '--no-nick' in "$@" && \
            [[ ! -z "${NICK}" ]]; then
            TEXT+=" '${NICK}'"
        fi
        $_e "${TEXT}"
    }

    compare() {
        #version: Compare between <version1> and <version2>
        return
    }

    check() {
        #version: Check if current version matches last (actual) GIT tag.
        require versioning

        VERSION=$(version print --no-nick)
        GIT_TAG=$(git tag -l)

        success message "Não existe nenhuma TAG para a versão \"${VERSION}\"."

        there "${VERSION}" in "${GIT_TAG}" && \
            fail "A versão \"${VERSION}\" já possui tag versionada."

        success
    }

    release() {
        #version: Start/refresh semantic versioning.
        require versioning

        if [[ $# -gt 0 ]]
        then    for     option   in "$@"
            do  case "${option}" in

                    #release-option: --version-file= Filename with SemVer contents.
                    --version-file=*   ) TARGET_VERSION="${option/--version-file=/}" ;;

                    #release-option: --no-v,--no-letter Version using only numerals.
                    --no-v|--no-letter*) VERSION_LETTER=        ;;

                    #release-option: --no-tag Finish without generate a new tag.
                    --no-tag           ) GENERATE_TAG=false     ;;

                    #release-option: --no-release Finish without generate and publish a release.
                    --no-release       ) GENERATE_RELEASE=false ;;

                    *)     NEED=true
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

            export TARGET_VERSION
            export VERSION_LETTER
            export GENERATE_TAG
            export GENERATE_RELEASE
            export OVERIDE_VERSION
        fi

        # shellcheck disable=SC2002
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

        LAST_TAG=$(git tag --list --sort=tag | head -n 1)
        LAST_SUM=$(git show "${LAST_TAG}" | grep 'commit ' | awk '{print $2}')
        FULL_VER="${VERSION_LETTER}${TARGET_MAJOR}.${TARGET_MINOR}.${TARGET_BUILD}-${TARGET_REVISION}"

        $_e "## ${FULL_VER} ${TARGET_CODENAME} ${TARGET_NICKNAME}
Histórico de correções desde a versão **${LAST_TAG}** até a presente data ($(date +'%Y-%m-%d')):
$(git log --since="${LAST_SUM}" --oneline --pretty=format:'-   **%h**: %s')

" >> HISTORY.md

        declare -A UPDATEABLES=(
            [APP_VERSION_MAJOR]=$TARGET_MAJOR
            [APP_VERSION_MINOR]=$TARGET_MINOR
            [APP_VERSION_BUILD]=$TARGET_BUILD
            [APP_VERSION_REVISION]=$TARGET_REVISION
            [APP_VERSION_CODENAME]=$TARGET_CODENAME
            [APP_VERSION_NICKNAME]=$TARGET_NICKNAME
        )
        for target in "${!UPDATEABLES[@]}"
        do  # shellcheck disable=SC2002
            cat "${APP}" | sed -E "s/(${target}=)(.*)/\1${UPDATEABLES[$target]}/" > "${APP}~"
            cat "${APP}~" > "${APP}"
        done
        [ -e "${APP}~" ] && rm "${APP}~"

        PRINT "Checking for >$0< where last tag was \"${LAST_TAG}\" turns to:
        git tag \"${FULL_VER}\" -m \"${TARGET_CODENAME} ${TARGET_NICKNAME}\"
        "

        if [[ $GENERATE_TAG ]]
        then fail "Exit without generate tags from release."
        fi

        #version: Finish versioning closing the last release.
        for target in "${APP}" "HISTORY.md"
        do git commit "${target}" -m "Updating release to ${FULL_VER}"
        done
        git tag "${FULL_VER}" -a -m "${TARGET_CODENAME} ${TARGET_NICKNAME}"

        if [[ $GENERATE_RELEASE ]]
        then fail "Exit without publish releases."
        fi

        git push --tags
    }

    checkOptions "$@"
}

bash4() {
    [[ ! "${BASH_VERSINFO[0]}" -lt 4 ]]
}

versioning() {
    require git

    git status > /dev/null 2>&1
}

there() {
    SOMETHING=
    COLLECTION=

    for argument in SOMETHING IN COLLECTION
    do export $argument="$1"; shift
    done

    # shellcheck disable=SC2076
    [[ "${COLLECTION}" =~ "${SOMETHING}" ]] && return 0

    return 1
}

require() {
    for required in "$@"
    do  binary=$(which "${required}")
        return=true
        method=

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
yell() { $_e "$0: $*" >&2; }
die()  { yell "$*"; exit 111; }
try()  { "$@" || die "${Cr}>${Cn} Error: $*"; }


SHORT=${SHORT:-}

declare -a commands
commands=()

help() {
    # Show this content.
    success message "${EMPTY}"
    filter='\ '
    command="$1"

    if [[ "${command}"  == "" ]] \
    && [[ "${__}" == "${___}" ]]
    then     command="${___}"
        ___=
        __=
    fi

    suggestion=$(echo "${___} ${command}" | $_sed 's/\s(.*\s)/\1/')

    [[ "${___}"   == "" ]] && assume_help="[help … ]"
    [[ "$command" != "" ]] && filter="${command}"
    [[ "$SHORT"   == "" ]] && show_header && PRINT "Usage: $0 >${suggestion}< ${assume_help:-…}\n\n"
    scope=$filter

    parse_help() {
        content="$1"

        [ ! -e "$content" ] && content=$(which "$APP" | which "./$APP")
        [ ! -d "$content" ] || return 0

        list=$(grep '[funct''ion|]*(.*)\(''\) {' -A1 < "${content:-/dev/null}" | \
            awk -F-- '{print($1)}'  | \
            $_sed 's/(.*)\(\) \{$/\1/' | \
            $_sed "s/.+#${filter}: (.*)$/@ok\1/g" | \
            grep '@ok' -B1 | \
            $_sed 's/\@ok//' | \
            $_sed "s/^${scope}//" | tr '\n' '\ ' | $_sed 's/-- /\\n/g')

        args=$(grep "#${filter}-option:.*" < "${content:-/dev/null}" | \
            $_sed "s/.*#${filter}-option: (.*) (.*)$/\1 \2/g")

        OIFS="$IFS"
        IFS=$'\n' temporary=(${list//\\n/$'\n'})
        IFS="$OIFS"

        for command in "${temporary[@]}"
        do  commands[  "${#commands[@]}"  ]="$command"
        done

        IFS=$'\n' temporary=(${args//\\n/$'\n'})
        IFS="$OIFS"

        for command in "${temporary[@]}"
        do  description="$($_e "${command}" | $_sed 's/([-.,a-z0-9=]*)\ (.*)/\2/')"
            everyoption=($($_e "${command}" | awk '{print($1)}' | tr ',' ' '))
            for opt in "${everyoption[@]}"
            do  commands["${#commands[@]}"]="${opt} ${description}"
                description=
            done
            commands["${#commands[@]}"]="${commands[${#commands[@]}]}\r"
        done
    }

    fill() {
        size=${#1}
        str_repeat $((max_size - size)) ' '
    }

    parseThis() {
        [[ "$1" == "" ]] && return
        method="$1";shift
        PRINT "${space}${Cb}${method}${Cn}$(fill "$method")${space}${*}"
    }

    parse_help

    processed=

    if  [[ "NO"  != "${APP_RECIPES}" ]] && \
        [[ "YES" != "${APP_RECIPES}" ]] && \
        [[  0 -lt "${#FSO[@]}" ]]; then
        for O  in  "${FSO[@]}"
        do $_e "${processed[@]}" | grep "${O}" > /dev/null && continue

                parse_help "${O}"
                processed+="${O}\n"
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
confirmYesNo() {
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
success() {
    if [ "$1"  == "message" ]
    then     success_message="$2"; return 0; fi
    PRINT "${success_message}"
    PRINT && success_message=
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
fail() {
    PRINT "$@" && exit 1
}

strlen() {
    $_e ${#1}
}

str_repeat() {
    printf '%*s' "$1" | tr ' ' "$2"
}

functionExists() {
    name="^${1} ()"
    [[ $(typeset | grep "${name}" | awk '{print($1)}') != '' ]] && $_e YES
}

#
#
autocomplete() {
    SHORT=on;Cn= ;Cb= ;Cd= ;Ci= ;Cr= ;Cg= ;Cy= ;Cc=
    $_e "$(help "$1" | awk '{print($1)}')"
}

config() {
    # Configure application.

    install() {
        #config: Installs autocomplete features (need sudo).
        success message "Autocomplete instalado com sucesso.

        Reinicialize o terminal para que as mudanças façam efeito.

        Você pode utilizar o comando \`${Cb}reset${Cn}\` para realizar esse processo."

        _autocomplete_Template() {
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
        do [[ $UID -eq 0 ]] && $_e "Configuring autocomplete…" && \
            $_e "complete -F _autocomplete_Template %APP%" | \
                sed -e "s/%APP%/${each}/" | \
                sed -e "s/_Template/${clean}/" >> "$target" && \
            src "$target" && \
            success
        done
    }

    checkOptions "$@"
}

checkOptions() {
    [[ "$APP_RECIPES" != "NO" ]] && search_for_recipes

    if [ "${#}" -eq 0 ]
    then help "$__$*"
    else [ "$(functionExists "$1")" != "YES" ] \
            && help \
            && fail "Warning: \"$1\" is an invalid command."
        [[ "${__}" != "" ]] && ___="${__}"
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

    cOption="$C[0;2;3m"
fi

FSO=()


search_for_recipes() {
    [[  -d  "$1" ]] && \
        RCP="$1"    || \
        RCP="$(pwd)/.$($_e "/${APP}" | $_sed 's/.*\/(.*)$/\1/')"

    for recipe in "${RCP}"/*
    do  if   [ -d "${recipe}" ];then search_for_recipes "${recipe}"
        elif [ -e "${recipe}" ]
        then src  "${recipe}"
            there "${recipe}" in "${FSO[@]}" && continue
            FSO+=( ${recipe} )
        fi
    done

    [[ ${#FSO[@]} -gt 0 ]] && APP_RECIPES=LOADED && return

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

src() {

    # shellcheck disable=SC1090
    source "$1"
}

json() {
    encode() {
        INPUT="$*"
        [[ ! -n "${INPUT}" ]] && INPUT="$(cat /dev/stdin)"
        case "${ENGINE}" in
            python) python -c 'import sys, json; sys.stdout.write(json.dumps(json.loads(sys.stdin.read()), separators=(",", ":")))' <<< "${INPUT}" ;;
            php|*) php -r 'echo json_encode(json_decode(stream_get_contents(fopen("php://stdin", "r"))));' <<< "${INPUT}" ;;
        esac
    }

    # shellcheck disable=SC2120
    decode() {
        INPUT="$*"
        [[ ! -n "${INPUT}" ]] && INPUT="$(cat /dev/stdin)"
        case "${ENGINE}" in
            php|*) # shellcheck disable=SC2016
            php -r '$INPUT=stream_get_contents(fopen("php://stdin","r"));$INPUT=($INPUT[0]==="'"'"'"?substr($INPUT,1,-2):$INPUT);function R($S,$P="",$l=""){foreach($S as $n=>$v){if(is_array($v)||is_object($v)){R($v,"{$n}","{$P}");continue;}echo "[".(implode(".",array_filter([$l,$P,$n],function($v){return($v!=="");})))."]={$v}\n";}};R(json_decode($INPUT,true));' <<< "${INPUT}"
        esac
    }

    dynamic() {
        JSON="${4:-${3:-}}"
        NAME="${2:-${1:-}}"
        [[ ! -n "${JSON}" ]] && JSON="$(cat /dev/stdin)"

        LINE=

        while read -r line
        do  LINE=$((  LINE + 1  ))
            VARIABLE="$($_e "${line}" | sed -E 's/\[(.*)\]=(.*)/["\1"]="\2"/')"
            eval "${NAME}${VARIABLE}"
        done <<< "${JSON}"; # shellcheck disable=SC2163
        export   "${NAME}"
        $_e      "${NAME[@]}"
    }

    extract() {
        JSON=${3:-${2:-}}
        [[  !   -n  "${JSON}" ]] && JSON="$(cat /dev/stdin)"; # shellcheck disable=SC2119
        [[  ""  !=  "${JSON}" ]] && \
        [[ "''" !=  "${JSON}" ]] && \
        (decode <<< "${JSON}""""""" \
            | grep "\[${1}\]="""""  \
            | sed -E 's/.*=(.*)/\1/')
    }

    checkOptions "$@"
}

λ() {
    require md5sum grep sed

    declare -A SECTIONS=()
    declare -a WARNINGS=()
    declare -A HASHDATA=()

    read-sections() {
        [[ "$3" == "/" ]] \
            && SECTIONS[$2]+="$1" \
            || SECTIONS[$2]="${3:-__INVALID_HASH__} $1 "
    }

    calculate-hash() {
        SECTION=$1
        # shellcheck disable=SC2002
        HASH=( "$2"  "$(cat    "${APP}"    \
            | head  -n$(($4         - 1 )) \
            | tail  -n$(($4  -  $3  - 1 )) \
            | md5sum  |  awk '{print $1}')")
        if  [ "${HASH[0]}" != "${HASH[1]}" ]
        then HASHDATA["${SECTION}"]="${HASH[1]}"
            [[ "$SHORT" == "" ]] \
                && WARNINGS+=("Incorrect hash for \"${SECTION}\".\nThere's \"${HASH[0]}\", should have \"${HASH[1]}\".\n")\
                || WARNINGS+=("${SECTION}\t${HASH[0]}\t${HASH[1]}")
        fi
        export HASHDATA
    }

    extract-headers() {
        LINE=
        HEAD="${4:-${3:-}}"
        NAME="${2:-${1:-}}"
        [[ ! -n "${HEAD}" ]] && HEAD="$(cat /dev/stdin)"

        while read -r line
        do  LINE=$((  LINE + 1  ))
            if $_e "${line}" | grep -q '< .*: .*'
            then eval "${NAME}$($_e "${line}" | sed -E 's/< (.*): (.*)/["\1"]="\2"/' | sed -E 's/\r//')"
            fi
        done <<< "${HEAD}"
    }

    check-for-updates() {
        require curl awk sed base64

        declare -A ENDPOINTS=(\
            [TAGs]="https://api.github.com/repos/jmurowaniecki/jumpstart-bash/tags" \
        )

        declare -A TAGs=() HEADERS=()
        export TAGS HEADERS

        curl_headers=$(mktemp)
        curl_body=$(curl -s "${ENDPOINTS['TAGs']}" -vvv \
            2> "${curl_headers}")

        $_e    "${curl_body}" \
            | json decode \
            | json dynamic assert TAGs

        extract-headers \
            to HEADERS \
            from "$(cat "${curl_headers}")" \
                &&  rm  "${curl_headers}"

        case "${TAGs[message]}" in
            'API rate limit exceeded for'*)
            $_e "You have '${HEADERS[X-RateLimit-Remaining]}/${HEADERS[X-RateLimit-Limit]}' remaining requests. Try authenticate to get higher rate limit."
        esac

        # [
        #   {
        #     "name": "0.1.0-0",
        #     "zipball_url": "https://api.github.com/repos/jmurowaniecki/jumpstart-bash/zipball/0.1.0-0",
        #     "tarball_url": "https://api.github.com/repos/jmurowaniecki/jumpstart-bash/tarball/0.1.0-0",
        #     "commit": {
        #       "sha": "466f1d28845826970d6c8e51b6e2a284f73ebe1d",
        #       "url": "https://api.github.com/repos/jmurowaniecki/jumpstart-bash/commits/466f1d28845826970d6c8e51b6e2a284f73ebe1d"
        #     },
        #     "node_id": "MDM6UmVmMTAyMDAxOTc5OjAuMS4wLTA="
        #   }
        # ]

        target=$(mktemp)

        # https://api.github.com/repos/jmurowaniecki/jumpstart-bash/git/trees/466f1d28845826970d6c8e51b6e2a284f73ebe1d

        # {
        #   "sha": "466f1d28845826970d6c8e51b6e2a284f73ebe1d",
        #   "url": "https://api.github.com/repos/jmurowaniecki/jumpstart-bash/git/trees/466f1d28845826970d6c8e51b6e2a284f73ebe1d",
        #   "tree": [
        #     ...,
        #     {
        #       "path": "template.sh",
        #       "mode": "100755",
        #       "type": "blob",
        #       "sha": "3483e086ff93c0e4d140d975fb08833145d6b715",
        #       "size": 6730,
        #       "url": "https://api.github.com/repos/jmurowaniecki/jumpstart-bash/git/blobs/3483e086ff93c0e4d140d975fb08833145d6b715"
        #     }
        #   ],
        #   "truncated": false
        # }
        curl 'https://api.github.com/repos/jmurowaniecki/jumpstart-bash/git/blobs/3483e086ff93c0e4d140d975fb08833145d6b715' | \
            grep 'content' | \

        curl 'https://api.github.com/repos/jmurowaniecki/jumpstart-bash/git/blobs/3483e086ff93c0e4d140d975fb08833145d6b715' | \
            grep 'content' | \
            awk -F':' '{print substr($2, 3, length($2) - 4)}' | \
            sed -E 's/\\n/\n/g' | \
            base64 -d > "${target}"

        echo "Veja ${target}"
    }

    case "$1" in
        update) check-for-updates
            ;;

        fix)
            sectors="$(grep -n '# ''<[/A-Z]*.*>' "${APP}" \
                | sed  -E 's/([0-9]*):# ''<([/]*)([A-Z]*)(.*hash="(.*)")*>.*/\1\t\3\t\2\t\5/')"
            while read -r VALUE
            do  declare -a fields=(line name stop hash)
                line=
                name=
                stop=
                hash=
                FIELDS=(${VALUE})
                for var in "${!FIELDS[@]}"
                do  export "${fields[$var]}"="${FIELDS[$var]}"
                done
                read-sections "${line}" "${name}" "${stop}" "${hash}"
            done  <<< "${sectors}"

            for section in "${!SECTIONS[@]}"
            do  declare -a fields=(hash head tail)
                hash=
                head=
                tail=
                FIELDS=(${SECTIONS[${section}]})
                for var in "${!FIELDS[@]}"
                do  export "${fields[$var]}"="${FIELDS[$var]}"
                done
                calculate-hash "${section}" "${hash}" "${head}" "${tail}"
            done

            for section in "${!HASHDATA[@]}"
            do  target="$(mktemp)"
                # shellcheck disable=SC2002
                cat "${APP}" \
                    | sed -E 's/\# ''<'"${section}"'*.*>/\# ''<'"${section}"' hash''="'"${HASHDATA[$section]}"'">/' \
                    > "${target}"
                cat   "${target}" > "${APP}"
                rm -f "${target}"
                λ fix
                exit
            done
            ;;

        check|*)
            sectors="$(grep -n '# ''<[/A-Z]*.*>' "${APP}" | \
                sed  -E 's/([0-9]*):# ''<([/]*)([A-Z]*)(.*hash="(.*)")*>.*/\1\t\3\t\2\t\5/')"
            while read -r VALUE
            do  declare -a fields=(line name stop hash)
                line=
                name=
                stop=
                hash=
                FIELDS=(${VALUE})
                for var in "${!FIELDS[@]}"
                do  export "${fields[$var]}"="${FIELDS[$var]}"
                done
                read-sections "${line}" "${name}" "${stop}" "${hash}"
            done <<< "${sectors}"

            for section in "${!SECTIONS[@]}"
            do  declare -a fields=(hash head tail)
                hash=
                head=
                tail=
                FIELDS=(${SECTIONS[${section}]})
                for var in "${!FIELDS[@]}"
                do  export "${fields[$var]}"="${FIELDS[$var]}"
                done
                calculate-hash "${section}" "${hash}" "${head}" "${tail}"
            done

            if [ ${#WARNINGS[@]} -gt 0 ]
            then for warn in "${WARNINGS[@]}"
                do    PRINT  "${warn}"
                done; PRINT "These alerts may mean that you are using a modified or outdated version."\
                "\nTry to keep updated executing \`${0} λ update\`."
            fi
            ;;
    esac

}

PRINT() {

    content="$*" # @TODO: RTS
    content=$(echo "${content}" | sed -E "s/([.|]*\`)(.*)(\`)/\\${Cn}\\${Cb}\1\2\3\\${Cn}/g")
    content=$(echo "${content}" | sed -E "s/([.|]*\[)(.*)(\])/\\${Cn}\\${Cd}\1\2\3\\${Cn}/g")
    content=$(echo "${content}" | sed -E "s/([.|]*\()(.*)(\))/\\${Cn}\\${Cd}\1\2\3\\${Cn}/g")
    content=$(echo "${content}" | sed -E "s/([.|]*\{)(.*)(\})/\\${Cn}\\${Cd}\1\2\3\\${Cn}/g")
    content=$(echo "${content}" | sed -E "s/([.|]*\")(\w*\S*)(\"[|.]*)/\\${Cn}\\${Cb}\1\2\3\\${Cn}/g")
    content=$(echo "${content}" | sed -E "s/([.|]*<)(\w*\S*)(>)/\\${Cd}\1\\${Ci}\2\3\\${Cn}/")
    content=$(echo "${content}" | sed -E "s/([.|]*>)(.*)(<[|.]*)/\\${Cn}\\${Cb}\2\\${Cn}/g")

    $_e "${content}"
}

#
# ALIAS TO COMMON RESOURCES
    max_size=
    _sed='sed -E'
    _e='echo -e'
    __=
    ___=

#
# FUNCTION CALLER
checkOptions "$@"
# </CORE>
