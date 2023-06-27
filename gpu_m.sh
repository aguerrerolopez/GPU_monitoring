#!/bin/bash

# Get the GPU information using nvidia-smi and format it as CSV
gpu_info=$(nvidia-smi --query-gpu=index --format=csv,noheader,nounits)

# Prepare the CSV header
csv_header="User,Process Name,PID,GPU Memory Usage (%),GPU Number"

# Initialize an array to store each process row
process_rows=()

# Initialize an associative array to store the total GPU memory usage for each GPU
declare -A gpu_memory_usage

# Iterate over each GPU
while IFS=',' read -r gpu_index; do
  # Get the process information for the current GPU
  process_info=$(nvidia-smi --id=$gpu_index --query-compute-apps=pid,process_name,used_memory --format=csv,noheader,nounits)

  # Iterate over each line of process information
  while IFS=',' read -r pid process_name used_memory; do
    # Get the username of the process owner
    username=$(ps -o user= -p $pid)

    # Build the CSV row
    csv_row="$username,$process_name,$pid,$used_memory,$gpu_index"

    # Append the row to the process_rows array
    process_rows+=("$csv_row")

    # Add the GPU memory usage to the total for the current GPU
    ((gpu_memory_usage[$gpu_index]+=$used_memory))
  done <<< "$process_info"
done <<< "$gpu_info"

# Prepare the output CSV file name
output_file="gpu_processes.csv"

# Write the CSV file
echo "$csv_header" > "$output_file"
printf "%s\n" "${process_rows[@]}" >> "$output_file"

summary_header="Total Usage,,,,GPU Percentage, GPU Number, Memory Used (MiB)"
echo "$summary_header" >> "$output_file"

# Add the GPU memory usage summary rows
for gpu_index in "${!gpu_memory_usage[@]}"; do
  total_usage=${gpu_memory_usage[$gpu_index]}
  gpu_memory=$(nvidia-smi --id=$gpu_index --query-gpu=memory.total --format=csv,noheader,nounits)
  total_memory_usage_percentage=$(bc -l <<< "scale=2; ($total_usage / $gpu_memory) * 100")
  summary_row="Total Usage,,,,$total_memory_usage_percentage,$gpu_index,$total_usage"
  echo "$summary_row" >> "$output_file"
done

echo "CSV file '$output_file' has been generated."
