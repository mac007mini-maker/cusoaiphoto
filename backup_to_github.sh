#!/bin/bash

echo "🔄 Starting GitHub backup process..."

# Add new remote if not exists
if git remote | grep -q "backup"; then
    echo "✅ Backup remote already exists"
else
    echo "➕ Adding backup remote..."
    git remote add backup https://github.com/jokerlin135/visoaiflow-backup.git
fi

# Commit current changes
echo "📝 Committing current changes..."
git add .
git commit -m "Backup: Clean UI with gradient Pro page and fixed navigation" || echo "No changes to commit"

# Push to backup repo
echo "⬆️  Pushing to backup repo..."
git push backup main

echo "✅ Backup completed successfully!"
echo "📦 Code backed up to: https://github.com/jokerlin135/visoaiflow-backup"
