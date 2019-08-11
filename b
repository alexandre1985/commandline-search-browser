#!/bin/bash


# INTERNAL CHECKS AND VARIABLES
MKDIR=/usr/bin/mkdir # IMPORTANT! MKDIR executable command path (must be correctly set)
SED=/usr/bin/sed # IMPORTANT! SED executable command path (must be correctly set)
BASENAME=/usr/bin/basename # IMPORTANT! BASENAME executable command path (must be correctly set)

CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
SCRIPT_CONFIG_DIR=${CONFIG_HOME}/commandline-search-browser
CONFIG_FILE_MAIN=${SCRIPT_CONFIG_DIR}/vars-and-aliases.conf


sanitize_and_import_conf_file() {
	CFG_FILE=$1
	CFG_CONTENT=$(${SED} -r '/[^=]+=[^=]+/!d' $CFG_FILE | ${SED} -r 's/\s+=\s/=/g')
	eval "${CFG_CONTENT}"
}


${MKDIR} -p ${SCRIPT_CONFIG_DIR}

if [ ! -f ${CONFIG_FILE_MAIN} ]; then
	echo '# this variable has to be set, and match your internet browser terminal command
BROWSER_COMMAND=xdg-open  # can also be,for example, firefox or /usr/bin/firefox


# Alias of your browser search engine and corresponding search url

## to add the "search term" to the search url use the word %MYSEARCHTERM
## for example, for Google you can add the line:
##g="https://www.google.com/search?q=%MYSEARCHTERM"
## being "g" the google search engine alias
## and "https://www.google.com/search?q=%MYSEARCHTERM" the google search url that you want to use

## You may use an configured alias as the content of an alias variable
## For example google=g


# The Default Search Engine.
# The script has to have this variable (named default) set and uncommented. And this variable name ("default") must not be changed. Only he value of the "default" variable may be changed
default=s

# StartPage
s="https://www.startpage.com/do/dsearch?query=%MYSEARCHTERM"
startpage=s

# Google
g="https://www.google.com/search?q=%MYSEARCHTERM"
google=g

# DuckDuckGo
d="https://duckduckgo.com/?q=%MYSEARCHTERM"
duckduck=d

# Bing
b="https://www.bing.com/search?q=%MYSEARCHTERM"
bing=b

# Twitter
tw="https://twitter.com/search?q=%MYSEARCHTERM"
twitter=tw

# Wikipedia (en)
w="https://en.wikipedia.org/wiki/%MYSEARCHTERM"
wiki=w

# Cambridge Dictionary
en="https://dictionary.cambridge.org/search/english/direct/?q=%MYSEARCHTERM"
dic=en

# Arch Linux Wiki
arch="https://wiki.archlinux.org/index.php?search=%MYSEARCHTERM"

# Arch Linux Packages
pkg="https://www.archlinux.org/packages/?q=%MYSEARCHTERM"

# Arch Linux AUR
aur="https://aur.archlinux.org/packages/?O=0&K=%MYSEARCHTERM"

# Manjaro Linux Forum
m="https://forum.manjaro.org/search?q=%MYSEARCHTERM"
manjaro=m

# GitHub
gh="https://github.com/search?&ref=simplesearch&q=%MYSEARCHTERM"
github=gh

# The Pirate Bay
pirate="https://thepiratebay.org/search/%MYSEARCHTERM"
bay=pirate

# Google Translate
t="https://translate.google.com/?source=osdd#auto|auto|%MYSEARCHTERM"
translate=t

# Ebay
e="https://www.ebay.com/sch/i.html?&_nkw=%MYSEARCHTERM"
ebay=e

# Amazon.com
a="https://www.amazon.com/s?k=%MYSEARCHTERM"
amazon=a' > ${CONFIG_FILE_MAIN}
fi

sanitize_and_import_conf_file ${CONFIG_FILE_MAIN}


# FUNCTIONS


function is_shell_var_varname_set() {
	[ -v $1 ] && return 0 || return 1
}

function encode() {
	local length="${#1}"
	for (( i = 0; i < length; i++ )); do
		local c="${1:i:1}"
		case $c in
			[a-zA-Z0-9.~_-])
				printf "$c"
				;;
			*)
				printf '%%%02X' "'$c"
				;;
		esac
	done
}

function remove_first_word_of_string() {
	read first rest << EOF
	$(echo ${1})
EOF
	echo ${rest}
}

function print_help() {
	NAME=$(${BASENAME} $0)
	echo -e "Usage:\n  ${NAME} [--help|-h]\n  ${NAME} [search_engine_alias] <search term>\n\nThe ${NAME} search engine aliases are defined in the ${CONFIG_FILE_MAIN} file."
	exit 0
}


# PROCESSING LOGIC

# check if is to show help message
[ $1 = "--help" -o $1 = "-h" ] && print_help


# ARGUMENT
ARGUMENTS="${@}"


# CHECK IF USES A SEARCH ENGINE ALIAS

# check if the first argument corresponds to a script configured alias
# and if it doesnt use the default search engine (which corresponds to the alias name "default")

if ! is_shell_var_varname_set $1; then
	# set the default search engine
	SEARCH_ENGINE_ALIAS="default"

	# set the search term
	SEARCH_TERM="${ARGUMENTS}"
else
	# set the first argument as the search engine alias
	SEARCH_ENGINE_ALIAS=${ARGUMENTS%% *}
	
	# set the search term
	SEARCH_TERM=$(remove_first_word_of_string "${ARGUMENTS}")
fi

SEARCH_ENGINE_ARGUMENT=${SEARCH_ENGINE_ALIAS}

# while a search engine alias is another alias and try to find out the url
while is_shell_var_varname_set ${!SEARCH_ENGINE_ALIAS}; do
	SEARCH_ENGINE_ALIAS=${!SEARCH_ENGINE_ALIAS}
done

# encoding serach term
SEARCH_TERM_ENCODED=$(encode "${SEARCH_TERM}")

# target search engine url
SEARCH_ENGINE_ORIGINAL_URL="${!SEARCH_ENGINE_ALIAS}"

# produce the link to pass to BROWSER_COMMAND
SEARCH_URL="${SEARCH_ENGINE_ORIGINAL_URL//%MYSEARCHTERM/${SEARCH_TERM_ENCODED}}"


# do the action
echo "Search Info:
  search engine alias: \"${SEARCH_ENGINE_ARGUMENT}\"
  search phrase: \"${SEARCH_TERM}\""

${BROWSER_COMMAND} "${SEARCH_URL}" > /dev/null 2>&1

exit 0
