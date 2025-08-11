# SonarQube Integration Setup Guide

## 🔍 Issue Identified
Your pipeline is working successfully, but SonarQube analysis is failing due to **authentication requirements**.

**Error**: `Not authorized. Analyzing this project requires authentication.`

## 🔧 Solution Options

### Option 1: Configure Authentication (Recommended for Production)

#### Step 1: Create SonarQube Token
1. Open SonarQube: http://192.168.47.147:9000
2. Login with admin credentials (default: `admin`/`admin`)
3. Go to: **My Account** → **Security** → **Generate Tokens**
4. Create token:
   - Name: `jenkins-demo-website`
   - Type: `User Token`
   - Expires: `No expiration` (for demo)
5. **Copy the generated token** (you won't see it again!)

#### Step 2: Add Token to Jenkins Credentials
1. Go to Jenkins: http://localhost:8080
2. Navigate to: **Manage Jenkins** → **Manage Credentials**
3. Click: **(global)** → **Add Credentials**
4. Configure:
   - Kind: `Secret text`
   - Secret: `[paste your SonarQube token]`
   - ID: `sonar-token`
   - Description: `SonarQube Authentication Token`
5. Click **OK**

#### Step 3: Configure SonarQube Server in Jenkins
1. Go to: **Manage Jenkins** → **Configure System**
2. Find: **SonarQube servers** section
3. Click **Add SonarQube**
4. Configure:
   - Name: `SonarQ`
   - Server URL: `http://192.168.47.147:9000`
   - Server authentication token: Select `sonar-token` from dropdown
5. Click **Save**

### Option 2: Disable Authentication (Demo/Development Only)

⚠️ **WARNING**: Only for demo environments!

1. Login to SonarQube as admin: http://192.168.47.147:9000
2. Go to: **Administration** → **Security** → **General**
3. Turn **OFF** "Force user authentication"
4. Click **Save**

## 🧪 Testing the Fix

### Manual Test (with token):
```bash
cd /tmp/demo-website-repo
/var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQ/bin/sonar-scanner \
  -Dsonar.projectKey=demo-website \
  -Dsonar.projectName="DevOps Demo Website" \
  -Dsonar.projectVersion=1.0 \
  -Dsonar.sources=. \
  -Dsonar.exclusions="node_modules/**,**/*.min.js,**/*.min.css,Dockerfile,nginx.conf" \
  -Dsonar.host.url=http://192.168.47.147:9000 \
  -Dsonar.token=YOUR_TOKEN_HERE
```

### Jenkins Pipeline Test:
After configuring authentication, run your Jenkins pipeline again. The SonarQube stage should now work.

## 📊 Expected Results

After successful authentication setup:

1. **Jenkins Console**: Should show successful SonarQube analysis
2. **SonarQube Dashboard**: Project should appear at http://192.168.47.147:9000/dashboard?id=demo-website
3. **Quality Gate**: Should show pass/fail status

## 🔍 Troubleshooting

### If SonarQube still doesn't show results:

1. **Check Jenkins Console Output**:
   - Look for "SonarQube analysis completed"
   - Check for any error messages in the SonarQube stage

2. **Verify SonarQube Server Configuration**:
   - Jenkins → Configure System → SonarQube servers
   - Test connection button should show success

3. **Check SonarQube Logs**:
   ```bash
   docker logs [sonarqube-container-name]
   ```

4. **Verify Project Creation**:
   - Go to SonarQube → Projects
   - Look for "demo-website" project

## 🎯 Quick Verification Commands

```bash
# Check SonarQube server status
curl -s http://192.168.47.147:9000/api/system/status

# Check if project exists
curl -s "http://192.168.47.147:9000/api/projects/search?projects=demo-website"

# Check authentication status
curl -s "http://192.168.47.147:9000/api/authentication/validate"
```

## 📝 Next Steps

1. Choose authentication option (Option 1 recommended)
2. Follow the setup steps
3. Run Jenkins pipeline again
4. Verify results in SonarQube dashboard
5. Check quality gate status

## 🔗 Useful Links

- SonarQube Dashboard: http://192.168.47.147:9000
- Jenkins Configuration: http://localhost:8080/configure
- Project Dashboard: http://192.168.47.147:9000/dashboard?id=demo-website (after setup)
