#!/bin/bash

# Run ButtonFocusTest and capture stderr
echo "Running ButtonFocusTest..."
swift run ButtonFocusTest 2>button_debug.txt &
PID=$!

# Let it run for a moment
sleep 2

# Send Tab key
echo -e "\t" > /dev/tty

# Wait a bit more
sleep 1

# Kill the process
kill -TERM $PID 2>/dev/null

# Show debug output
echo ""
echo "=== Debug output from stderr ==="
cat button_debug.txt | grep -E "(FocusManager|ButtonLayoutManager|ButtonContainer|ButtonLayoutView)" | head -50