#!/bin/bash
# Script to safely delete old Sarap.io folder

echo "🧹 Cleaning up duplicate folders..."
echo ""
echo "This will delete: Sarap.io/ (old location)"
echo ""
read -p "Are you sure? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting Sarap.io/..."
    rm -rf Sarap.io/
    echo "✅ Done! Old folder deleted."
    echo ""
    echo "Your clean structure:"
    echo "  - sarapio/ (source files)"
    echo "  - sarapio.xcodeproj (Xcode project)"
else
    echo "Cancelled."
fi
