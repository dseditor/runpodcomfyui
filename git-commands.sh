#!/bin/bash
# Git commands for deployment

# ==================================================
# First time setup
# ==================================================

# 1. Create GitHub repo first: https://github.com/new

# 2. Initialize and push
cd F:/Serverless/runpodworker

git init
git add .
git commit -m "Initial commit: ComfyUI Serverless Worker"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git push -u origin main

# ==================================================
# Update code after changes
# ==================================================

git add .
git commit -m "Update handler or configuration"
git push

# RunPod will automatically rebuild (takes ~5 minutes)

# ==================================================
# Common commands
# ==================================================

# Check status
git status

# View changes
git diff

# View commit history
git log --oneline

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# ==================================================
# If you need to change remote URL
# ==================================================

git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/NEW_REPO.git
git push -u origin main
