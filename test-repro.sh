#!/bin/bash
set -e

echo "Reproducing expo export --clear bug"
echo ""

# Clean up any previous builds to start fresh
rm -rf dist/

# STEP 1: First export with TEST_VAR=first
# This should create a bundle with "first" inlined
echo "Step 1: Export with TEST_VAR=first"
EXPO_PUBLIC_TEST_VAR=first npx expo export -p web

# Extract the bundle hash from the filename
# Expected: A unique hash like "6bfb8dfffc218d3fd4d1208e4d6206d7"
HASH1=$(ls dist/_expo/static/js/web/index-*.js | head -1 | sed 's/.*index-\(.*\)\.js/\1/')
echo "Bundle hash: $HASH1"
echo ""

# STEP 2: Second export with TEST_VAR=second AND --clear flag
# The --clear flag should clear Metro's cache and rebuild from scratch
# This should create a NEW bundle with "second" inlined and a DIFFERENT hash
echo "Step 2: Export with TEST_VAR=second --clear"
EXPO_PUBLIC_TEST_VAR=second npx expo export -p web --clear

# Extract the second bundle hash
HASH2=$(ls dist/_expo/static/js/web/index-*.js | head -1 | sed 's/.*index-\(.*\)\.js/\1/')
echo "Bundle hash: $HASH2"
echo ""

# VERIFICATION: Compare the bundle hashes
# If they're identical, the bug is reproduced (cache was NOT cleared)
if [ "$HASH1" = "$HASH2" ]; then
    echo "🐛 BUG: Bundle hashes are IDENTICAL ($HASH1)"
    echo "The --clear flag did not actually clear the cache"

    # Additional verification: Check if old value is still in the bundle
    if grep -q "first" dist/_expo/static/js/web/index-*.js; then
        echo "Bundle still contains 'first' from the first export"
    fi
else
    echo "✅ Bundle hashes are different - cache was cleared"
fi
