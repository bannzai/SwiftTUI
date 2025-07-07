#!/bin/bash

# timeoutコマンドの確認スクリプト

echo "Checking timeout command availability..."

if command -v gtimeout &> /dev/null; then
    echo "✓ gtimeout is available (GNU coreutils)"
    gtimeout --version | head -1
elif command -v timeout &> /dev/null; then
    echo "✓ timeout is available"
    timeout --version 2>/dev/null || echo "  (BSD timeout - no version info)"
else
    echo "✗ Neither timeout nor gtimeout is available"
    echo ""
    echo "To install on macOS:"
    echo "  brew install coreutils"
    echo ""
    echo "This will install gtimeout command."
    exit 1
fi

echo ""
echo "all-test.sh script is ready to use!"