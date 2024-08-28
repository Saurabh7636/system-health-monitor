#!/bin/bash

# Function to escape strings for JSON
escape_json() {
  printf '%s' "$1" | jq -R .
}

# Get system uptime
uptime_info=$(uptime -p | sed 's/^[^ ]* //' | sed 's/ up //g')

# Get load averages
load_averages=$(uptime | awk -F 'load average:' '{ print $2 }' | sed 's/^[ \t]*//')

# Get disk usage information
disk_usage=$(df -h --total | awk '/^total/ {printf("{\"total\": \"%s\", \"used\": \"%s\", \"available\": \"%s\", \"use_percentage\": \"%s\"}", $2, $3, $4, $5)}')

# Get memory usage information
memory_info=$(free -h | awk '/^Mem:/ {printf("{\"total\": \"%s\", \"used\": \"%s\", \"free\": \"%s\", \"shared\": \"%s\", \"buff/cache\": \"%s\", \"available\": \"%s\"}", $2, $3, $4, $5, $6, $7)}')

# Get CPU load information
cpu_load=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf("{\"cpu_idle\": \"%s\"}", $1)}')

# Get CPU temperature and frequency (requires lm-sensors)
if command -v sensors > /dev/null; then
  temperature_info=$(sensors | awk '/^Core 0:/ {printf("{\"core0\": \"%s\"}", $3)}')
else
  temperature_info="{\"error\": \"lm-sensors not installed\"}"
fi

# Get network statistics
network_stats=$(netstat -i | awk 'NR>2 {printf("{\"interface\": \"%s\", \"rx_packets\": \"%s\", \"tx_packets\": \"%s\"}", $1, $3, $11)}' | jq -s '.')

# Get process information (top 5 processes by CPU usage)
top_processes=$(top -bn1 | head -n 12 | tail -n 10 | awk '{printf("{\"pid\": \"%s\", \"user\": \"%s\", \"cpu\": \"%s\", \"mem\": \"%s\", \"command\": \"%s\"}", $1, $2, $9, $10, $12)}' | jq -s '.')

# Get battery status (for laptops)
if command -v upower > /dev/null; then
  battery_status=$(upower -i $(upower -e | grep 'BAT') | awk '/state:/ {state=$2} /percentage:/ {percent=$2} /time to empty:/ {time_left=$4" "$5} END {printf("{\"state\": \"%s\", \"percentage\": \"%s\", \"time_left\": \"%s\"}", state, percent, time_left)}')
else
  battery_status="{\"error\": \"upower not installed\"}"
fi

# Combine all information into a JSON object using jq
json_output=$(jq -n \
  --arg uptime "$uptime_info" \
  --arg load_averages "$load_averages" \
  --argjson disk_usage "$disk_usage" \
  --argjson memory_info "$memory_info" \
  --argjson cpu_load "$cpu_load" \
  --argjson temperature_info "$temperature_info" \
  --argjson network_stats "$network_stats" \
  --argjson top_processes "$top_processes" \
  --argjson battery_status "$battery_status" \
  '{
    uptime: $uptime,
    load_averages: $load_averages,
    disk_usage: $disk_usage,
    memory_info: $memory_info,
    cpu_load: $cpu_load,
    temperature_info: $temperature_info,
    network_stats: $network_stats,
    top_processes: $top_processes,
    battery_status: $battery_status
  }')

# Output the JSON to a file
output_file="system_info.json"
echo "$json_output" > "$output_file"

echo "JSON output saved to $output_file"
