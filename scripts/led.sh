#!/usr/bin/env bash

modprobe -r ec_sys
modprobe ec_sys write_support=1

on="\x8a"
off="\x0a"

led(){
	echo -n -e $1 | dd of="/sys/kernel/debug/ec/ec0/io" bs=1 seek=12 count=1 conv=notrunc 2> /dev/null
	# thx to u/vali20
	# https://www.reddit.com/r/thinkpad/comments/7n8eyu/thinkpad_led_control_under_gnulinux/
}

dit(){
	led $on
	sleep 0.1
	led $off
	sleep 0.1
}

dah(){
	led $on
	sleep 0.3
	led $off
	sleep 0.1
}

morse(){
	case $1 in
		"0") dah; dah; dah; dah; dah;;
		"1") dit; dah; dah; dah; dah;;
		"2") dit; dit; dah; dah; dah;;
		"3") dit; dit; dit; dah; dah;;
		"4") dit; dit; dit; dit; dah;;
		"5") dit; dit; dit; dit; dit;;
		"6") dah; dit; dit; dit; dit;;
		"7") dah; dah; dit; dit; dit;;
		"8") dah; dah; dah; dit; dit;;
		"9") dah; dah; dah; dah; dit;;
		"a") dit; dah;;
		"b") dah; dit; dit; dit;;
		"c") dah; dit; dah; dit;;
		"d") dah; dit; dit;;
		"e") dit;;
		"f") dit; dit; dah; dit;;
		"g") dah; dah; dit;;
		"h") dit; dit; dit; dit;;
		"i") dit; dit;;
		"j") dit; dah; dah; dah;;
		"k") dah; dit; dah;;
		"l") dit; dah; dit; dit;;
		"m") dah; dah;;
		"n") dah; dit;;
		"o") dah; dah; dah;;
		"p") dit; dah; dah; dit;;
		"q") dah; dah; dit; dah;;
		"r") dit; dah; dit;;
		"s") dit; dit; dit;;
		"t") dah;;
		"u") dit; dit; dah;;
		"v") dit; dit; dit; dah;;
		"w") dit; dah; dah;;
		"x") dah; dit; dit; dah;;
		"y") dah; dit; dah; dah;;
		"z") dah; dah; dit; dit;;
		" ") sleep 0.6;;
		#*) echo "done";;
	esac
	sleep 0.2;
}

parse(){
	tmp=$1
	for i in $(seq 0 ${#tmp})
	do
		echo "current letter: ${tmp:$i:1}"
		morse ${tmp:$i:1}
	done
}

read -p "enter a word: " input
echo "blinking \"$input\""
parse "$input"

sleep 1
led $on

modprobe -r ec_sys
