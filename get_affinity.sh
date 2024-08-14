#!/bin/bash

# Get PIDs and corresponding commands of all processes matching "Shooter"
processes=$(ps -eo pid,comm | grep Shooter)

echo "PID - Command - Affinity"
echo "---------------------------------"

# Loop through each process and display its CPU affinity
echo "$processes" | while read -r line; do
    # Extract the PID from each line
    pid=$(echo $line | awk '{print $1}')

    # Get the CPU affinity for this PID
    affinity=$(taskset -cp $pid 2>&1 | grep -oP 'current affinity list: \K.*')

    # Display PID, command, and affinity
    echo "$line - CPUs: $affinity"
done
