#!/bin/bash

# Function to generate the GPU processes CSV
generate_gpu_processes_csv() {
    ./gpu_m.sh
}

# Set the interval in seconds
interval=30

# Loop indefinitely
while true; do
    # Generate the GPU processes CSV
    generate_gpu_processes_csv

    # Sleep for the specified interval
    sleep "$interval"
done
