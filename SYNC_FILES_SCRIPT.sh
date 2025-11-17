#!/bin/bash
# Script to sync files from sarapio/ to Sarap.io/sarapio/sarapio/
# Run this whenever you edit files in Cursor to sync with Xcode

echo "🔄 Syncing files from sarapio/ to Sarap.io/sarapio/sarapio/..."

# Sync all files, preserving structure
rsync -av --delete \
  sarapio/ \
  "Sarap.io/sarapio/sarapio/" \
  --exclude=".DS_Store" \
  --exclude="*.xcuserstate" \
  --exclude="build/"

echo "✅ Sync complete! Xcode should now see your changes."
echo ""
echo "💡 Tip: You can run this script automatically with:"
echo "   watch -n 2 ./SYNC_FILES_SCRIPT.sh"
echo ""
echo "   Or add to your .zshrc:"
echo "   alias sync-xcode='cd /Users/student/Documents/Sarapio && ./SYNC_FILES_SCRIPT.sh'"

