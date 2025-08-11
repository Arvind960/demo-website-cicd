# 🚀 Deployment Guide

## Quick Deployment

### Local Development
```bash
# Clone repository
git clone <your-repo-url>
cd demo-website

# Build and run with Docker
docker build -t demo-website .
docker run -d -p 8080:80 --name demo-website demo-website
```

### Jenkins Pipeline Deployment

1. **Create Jenkins Pipeline Job**
   - New Item → Pipeline
   - Pipeline script from SCM
   - Repository URL: Your GitHub repository
   - Script Path: Jenkinsfile

2. **Configure SonarQube**
   - Manage Jenkins → Configure System
   - SonarQube servers section
   - Add server: http://your-sonarqube-server:9000

3. **Set up Credentials**
   - Manage Jenkins → Credentials
   - Add SonarQube token with ID: 'SonarQ'

4. **Run Pipeline**
   - Build Now or Build with Parameters

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DOCKER_IMAGE` | Docker image name | `demo-website` |
| `DOCKER_TAG` | Image tag | `${BUILD_NUMBER}` |
| `SONAR_SERVER` | SonarQube server ID | `SonarQ` |
| `APP_PORT` | Application port | `8080` |

## Production Deployment

### Prerequisites
- Docker installed
- Jenkins with required plugins
- SonarQube server accessible
- Proper network configuration

### Steps
1. Configure production environment variables
2. Set up production SonarQube project
3. Configure Jenkins for production deployment
4. Run pipeline with production parameters

## Monitoring

### Health Checks
- Application: `http://localhost:8080/health`
- Container: `docker ps` and `docker logs`

### Metrics
- SonarQube dashboard for code quality
- Jenkins build history
- Docker container stats
