#!/bin/bash

# Check for replaceSubrange usage in Sources directory
if grep -r "replaceSubrange" Sources/; then
    echo "❌ Error: Found usage of replaceSubrange in source files!"
    echo "Please use bufferWrite instead of replaceSubrange to avoid range errors."
    exit 1
fi

echo "✅ No replaceSubrange usage found"
exit 0