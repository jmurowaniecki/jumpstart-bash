#
# λ::Makefile v1.0
# ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
#
# Para mais informações de uso consulte documentação no repositório:
#
define λ 2> /dev/null
RGB=
rgb=
case ${TERM} in
  xterm-color|*-256color)
    RGB="\033[1m"
	rgb="\033[0m"
esac
SELF=Makefile
LINE=$(cat  "${SELF}" | grep -n    -m1 'λ 2'   | awk -F':' '{print($1)}')
HEAD=$(cat  "${SELF}" | head -n"$((LINE - 1))" | sed -E 's/#(.*)/\1/')
HELP=$(cat  "${SELF}" | grep   '.*\:.* # '''   | sed -E 's/([a-z_\ ]{1,7})\:.*#(.*)/\t\'"${RGB}"'\1\'"${rgb}"'\t\2/')
OPTS=$(echo "${HELP}" | tail -n"$(($(echo "${HELP}" | wc -l) - 1))")
echo "${HEAD}\n\t${RGB}$(git config --get remote.origin.url)${rgb}\n\n\n Listagem de opções:\n\n${OPTS}\n"
exit 0
endef

PLATFORM = Linux
ifeq (Darwin, $(findstring Darwin, $(shell uname -a)))
PLATFORM = OSX
endif

rgb   = "\\033[0m"
RGB   = "\\033[1m"
Rgb   = "\\033[31m"
rGb   = "\\033[32m"
rgB   = "\\033[34m"
FAIL  = "$(Rgb)x$(rgb)"
PASS  = "$(rGb)*$(rgb)"
PRINT = echo "\n"

OPTIONS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
ifneq "$(OPTIONS)" ""
$(eval $(OPTIONS):;@:)
endif

.DEFAULT: help

help: # Exibe esta ajuda dos comandos.
	@sh Makefile

 : #  ###################################################################### \r
