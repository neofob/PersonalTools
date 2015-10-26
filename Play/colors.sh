#!/bin/bash
# Modified from docker/docker's `contrib/check-config.sh`

# see https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
declare -A colors=(
	[black]=30
	[red]=31
	[green]=32
	[yellow]=33
	[blue]=34
	[magenta]=35
	[cyan]=36
	[white]=37
)
# Ex: color red
function color() {
	color=( 1 )
	if [ $# -gt 0 ] && [ "${colors[$1]}" ]; then
		color+=( "${colors[$1]}" )
	fi
	# set delimiter
	local IFS=';'
	echo -en '\033['"${color[*]}"m
}

# reverse docker's order
# wrap_color <color> <"text">
function wrap_color() {
	color "$1"
	shift
	echo -n "$@"
	color reset
	echo
}
