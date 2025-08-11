#!/bin/bash

echo "🔑 SonarQube Authentication Setup Guide"
echo "======================================="
echo ""

SONAR_URL="http://192.168.47.147:9000"

echo "Step 1: Create SonarQube Token"
echo "------------------------------"
echo "1. Open SonarQube in browser: $SONAR_URL"
echo "2. Login with admin credentials (default: admin/admin)"
echo "3. Go to: My Account → Security → Generate Tokens"
echo "4. Create token with name: 'jenkins-demo-website'"
echo "5. Copy the generated token"
echo ""

echo "Step 2: Add Token to Jenkins"
echo "----------------------------"
echo "1. Go to Jenkins: http://localhost:8080"
echo "2. Navigate to: Manage Jenkins → Manage Credentials"
echo "3. Click: (global) → Add Credentials"
echo "4. Kind: Secret text"
echo "5. Secret: [paste your SonarQube token]"
echo "6. ID: sonar-token"
echo "7. Description: SonarQube Authentication Token"
echo ""

echo "Step 3: Configure SonarQube Server in Jenkins"
echo "---------------------------------------------"
echo "1. Go to: Manage Jenkins → Configure System"
echo "2. Find: SonarQube servers section"
echo "3. Add SonarQube server:"
echo "   - Name: SonarQ"
echo "   - Server URL: $SONAR_URL"
echo "   - Server authentication token: sonar-token (select from dropdown)"
echo ""

echo "Step 4: Test Manual Scan (after getting token)"
echo "----------------------------------------------"
echo "Replace YOUR_TOKEN_HERE with actual token:"
echo ""
echo "cd /tmp/demo-website-repo"
echo "/var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQ/bin/sonar-scanner \\"
echo "  -Dsonar.projectKey=demo-website \\"
echo "  -Dsonar.projectName=\"DevOps Demo Website\" \\"
echo "  -Dsonar.projectVersion=1.0 \\"
echo "  -Dsonar.sources=. \\"
echo "  -Dsonar.exclusions=\"node_modules/**,**/*.min.js,**/*.min.css,Dockerfile,nginx.conf\" \\"
echo "  -Dsonar.host.url=$SONAR_URL \\"
echo "  -Dsonar.token=YOUR_TOKEN_HERE"
echo ""

echo "Step 5: Alternative - Disable Authentication (for demo only)"
echo "-----------------------------------------------------------"
echo "If this is just for demo purposes, you can disable authentication:"
echo "1. Login to SonarQube as admin"
echo "2. Go to: Administration → Security → General"
echo "3. Turn OFF 'Force user authentication'"
echo "4. Save settings"
echo ""
echo "⚠️  WARNING: Only do this for demo/development environments!"
echo ""

echo "🔍 Quick Check - SonarQube Login Status:"
LOGIN_CHECK=$(curl -s "$SONAR_URL/api/authentication/validate" | grep -o '"valid":[^,]*')
echo "Authentication status: $LOGIN_CHECK"

if [[ "$LOGIN_CHECK" == *"false"* ]]; then
    echo "✅ Authentication might be disabled - try running pipeline again"
else
    echo "🔐 Authentication is required - follow steps above"
fi
