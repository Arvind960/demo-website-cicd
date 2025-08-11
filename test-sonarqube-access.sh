#!/bin/bash

echo "🧪 Testing SonarQube Project Access"
echo "==================================="
echo ""

SONAR_URL="http://192.168.47.147:9000"

echo "Testing with default admin credentials..."
echo ""

# Test with default admin/admin credentials
AUTH_HEADER=$(echo -n "admin:admin" | base64)

echo "1. Testing authentication with admin/admin:"
curl -s -H "Authorization: Basic $AUTH_HEADER" "$SONAR_URL/api/authentication/validate" | python3 -c "import sys, json; data=json.load(sys.stdin); print('Valid:', data.get('valid', False))"

echo ""
echo "2. Testing projects list with authentication:"
PROJECTS=$(curl -s -H "Authorization: Basic $AUTH_HEADER" "$SONAR_URL/api/projects/search")
echo "$PROJECTS" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    total = data.get('paging', {}).get('total', 0)
    print(f'Total projects found: {total}')
    for project in data.get('components', []):
        print(f'  - {project[\"key\"]}: {project[\"name\"]}')
except:
    print('Could not parse projects response')
"

echo ""
echo "3. Direct project access test:"
echo "Testing demo-website project..."
DEMO_PROJECT=$(curl -s -H "Authorization: Basic $AUTH_HEADER" "$SONAR_URL/api/projects/search?projects=demo-website")
echo "$DEMO_PROJECT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    components = data.get('components', [])
    if components:
        project = components[0]
        print(f'✅ Project found: {project[\"name\"]} (Key: {project[\"key\"]})')
        print(f'   Last analysis: {project.get(\"lastAnalysisDate\", \"Unknown\")}')
    else:
        print('❌ demo-website project not found')
except Exception as e:
    print(f'Error parsing response: {e}')
"

echo ""
echo "4. 🌐 Browser Access Instructions:"
echo "If authentication works above, access via browser:"
echo "   1. Open: $SONAR_URL"
echo "   2. Login: admin / admin"
echo "   3. Go to: Projects → demo-website"
echo "   4. Or direct: $SONAR_URL/dashboard?id=demo-website"
