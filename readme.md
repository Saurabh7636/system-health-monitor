# System Health Monitor

## Overview

The System Health Monitor is a bash script that collects and presents critical system health data in JSON format. It provides detailed insights into various system metrics and statuses, including uptime, load averages, disk and memory usage, CPU load and temperature, network statistics, top processes, and battery status (for laptops).

## Features

- **System Uptime**: Displays the total time the system has been running.
- **Load Averages**: Shows the system load for the last 1, 5, and 15 minutes.
- **Disk Usage**: Provides details on disk space usage and availability.
- **Memory Usage**: Offers information about memory utilization.
- **CPU Load**: Indicates the percentage of CPU that is currently idle.
- **CPU Temperature**: Reports the temperature of CPU cores (requires `lm-sensors`).
- **Network Statistics**: Includes data on network interfaces, such as packets sent and received.
- **Top Processes**: Lists the processes consuming the most CPU resources.
- **Battery Status**: For laptops, provides battery level, percentage, and remaining time (requires `upower`).

## Requirements

- `jq`: A tool for processing JSON.
- `lm-sensors`: For monitoring CPU temperature.
- `upower`: For checking battery status (on laptops).
- `net-tools`: For network statistics.

### Running the Application

1. **Install Required Packages**

   Use the following script to install the necessary packages for both Debian-based and Red Hat-based systems:

   - Make the script executable:
        ```bash
        chmod +x install_dependencies.sh
        ```

   - Run the script with root privileges:
        ```bash
        sudo bash install_dependencies.sh
        ```

2. **Obtain Health Information**

   To get system health data, follow these steps for both Debian-based and Red Hat-based systems:

   - Navigate to the `health-scan` directory and make the scripts executable:

        ```bash
        chmod +x json.sh
        ```

        ```bash
        chmod +x md.sh
        ```

   - Execute the scripts with root privileges:

        ```bash
        sudo bash json.sh # Outputs data to system_info.json
        ```

        ```bash
        sudo bash md.sh # Outputs data to system_info.md
        ```