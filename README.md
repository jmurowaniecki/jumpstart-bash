# Jump Start Bash Template
[![StyleCI](https://styleci.io/repos/102001979/shield?branch=master)](https://styleci.io/repos/102001979) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/8c024327353741839413296650fe883f)](https://www.codacy.com/app/jmurowaniecki/jumpstart-bash?utm_source=github.com&utm_medium=referral&utm_content=jmurowaniecki/jumpstart-bash&utm_campaign=Badge_Grade)

**Jump Start** was concepted to be an easy and lightweight boilerplate for your tools using modularity to manage readability and producing a self-deployment solution. Although you can use `jumpstart` to handle self-contained tools, it can be used to manage multiple recipes in a _global_ environment.

Aiming to solve structural gaps due to some [classical language limitations](https://mywiki.wooledge.org/BashWeaknesses), allowing to perform autocompletion and generate documentation based initially on  function declarations source code annotations, **Jump Start** intent to be your weapon of choice to start from small sized projects to complex solutions.

[Bash is a really powerfull tool](https://www.tldp.org/LDP/abs/html/) and there are a lot of [online documentation](http://web.mit.edu/~linux/docs/howto/Adv-Bash-Scr-HOWTO), [good](https://github.com/bahamas10/bash-style-guide) [practices](https://devmanual.gentoo.org/tools-reference/bash/), [style guidance](https://google.github.io/styleguide/shell.xml), advices and tools for [validation, static analysis and linting](https://github.com/koalaman/shellcheck) to ensure code quality and maintainability.


## Getting start

### Instalation

### Compatibility check

### Hands on

#### Creating a small and self-contained application

#### Creating a complex and self-deployable solution

### Solving problems

## Structure

#### #! _(aka: Shebang)_

[Standart declaration of the program loader](https://en.wikipedia.org/wiki/Shebang_(Unix)) are commonly the first line of the executable file that specifies the interpreter and environmental parameters.

```bash
#!/usr/bin/env bash
```
> _Means that our script runs over Bash._


#### Document heading

Describes script name, description, usage, authors and how/where to get more information (repository links, and more).

```bash
#
# TITLE       : Template title.
# DESCRIPTION : Template description.
# AUTHOR      : Your Name <your@email>
# DATE        : 20170825
# VERSION     : 7.6.2-33
# USAGE       : bash template.sh or ./template.sh or ..
# REPOSITORY  : https://github.com/YOUR_USER/your_project
#
```

#### Versioning

Use the ID and version variables to efficiently and efficiently track features and bugs by keeping those values up to date with your favorite versioner's tags [in the way that suits you best](http://semver.org/).

```bash
APP_TITLE="${Cb}λ${Cn} Template"

APP_MAJOR=0
APP_MINOR=0
APP_REVISION=0
APP_PATCH=0
#
#   AVOID change above the safety line.
#
# --------------------------------------- SAFETY LINE -------------
APP_VERSION="${APP_MAJOR}.${APP_MINOR}.${APP_REVISION}-${APP_PATCH}"
```


#### Development area _(fun zone)_

The functions below exemplify where to stay and how to document the functions so that they are properly displayed as options by the script helper.

```bash
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
```

> Note that the `$_e` variable is used as a substitute for the `echo -e` command as a sole aesthetic purpose.


#### Auxiliary functions

Sets the default error message if the parameter entered is not a valid command.
```bash
#
#   AVOID change above the safety line.
#
# --------------------------------------- SAFETY LINE -------------
DEFAULT_ERROR_MESSAGE="Warning: ${Cb}$1${Cn} is an invalid command."
```


##### Lazy helper

Displays help for supported application parameters.

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
> To have your method descriptions displayed correctly, include a comment line summarizing their operation just below the function definition - as suggested in the examples above.


##### Prompting Yes/No

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


##### Success and failure messages

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

> The use of `fail` shows a message quitting script.



##### Check if given parameter are a valid function inside the actual function scope

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

## TODO

-   [Implement `traps`](http://redsymbol.net/articles/bash-exit-traps/);
-   Tutorials;
-   Autobuild increments version signature;
-   Improve function `confirmYesNo`;
-   Modularize README into a wiki or something like;
-   GIT versioning integration;

---

# License, warranties and terms of use

The author is not liable for misuse and/or damage caused by free use and/or distribution of this tool.

## <div style="text-align:center">The MIT License (MIT)</div>

### <div style="text-align:center">Copyright © 2017 λ::lambda, CompilouIT, John Murowaniecki.</div>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

_The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software._

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
