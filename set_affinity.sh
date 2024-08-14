#!/bin/bash

# Initial CPU set for affinity
start_cpu=0

# Get PIDs of all processes matching "Shooter"
pids=$(ps -e | grep Shooter | awk '{print $1}')

# Loop through each PID and assign CPU affinity
for pid in $pids; do
    # Calculate end CPU by adding 3 (to assign 4 CPUs total)
    end_cpu=$((start_cpu + 3))

    # Set CPU affinity for this process
    taskset -cp $start_cpu-$end_cpu $pid

    # Output the change for confirmation
    echo "Set PID $pid to CPUs $start_cpu-$end_cpu"

    # Increment start CPU by 4 for the next process
    start_cpu=$((end_cpu + 1))
done
