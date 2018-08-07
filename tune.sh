#!/bin/bash
MEMCG_DIR="/sys/fs/cgroup/memory/kubepods"
MEM_LIMIT_FILES=$(find /sys/fs/cgroup/memory/kubepods -name memory.limit_in_bytes)
RESET=0

date

for MEM_LIMIT_FILE in $MEM_LIMIT_FILES
do
	MEMCG_SUB_DIR=$(dirname $MEM_LIMIT_FILE)
	MEM_LIMIT=$(cat $MEM_LIMIT_FILE)
	if (( $RESET == 1 &&
		$(cat $MEMCG_SUB_DIR/memory.high) < 9223372036854771712 )); then
		echo -1 > $MEMCG_SUB_DIR/memory.high
	elif (( $RESET == 0 &&
		$MEM_LIMIT < 9223372036854771712 &&
		$(cat $MEMCG_SUB_DIR/memory.high) == 9223372036854771712 )); then
		awk "BEGIN {print int($MEM_LIMIT * 0.8); exit}" > $MEMCG_SUB_DIR/memory.high
	else
		continue
	fi
	grep -H "" $MEM_LIMIT_FILE
	grep -H "" $MEMCG_SUB_DIR/memory.high
done

echo ""
