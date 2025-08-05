#!/bin/bash

# Reload Quickshell script
# This script properly kills and restarts Quickshell

echo "Reloading Quickshell..."

# Kill existing Quickshell processes
pkill -f quickshell

# Wait a moment for processes to terminate
sleep 1

# Check if any quickshell processes are still running
if pgrep -f quickshell > /dev/null; then
    echo "Force killing remaining Quickshell processes..."
    pkill -9 -f quickshell
    sleep 0.5
fi

# Start Quickshell in the background
echo "Starting Quickshell..."
quickshell &

echo "Quickshell reloaded!" 