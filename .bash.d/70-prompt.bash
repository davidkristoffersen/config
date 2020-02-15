#!/usr/bin/env bash

function prompt_path() {
	local path=""
	local -a path_arr
	IFS="/" read -ra path_arr <<< "$(pwd)"
	local path_len="$((${#path_arr[@]}-1))"
	local path_it=-1
	local path_padd=2
	if [ $path_len -eq 0 ]; then
		path="/"
	fi

	for i in "${path_arr[@]}"; do
		if [ $path_it -eq -1 ]; then
			((path_it++))
			continue
		elif [ $path_len -gt $((path_padd * 2)) ]; then
			if [ $path_it -lt $path_padd ]; then
				path="$path/$i"
			elif [ $path_it -gt $((path_len - $path_padd - 1)) ]; then
				path="$path/$i"
			elif [ $path_it -eq $path_padd ]; then
				path="$path/..."
			fi
		else
			path="$path/$i"
		fi
		((path_it++))
	done
	printf "$BBLUE$path$RESET"
}

function prompt_git() {
	# Git branch detection
	local branch="$(git branch 2>/dev/null | grep '^*' | colrm 1 2) "
 	if [ "$branch" == " " ]; then
		branch=''
	fi
	printf "$BMAGENTA$branch$RESET"
}

function prompt_pre() {
	local pre="$RESET$BYELLOW╭─ $RESET"
	local post="$RESET$BYELLOW╰─$RESET"
	local -a _pre=("$pre" "$post")
	declare -p _pre
}

function prompt_ssh() {
	local _out=""
	_out+="$BYELLOW[$RESET\u$RESET"
	_out+="$FAINT@$RESET"
	_out+="${HOSTNAME%%.*}$BYELLOW]$RESET"
	printf "$out"
}

function prompt_exit() {
	local _out=""
	if [ "$1" != "0" ]; then
		_out="${RED}</3${RESET}"
	else
		_out="${GREEN}<3${RESET}"
	fi
	printf "$_out"
}

PROMPT_COMMAND=__prompt_command # Func to gen PS1 after CMDs
__prompt_command() {
	# Previous commands' exit status
	local EXIT="$?"
	PS1=""

	# Create start of lines
	eval "$(prompt_pre)"

	# Start of line 0
	PS1+="${_pre[0]}"

	# SSH info
	if $SSH; then
		PS1+="$(prompt_ssh) "
	fi

	# Git info
	PS1+="$(prompt_git)"

	# Path info
	PS1+="$(prompt_path) "

	# Exit status info
	PS1+="$(prompt_exit $EXIT)"

	# Start of line 1
	PS1+="\n${_pre[1]} "
}
