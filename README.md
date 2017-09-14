# Bash Template

Modelo padrão para scripts Bash.


## Entendendo a estrutura

### #! / Shebang

Declaração [padrão do interpretador do script](https://en.wikipedia.org/wiki/Shebang_(Unix)).

```bash
#!/usr/bin/env bash
```


### Cabeçalho / documentação

Deve indicar o nome do script, sua descrição/aplicação, seu(s) autor(es), informações de uso, onde/como obter mais informações, link para o repositório, etc.

```bash
#
# TITLE       : Template title.
# DESCRIPTION : Template description.
# AUTHOR      : Your Name <your@email>
# DATE        : 20170825
# VERSION     : 0.0-1
# USAGE       : bash template.sh or ./template.sh or ..
# REPOSITORY  : https://github.com/YOUR_USER/your_project
#
```


### Variáveis de identificação e versão

Utilize as variáveis de identificação e versão para rastrear funcionalidades e bugs de forma eficiente mantendo esses valores atualizados com as tags do seu versionador favorito [da forma que melhor lhe convir](http://semver.org/).

```bash
APP_TITLE="${Cb}λ${Cn} Template"
APP_MAJOR=0
APP_MINOR=0
APP_REVISION=0
APP_PATCH=0
APP_VERSION="${APP_MAJOR}.${APP_MINOR}.${APP_REVISION}-${APP_PATCH}"
```


### Área de desenvolvimento :rocket:

As funções abaixo exemplificam onde devem ficar e como devem ser documentadas as funções para que sejam exibidas adequadamente como opções pelo helper do script.

```bash
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
```

> Note que a variável `$_e` é utilizada como substituta ao comando `echo -e` como único propósito estético.


### Funções auxiliares

Define mensagem padrão de erro caso o parâmetro informado não seja um comando válido.
```bash
#
# Try not edit below this line # ----------------------------------------------

DEFAULT_ERROR_MESSAGE="Warning: ${Cb}$1${Cn} is an invalid command."
```


#### Interpretador de ajuda para parâmetros

Exibe ajuda dos parâmetros suportados pela aplicação.

```bash
function help {
    # Show this content.

    success message "${EMPTY}"

    $_e "
${APP_TITLE} v${APP_VERSION}

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
```
> Para que seus métodos tenham suas descrições exibidas corretamente inclua uma linha de comentário resumindo seu funcionamento logo abaixo da definição da função - como sugerido nos exemplos acima.


#### Capturar entrada / confirmações

```bash
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
```


#### Mensagem de sucesso e falha

```bash
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
```

> A função `fail` exibe mensagem de falha finalizando o script.


#### Verifica se determinada função existe no escopo da aplicação

```bash
function functionExists {
    [ "$(typeset | grep "${1} ()" | awk '{print($1)}')" != "" ] && $_e YES
}
```


#### Declaração de Cores

As cores são armazenadas em variáveis, após verificar se o terminal no qual este script é executado suporta seu uso.

```bash
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
```

> Caso o terminal/emulador não suporte a utilização de cores, as variáveis não serão declaradas.

#### Eu queria muito lembrar do motivo de ter feito isso

Sério, não faço ideia.

```bash
function _x {
    $_e "\t${Cb}$1${Cn}\t$*"
}
```

> Mas mesmo assim vou deixar - vai que seja útil pra alguém (ou no futuro).


#### Apelidos para comandos e métodos

```bash
#
# ALIAS TO COMMON RESOURCES
    _e='echo -e'
```

#### Verifica se o parâmetro informado é uma função válida

```bash
#
# FUNCTION CALLER
if [ ${#} -eq 0 ]
then help
else [ "$(functionExists "$1")" != "YES" ] \
        && help \
        && fail "${DEFAULT_ERROR_MESSAGE}"

    "$@"
fi
```

---

## Dicas

- Garanta a qualidade do seu código seguindo padrões de codificação, [validando o mesmo utilizando ferramentas adequadas](https://github.com/koalaman/shellcheck) e [adotando](https://google.github.io/styleguide/shell.xml) [boas](https://github.com/bahamas10/bash-style-guide) [práticas](https://devmanual.gentoo.org/tools-reference/bash/) ([bônus](https://github.com/bahamas10/bash-style-guide));


## TODO

- Implementar `traps`;
- Traduções;
- Tutorial de uso;
- Automatizar atualização dos valores de versão e assinatura de distribuição;
- Melhorar o `confirmYesNo`;

---


# License and terms of use

The author is not liable for misuse and/or damage caused by free use and/or distribution of this tool.

## <div style="text-align:center">The MIT License (MIT)</div>

### <div style="text-align:center">Copyright © 2017 λ::lambda, CompilouIT, John Murowaniecki.</div>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
