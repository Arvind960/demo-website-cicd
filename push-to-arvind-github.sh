#!/bin/bash

echo "🚀 GitHub Push Script for Arvind960"
echo "=================================="
echo ""

# Get repository name from user
read -p "Enter your GitHub repository name (e.g., demo-website-cicd): " REPO_NAME

if [[ -z "$REPO_NAME" ]]; then
    echo "❌ Repository name is required!"
    exit 1
fi

# Set up remote
REPO_URL="https://github.com/Arvind960/${REPO_NAME}.git"
echo "🔗 Setting up remote: $REPO_URL"

# Check if remote already exists
if git remote get-url origin >/dev/null 2>&1; then
    echo "📝 Updating existing remote..."
    git remote set-url origin "$REPO_URL"
else
    echo "➕ Adding new remote..."
    git remote add origin "$REPO_URL"
fi

echo ""
echo "🚀 Pushing to GitHub..."
echo "📝 When prompted for password, use your Personal Access Token (NOT your GitHub password)"
echo ""

# Push to GitHub
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCESS! Repository pushed to GitHub!"
    echo ""
    echo "🔗 Your repository: https://github.com/Arvind960/${REPO_NAME}"
    echo "📊 SonarQube Dashboard: http://192.168.47.147:9000/dashboard?id=demo-website"
    echo "🌐 Demo Website: http://localhost:9090"
    echo ""
    echo "📋 Next Steps:"
    echo "1. Update Jenkins pipeline to use GitHub repository"
    echo "2. Set up webhook for automatic builds (optional)"
    echo "3. Share your repository URL in your portfolio"
    echo "4. Update README with your specific deployment URLs"
    echo ""
    echo "🎯 Jenkins Integration:"
    echo "- Go to: http://localhost:8080/job/demo-website-pipeline/"
    echo "- Configure → Pipeline → Pipeline script from SCM"
    echo "- Repository URL: $REPO_URL"
    echo "- Branch: */main"
    echo "- Script Path: Jenkinsfile"
else
    echo ""
    echo "❌ Push failed!"
    echo ""
    echo "🔧 Common solutions:"
    echo "1. Create Personal Access Token at: https://github.com/settings/tokens"
    echo "2. Use token as password (NOT your GitHub password)"
    echo "3. Ensure repository exists: https://github.com/Arvind960/${REPO_NAME}"
    echo "4. Check token has 'repo' permissions"
    echo ""
    echo "🔄 Try running this script again after fixing the issue"
fi
