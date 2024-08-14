#!/bin/bash

# Total number of CPUs available
total_cpus=$(nproc --all)

# Array to keep track of PID and their assigned CPUs
declare -A pid_cpu_map

# Function to check and return available CPU range of size n
find_next_available_range() {
    local n=$1
    local start_cpu=0
    while [ $((start_cpu + n - 1)) -lt $total_cpus ]; do
        # Assume range is available unless found otherwise
        local is_available=1
        for cpu in "${!pid_cpu_map[@]}"; do
            local range=(${pid_cpu_map[$cpu]//-/ })
            if [ $start_cpu -le ${range[1]} ] && [ $((start_cpu + n - 1)) -ge ${range[0]} ]; then
                is_available=0
                break
            fi
        done

        if [ $is_available -eq 1 ]; then
            echo $start_cpu
            return
        fi
        ((start_cpu++))
    done

    echo "No available CPUs"
    return
}

# Collect all current CPU affinities and PIDs
processes=$(ps -eo pid,comm | grep Shooter)

# Populate pid_cpu_map with current CPU settings
echo "$processes" | while read -r line; do
    pid=$(echo $line | awk '{print $1}')
    affinity=$(taskset -cp $pid 2>&1 | grep -oP 'current affinity list: \K.*' | sed 's/,/-/')
    pid_cpu_map[$pid]=$affinity
done

# Check for any overlaps and mark PIDs for resetting
declare -a reset_pids
for pid in "${!pid_cpu_map[@]}"; do
    for pid2 in "${!pid_cpu_map[@]}"; do
        if [ "$pid" != "$pid2" ]; then
            range1=(${pid_cpu_map[$pid]//-/ })
            range2=(${pid_cpu_map[$pid2]//-/ })
            if [ ${range1[0]} -le ${range2[1]} ] && [ ${range1[1]} -ge ${range2[0]} ]; then
                reset_pids+=($pid)
                reset_pids+=($pid2)
            fi
        fi
    done
done

# Remove duplicates from reset_pids
reset_pids=($(echo "${reset_pids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Reset CPU affinity for overlapping processes
for pid in "${reset_pids[@]}"; do
    new_start_cpu=$(find_next_available_range 3)
    if [ "$new_start_cpu" == "No available CPUs" ]; then
        echo "PID $pid - No available CPUs to reset"
        continue
    fi
    new_end_cpu=$((new_start_cpu + 2))
    taskset -cp $new_start_cpu-$new_end_cpu $pid
    echo "PID $pid - Reset to CPUs $new_start_cpu-$new_end_cpu"
done
