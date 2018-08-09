#!/bin/bash
MEMCG_DIR="/sys/fs/cgroup/memory/kubepods"
MEM_LIMIT_FILES=$(find /sys/fs/cgroup/memory/kubepods -name memory.limit_in_bytes)
RESET=0
MEM_HIGH_RATIO=0.8
INT_MAX=9223372036854771712
DATE_PRINTED=0

FUNC=$1

function print_date(){
	if [[ "$DATE_PRINTED" == "0" ]];then
		date
		DATE_PRINTED=1
	fi
}

function mem_high_set(){
	for MEM_LIMIT_FILE in $MEM_LIMIT_FILES
	do
		MEMCG_SUB_DIR=$(dirname $MEM_LIMIT_FILE)
		MEM_LIMIT=$(cat $MEM_LIMIT_FILE)
		if (( $MEM_LIMIT < $INT_MAX &&
			$(cat $MEMCG_SUB_DIR/memory.high) == $INT_MAX )); then
			awk "BEGIN {print int($MEM_LIMIT * $MEM_HIGH_RATIO); exit}" > $MEMCG_SUB_DIR/memory.high
		else
			continue
		fi
		print_date
		grep -H "" $MEM_LIMIT_FILE
		grep -H "" $MEMCG_SUB_DIR/memory.high
	done
}

function mem_high_clear(){
	for MEM_LIMIT_FILE in $MEM_LIMIT_FILES
	do
		MEMCG_SUB_DIR=$(dirname $MEM_LIMIT_FILE)
		if (( $(cat $MEMCG_SUB_DIR/memory.high) < $INT_MAX )); then
			echo -1 > $MEMCG_SUB_DIR/memory.high
		else
			continue
		fi
		print_date
		grep -H "" $MEM_LIMIT_FILE
		grep -H "" $MEMCG_SUB_DIR/memory.high
	done
}

function show(){
	for MEM_LIMIT_FILE in $MEM_LIMIT_FILES
	do
		MEMCG_SUB_DIR=$(dirname $MEM_LIMIT_FILE)
		MEM_LIMIT=$(cat $MEM_LIMIT_FILE)
		if (( $MEM_LIMIT < $INT_MAX )); then
			grep -H "" $MEM_LIMIT_FILE
			grep -H "" $MEMCG_SUB_DIR/memory.high
			grep -H "" $MEMCG_SUB_DIR/memory.usage_in_bytes
		else
			continue
		fi
	done
}

case "$FUNC" in
	"set")
		mem_high_set
		;;
	"clear")
		mem_high_clear
		;;
	"show")
		show
		;;
	*)
		;;
esac

if [[ "$DATE_PRINTED" == "1" ]];then
	echo ""
fi

