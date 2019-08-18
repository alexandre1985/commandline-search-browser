#!/bin/bash


# VARIABLES

MKDIR=/usr/bin/mkdir # IMPORTANT! MKDIR executable command path (must be correctly set)
SED=/usr/bin/sed # IMPORTANT! SED executable command path (must be correctly set)
BASENAME=/usr/bin/basename # IMPORTANT! BASENAME executable command path (must be correctly set)
GREP=/usr/bin/grep # IMPORTANT! GREP executable command path (must be correctly set)

CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
SCRIPT_CONFIG_DIR=${CONFIG_HOME}/commandline-search-browser
CONFIG_FILE_MAIN=${SCRIPT_CONFIG_DIR}/vars-and-aliases.conf

ALIAS_VAR_PREFIX="CLSB_ALIAS_"


# FUNCTIONS

function write_original_config_file_to() {
	echo '# this variable has to be set, and match your internet browser terminal command
# can also be, for example, firefox or /usr/bin/firefox
BROWSER_COMMAND=xdg-open


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
t="https://translate.google.com/?source=osdd#view=home&op=translate&sl=auto&tl=${FUNC:-`show_if_else ${2} auto pt en es fr it`}&text=${FUNC:-`remove_first_word_if '%MYSEARCHTERM' pt en es fr it`}"
translate=t

# Ebay
e="https://www.ebay.com/sch/i.html?&_nkw=%MYSEARCHTERM"
ebay=e

# Amazon.com
a="https://www.amazon.com/s?k=%MYSEARCHTERM"
amazon=a' > $1
}


function sanitize_and_import_conf_file() {
	# this verification has yet to be tested
	# for security

	# config file will be the last argument
	# in order to the config file correspond $2 to script's $2, for example
	CFG_FILE="${@: -1}"
	# sanitize $CFG_FILE and save it in CFG_CONTENT
	# select on lines that have
	CFG_CONTENT="$(${SED} -r '/[^=]+=[^=]+/!d' ${CFG_FILE} | ${SED} -r 's/\s+=\s+/=/g')"
	# add an alias prefix to all vars
	## also exclude comment lines
	CFG_CONTENT="$(echo "${CFG_CONTENT}" | ${SED} -r '/^#/d')" # | ${SED} "s/^/${ALIAS_VAR_PREFIX}/")

	while IFS= read -r line; do
		#add alias var prefix to line
		line_with_alias_prefix="$(alias_varname_with_prefix "${line}")"
		var="$(echo ${line_with_alias_prefix%%=*} | ${SED} -r 's/ *$//g')"
		value="$(echo ${line_with_alias_prefix#*=} | ${SED} -r 's/^ *//g')"
		# remove quotation marks from $value
		value="$(echo ${value} | ${SED} -r 's/"//g')"
		export "${var}"="${value}"
	done < <(echo "${CFG_CONTENT}")
}

# arg: <string> name of the variable
function alias_varname_with_prefix() {
	printf '%s' "${ALIAS_VAR_PREFIX}${1}"
}

# arg: <string> name of the alias
function is_word_an_alias_of_config() {
	is_shell_var_varname_set "$(alias_varname_with_prefix ${1})"
}

# <string>: name of the alias
function get_alias_value_using_alias_keyword() {
	PROCESSED_ALIAS_NAME="$(alias_varname_with_prefix ${1})"
	VALUE="${!PROCESSED_ALIAS_NAME}"
	printf '%s' "${VALUE}"
}

function is_shell_var_varname_set() {
	[ -v $1 ] && return 0 || return 1
}

function encode() {
	local text="${1}"
	printf '%s' "${text}" | ${SED} "s/ /%20/g"
}

function remove_first_word_of_string() {
	read first rest << EOF
	$(echo "${1}")
EOF
	echo ${rest}
}


function remove_first_and_second_words_of_string() {
	read first second rest << EOF
	$(echo ${1})
EOF
	echo ${rest}
}

# args: <string> <Nth-position> (starting from 1)
function get_N_word_from_string() {
	tmp_arr=(${1})
	printf ${tmp_arr[${2}-1]}
}

# args: <string> <Nth-position> (starting from 1)
function echo_N_word_from_string() {
	echo $(get_N_word_from_string ${1} ${2})
}

# args: <string>
function get_bash_variables_from_string() {
	# regex bash variable
	# \$(\{([^{}]|(?R))*\}|[[:alnum:]])
	# \$(\{([^\{\}]|(?R))*\}|[[:alnum:]])

	echo ${1} | ${GREP} -Eo '\$(\{([^\{\}]|(?R))*\}|[[:alnum:]])'
}

function print_help() {
	NAME=$(${BASENAME} $0)
	echo -e "Usage:\n  ${NAME} [--help|-h]\n  ${NAME} [search_engine_alias] <search term>\n\nThe ${NAME} search engine aliases are defined in the ${CONFIG_FILE_MAIN} file."
	exit 0
}

## debugging functions

function debug_print_of_var_using_varname() {
	for var in ${@}; do
		echo "${var}:${!var}"
	done
}



# USE IN CONFIG FILES

## VARIABLES
declare FUNC

## FUNCTIONS
function show_if_else() {
	local VAR_IF="${1}"
	local VAR_ELSE="${2}"
	local ALL_ARGS="${@}"
	local ARGS=$(remove_first_and_second_words_of_string "${ALL_ARGS}")

	for arg in ${ARGS}; do
		[[ ${VAR_IF} == ${arg} ]] && printf "${VAR_IF}" && return 0
	done

	printf "${VAR_ELSE}"

	return 1
}

function remove_first_word_if() {
	local VAR_IF="${1}"
	local ARGS="${@:2}"
	local OUTPUT=""

	for arg in ${VAR_IF}; do
		[[ ${ARGS} =~ ${arg} ]] || OUTPUT+="${arg} "
	done

	printf "${OUTPUT%% }"

	return 0
}

# PROCESSING LOGIC

## arguments
ARGUMENTS="${@}"

## sanitize environment
${MKDIR} -p ${SCRIPT_CONFIG_DIR}

[ ! -f ${CONFIG_FILE_MAIN} ] && write_original_config_file_to ${CONFIG_FILE_MAIN}


## import config file
sanitize_and_import_conf_file ${ARGUMENTS} ${CONFIG_FILE_MAIN}


# check if is to show help message
[ $1 = "--help" -o $1 = "-h" ] && print_help



# CHECK IF USES A SEARCH ENGINE ALIAS

# check if the first argument corresponds to a script configured alias
# and if it doesnt use the default search engine (which corresponds to the alias name "default")

POSSIBLE_SEARCH_ENGINE_KEYWORD_ARGUMENT=$(get_N_word_from_string "${ARGUMENTS}" 1)


if ! is_word_an_alias_of_config ${POSSIBLE_SEARCH_ENGINE_KEYWORD_ARGUMENT}; then
	# set the default search engine
	SEARCH_ENGINE_ALIAS="default"

	# set the search term
	SEARCH_TERM="${ARGUMENTS}"
else
	# set the first argument as the search engine alias
	SEARCH_ENGINE_ALIAS="${POSSIBLE_SEARCH_ENGINE_KEYWORD_ARGUMENT}"

	# set the search term
	SEARCH_TERM=$(remove_first_word_of_string "${ARGUMENTS}")
fi


SEARCH_ENGINE_ARGUMENT=${SEARCH_ENGINE_ALIAS}

# while a search engine alias is another alias and try to find out the url
while is_word_an_alias_of_config "${SEARCH_ENGINE_ALIAS}"; do
	SEARCH_ENGINE_ALIAS=$(get_alias_value_using_alias_keyword "${SEARCH_ENGINE_ALIAS}")
done


# target search engine url
SEARCH_ENGINE_URL="${SEARCH_ENGINE_ALIAS}"



# Produce the link to pass to BROWSER_COMMAND

## deal with bash-like-variables that are on the configured URL
## some examples of bash-like-variables are $1, $2, ${bash_variable}, ${1:-auto}

## read and process the bash variables from the $SEARCH_ENGINE_URL

### create associative array for the bash variables from the target url of the config file
declare -A URL_CONFIG_VARS


while IFS= read -r bash_variable; do
	
	#### save the bash variables from the target url of the config file
	export "name"="${bash_variable}"
	eval "value=\"${bash_variable}\""
	URL_CONFIG_VARS[${name}]="${value}"

	#### remove the saved differences from $SEARCH_TERM
	SEARCH_TERM=$(echo ${SEARCH_TERM} | ${SED} "s/${value} *//g")

done < <(get_bash_variables_from_string ${SEARCH_ENGINE_URL})

### export for outside use
export URL_CONFIG_VARS


# evaluate the bash variables of $SEARCH_ENGINE_URL

## inserting encoded search term

### make %MYSEARCHTERM substitution
PROCESSED_SEARCH_URL="${SEARCH_ENGINE_URL//%MYSEARCHTERM/${SEARCH_TERM}}"

### evaluate variables of PROCESSED_SEARCH_URL
eval "PROCESSED_SEARCH_URL=\"${PROCESSED_SEARCH_URL}\""

### encode search url
PROCESSED_SEARCH_URL=$(encode "${PROCESSED_SEARCH_URL}")


# do the action

# echo "Search Info:
# search engine alias: \"${SEARCH_ENGINE_ARGUMENT}\"
# search phrase: \"${SEARCH_TERM}\"" # SEARCH_TERM is wrong


BROWSER_COMMAND_VAR=$(get_alias_value_using_alias_keyword "BROWSER_COMMAND")

# echo ${BROWSER_COMMAND_VAR} "${PROCESSED_SEARCH_URL}"
${BROWSER_COMMAND_VAR} "${PROCESSED_SEARCH_URL}" > /dev/null 2>&1


exit 0
