#!/bin/bash

echo "🔍 SonarQube GUI Access Diagnostic"
echo "=================================="
echo ""

SONAR_URL="http://192.168.47.147:9000"
PROJECT_KEY="demo-website"

echo "1. 📊 SonarQube Server Status:"
echo "------------------------------"
SERVER_STATUS=$(curl -s "$SONAR_URL/api/system/status" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
echo "Server Status: $SERVER_STATUS"
echo "Server URL: $SONAR_URL"
echo ""

echo "2. 🔍 Project Analysis Evidence:"
echo "--------------------------------"
if [ -f "/tmp/demo-website/.scannerwork/report-task.txt" ]; then
    echo "✅ SonarQube analysis was completed successfully!"
    echo "Analysis details:"
    cat /tmp/demo-website/.scannerwork/report-task.txt
    echo ""
    
    DASHBOARD_URL=$(grep "dashboardUrl=" /tmp/demo-website/.scannerwork/report-task.txt | cut -d'=' -f2-)
    echo "📊 Direct Dashboard URL: $DASHBOARD_URL"
else
    echo "❌ No recent analysis found"
fi
echo ""

echo "3. 🌐 GUI Access Instructions:"
echo "------------------------------"
echo "To access SonarQube GUI:"
echo ""
echo "Step 1: Open your web browser"
echo "Step 2: Navigate to: $SONAR_URL"
echo "Step 3: Login with credentials:"
echo "        Username: admin"
echo "        Password: admin (default)"
echo ""
echo "Step 4: After login, go directly to project:"
echo "        $SONAR_URL/dashboard?id=$PROJECT_KEY"
echo ""

echo "4. 🔐 Authentication Check:"
echo "---------------------------"
AUTH_STATUS=$(curl -s "$SONAR_URL/api/authentication/validate" | grep -o '"valid":[^,}]*')
echo "Current authentication: $AUTH_STATUS"

if [[ "$AUTH_STATUS" == *"false"* ]]; then
    echo "🔑 You need to login to see projects in the GUI"
    echo ""
    echo "Alternative - Disable authentication for demo:"
    echo "1. Login to SonarQube as admin"
    echo "2. Go to: Administration → Security → General"
    echo "3. Turn OFF 'Force user authentication'"
    echo "4. Save settings"
fi
echo ""

echo "5. 🧪 Quick Tests:"
echo "------------------"
echo "Testing main SonarQube page..."
MAIN_PAGE=$(curl -s -w "%{http_code}" -o /dev/null "$SONAR_URL/")
echo "Main page HTTP status: $MAIN_PAGE"

echo "Testing project dashboard..."
DASHBOARD_PAGE=$(curl -s -w "%{http_code}" -o /dev/null "$SONAR_URL/dashboard?id=$PROJECT_KEY")
echo "Dashboard HTTP status: $DASHBOARD_PAGE"

if [ "$DASHBOARD_PAGE" = "200" ]; then
    echo "✅ Project dashboard is accessible"
else
    echo "❌ Project dashboard access issue"
fi
echo ""

echo "6. 📋 Troubleshooting Steps:"
echo "----------------------------"
echo "If you still can't see the project in GUI:"
echo ""
echo "a) Clear browser cache and cookies"
echo "b) Try incognito/private browsing mode"
echo "c) Check if you're logged in to SonarQube"
echo "d) Verify the project URL: $SONAR_URL/dashboard?id=$PROJECT_KEY"
echo "e) Look in 'Projects' section after logging in"
echo ""

echo "7. 🔗 Direct Links:"
echo "-------------------"
echo "• SonarQube Home: $SONAR_URL"
echo "• Login Page: $SONAR_URL/sessions/new"
echo "• Projects List: $SONAR_URL/projects"
echo "• Demo Website Project: $SONAR_URL/dashboard?id=$PROJECT_KEY"
echo ""

echo "8. 📱 Browser Access Test:"
echo "--------------------------"
echo "Run this command to test if you can access from your browser:"
echo "curl -v '$SONAR_URL' 2>&1 | grep -E 'HTTP|Connected'"
curl -v "$SONAR_URL" 2>&1 | grep -E "HTTP|Connected" | head -3
echo ""

echo "🎯 SUMMARY:"
echo "----------"
if [ -f "/tmp/demo-website/.scannerwork/report-task.txt" ]; then
    echo "✅ SonarQube analysis completed successfully"
    echo "✅ Project 'demo-website' should be visible in GUI"
    echo "🔑 You need to LOGIN to SonarQube to see the project"
    echo "🌐 Direct URL: $SONAR_URL/dashboard?id=$PROJECT_KEY"
else
    echo "❌ No SonarQube analysis found - run Jenkins pipeline first"
fi
