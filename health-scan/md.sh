#!/bin/bash

# Function to display data in Markdown format
print_markdown() {
  local output_file="$1"

  {
    echo -e "## System Uptime\n\n$uptime_info\n"
    echo -e "## Load Averages\n\n$load_averages\n"

    echo -e "## Disk Usage\n"
    echo -e "| Total | Used | Available | Use% |"
    echo -e "|-------|------|-----------|------|"
    echo "$disk_usage" | awk '{printf "| %s | %s | %s | %s |\n", $1, $2, $3, $4}'

    echo -e "## Memory Usage\n"
    echo -e "| Total | Used | Free | Shared | Buff/Cache | Available |"
    echo -e "|-------|------|------|--------|------------|-----------|"
    echo "$memory_info" | awk '{printf "| %s | %s | %s | %s | %s | %s |\n", $1, $2, $3, $4, $5, $6}'

    echo -e "## CPU Idle Percentage\n\n$cpu_load%\n"

    echo -e "## CPU Temperature\n\n$temperature_info\n"

    echo -e "## Network Statistics\n"
    echo -e "| Interface | RX Packets | TX Packets |"
    echo -e "|-----------|------------|------------|"
    echo "$network_stats" | awk '{printf "| %s | %s | %s |\n", $1, $3, $11}'

    echo -e "## Top Processes\n"
    echo -e "| PID | USER | CPU | MEM | COMMAND |"
    echo -e "|-----|------|-----|-----|---------|"
    echo "$top_processes" | awk '{printf "| %s | %s | %s | %s | %s |\n", $1, $2, $9, $10, $12}'

    echo -e "## Battery Status\n"
    echo -e "| State | Percentage | Time Left |"
    echo -e "|-------|------------|-----------|"
    echo "$battery_status" | awk '{printf "| %s | %s | %s |\n", $1, $2, $3}'

  } > "$output_file"
}

# Get system uptime
uptime_info=$(uptime -p | sed 's/^[^ ]* //' | sed 's/ up //g')

# Get load averages
load_averages=$(uptime | awk -F 'load average:' '{ print $2 }' | sed 's/^[ \t]*//')

# Get disk usage information
disk_usage=$(df -h --total | awk '/^total/ {printf("%s %s %s %s", $2, $3, $4, $5)}')

# Get memory usage information
memory_info=$(free -h | awk '/^Mem:/ {printf("%s %s %s %s %s %s", $2, $3, $4, $5, $6, $7)}')

# Get CPU load information
cpu_load=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf("%s", $1)}')

# Get CPU temperature and frequency (requires lm-sensors)
if command -v sensors > /dev/null; then
  temperature_info=$(sensors | awk '/^Core 0:/ {printf("%s", $3)}')
else
  temperature_info="N/A"
fi

# Get network statistics
network_stats=$(netstat -i | awk 'NR>2 {printf("%s %s %s\n", $1, $3, $11)}')

# Get process information (top 5 processes by CPU usage)
top_processes=$(top -bn1 | head -n 12 | tail -n 10 | awk '{printf("%s %s %s %s %s\n", $1, $2, $9, $10, $12)}')

# Get battery status (for laptops)
if command -v upower > /dev/null; then
  battery_status=$(upower -i $(upower -e | grep 'BAT') | awk '/state:/ {state=$2} /percentage:/ {percent=$2} /time to empty:/ {time_left=$4" "$5} END {printf("%s %s %s", state, percent, time_left)}')
else
  battery_status="N/A N/A N/A"
fi

# Set default output filename
output_file="system_info.md"

# Output Markdown
print_markdown "$output_file"

echo "Output written to $output_file"
