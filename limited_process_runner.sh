#!/bin/bash

FILES=$(ls ./*.jh)
SLEEP_TIME=0.3
PROCESS_LIMIT_REACHED=false
MAXIMUM_BACKGROUND_PROCESSES=3
INDEX=0
for FILE in $FILES; do
	sh "./$FILE" &
	PID_ARRAY[$INDEX]=$!
	if [[ $PROCESS_LIMIT_REACHED = true ]]; then
		ALL_PROCESSES_RUNNING=true
		while [[ $ALL_PROCESSES_RUNNING = true ]]; do
			I=0
			for PID in "${PID_ARRAY[@]}"; do
				kill -0 $PID 2>/dev/null
				if [[ $? -ne 0 ]]; then
					INDEX=$I
					ALL_PROCESSES_RUNNING=false
					break
				fi
				I=$((I + 1))
			done
			sleep $SLEEP_TIME
		done
		continue	
	fi
	INDEX=$((INDEX + 1))
	if [[ $INDEX -eq $((MAXIMUM_BACKGROUND_PROCESSES - 1)) ]]; then
		PROCESS_LIMIT_REACHED=true
	fi
done
exit 0
