#!/bin/bash

echo "🔍 SonarQube Integration Troubleshooting Guide"
echo "=============================================="
echo ""

echo "1. 📋 Checking SonarQube Server Accessibility..."
SONAR_URL="http://192.168.47.147:9000"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $SONAR_URL)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ SonarQube server is accessible at $SONAR_URL"
else
    echo "❌ SonarQube server is not accessible (HTTP: $HTTP_CODE)"
    echo "   Check if SonarQube is running: docker ps | grep sonar"
    exit 1
fi

echo ""
echo "2. 🔧 Jenkins Configuration Steps:"
echo "   Go to: Jenkins → Manage Jenkins → Configure System"
echo "   Find: SonarQube servers section"
echo "   Add server with:"
echo "   - Name: SonarQ"
echo "   - Server URL: $SONAR_URL"
echo "   - Server authentication token (if required)"
echo ""

echo "3. 🔑 SonarQube Authentication Token:"
echo "   If authentication is required:"
echo "   - Go to: $SONAR_URL/account/security"
echo "   - Generate token"
echo "   - Add to Jenkins credentials"
echo ""

echo "4. 📊 Check Current SonarQube Projects:"
curl -s "$SONAR_URL/api/projects/search" | python3 -m json.tool 2>/dev/null || echo "   No projects found or API not accessible"

echo ""
echo "5. 🧪 Manual SonarQube Test:"
echo "   Run this command in your project directory:"
echo "   sonar-scanner \\"
echo "     -Dsonar.projectKey=demo-website \\"
echo "     -Dsonar.projectName=\"DevOps Demo Website\" \\"
echo "     -Dsonar.sources=. \\"
echo "     -Dsonar.host.url=$SONAR_URL"

echo ""
echo "6. 🔍 Check Jenkins Build Logs:"
echo "   Look for these patterns in Jenkins console output:"
echo "   - 'SonarQube analysis failed'"
echo "   - 'SonarQube scanner not found'"
echo "   - 'Quality Gate'"
echo "   - 'withSonarQubeEnv'"

echo ""
echo "7. 📝 Common Solutions:"
echo "   a) Install SonarQube Scanner plugin in Jenkins"
echo "   b) Configure SonarQube server in Jenkins system configuration"
echo "   c) Ensure sonar-scanner is installed on Jenkins agent"
echo "   d) Check network connectivity between Jenkins and SonarQube"
echo "   e) Verify authentication tokens if security is enabled"
