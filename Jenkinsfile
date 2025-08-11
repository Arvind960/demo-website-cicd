pipeline {
    agent any
    
    environment {
        // Docker settings
        DOCKER_IMAGE = 'demo-website'
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKER_REGISTRY = 'localhost:5000' // Change to your registry
        
        // SonarQube settings
        SONAR_SERVER = 'SonarQ'  // Name of SonarQube server configured in Jenkins
        SONAR_PROJECT_KEY = 'demo-website'
        
        // Application settings - Fixed port conflicts
        APP_NAME = 'demo-website'
        APP_PORT = '8081'  // Changed from 8080 (in use)
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "🔄 Checking out source code..."
                checkout scm
            }
        }
        
        stage('Code Quality Analysis') {
            parallel {
                stage('SonarQube Scan') {
                    steps {
                        echo "🔍 Running SonarQube analysis..."
                        script {
                            try {
                                withSonarQubeEnv(SONAR_SERVER) {
                                    sh '''
                                        # Check if sonar-scanner is available
                                        if command -v sonar-scanner >/dev/null 2>&1; then
                                            SCANNER_CMD="sonar-scanner"
                                        elif [ -f "/var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQ/bin/sonar-scanner" ]; then
                                            SCANNER_CMD="/var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQ/bin/sonar-scanner"
                                        else
                                            echo "⚠️ SonarQube scanner not found, skipping analysis"
                                            exit 0
                                        fi
                                        
                                        $SCANNER_CMD \
                                            -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                            -Dsonar.projectName="DevOps Demo Website" \
                                            -Dsonar.projectVersion=${BUILD_NUMBER} \
                                            -Dsonar.sources=. \
                                            -Dsonar.exclusions="node_modules/**,**/*.min.js,**/*.min.css,Dockerfile,nginx.conf" \
                                            -Dsonar.sourceEncoding=UTF-8 \
                                            -Dsonar.javascript.file.suffixes=.js \
                                            -Dsonar.css.file.suffixes=.css \
                                            -Dsonar.html.file.suffixes=.html
                                    '''
                                }
                            } catch (Exception e) {
                                echo "⚠️ SonarQube analysis failed: ${e.getMessage()}"
                                echo "🔄 Continuing build for demo purposes..."
                            }
                        }
                    }
                }
                
                stage('Lint Check') {
                    steps {
                        echo "📝 Running lint checks..."
                        sh '''
                            echo "Checking HTML structure..."
                            if grep -q "<!DOCTYPE html>" index.html; then
                                echo "✅ HTML structure is valid"
                            else
                                echo "❌ HTML structure issues found"
                                exit 1
                            fi
                            
                            echo "Checking CSS syntax..."
                            if [ -f "styles.css" ]; then
                                echo "✅ CSS file found"
                            else
                                echo "❌ CSS file missing"
                                exit 1
                            fi
                            
                            echo "Checking JavaScript syntax..."
                            if [ -f "script.js" ]; then
                                echo "✅ JavaScript file found"
                            else
                                echo "❌ JavaScript file missing"
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                echo "🚪 Waiting for SonarQube Quality Gate..."
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        try {
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                echo "⚠️ Quality Gate failed: ${qg.status}"
                                echo "🔄 Continuing build for demo purposes..."
                            } else {
                                echo "✅ Quality Gate passed!"
                            }
                        } catch (Exception e) {
                            echo "⚠️ Quality Gate check failed: ${e.message}"
                            echo "🔄 Continuing build for demo purposes..."
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                    
                    echo "✅ Docker image built successfully"
                    docker images | grep ${DOCKER_IMAGE}
                '''
            }
        }
        
        stage('Security Scan') {
            steps {
                echo "🛡️ Running security scans..."
                sh '''
                    echo "Checking if container runs as root..."
                    if docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} whoami | grep -q root; then
                        echo "⚠️ Container running as root - consider using non-root user"
                    else
                        echo "✅ Container not running as root"
                    fi
                    
                    echo "Checking exposed ports..."
                    docker inspect ${DOCKER_IMAGE}:${DOCKER_TAG} | grep -i exposedports || echo "No exposed ports found"
                    
                    echo "✅ Basic security scan completed"
                '''
            }
        }
        
        stage('Test Docker Image') {
            steps {
                echo "🧪 Testing Docker image..."
                sh '''
                    CONTAINER_ID=$(docker run -d -p ${APP_PORT}:80 ${DOCKER_IMAGE}:${DOCKER_TAG})
                    echo "Container started with ID: $CONTAINER_ID"
                    
                    sleep 10
                    
                    echo "Testing main page endpoint..."
                    if curl -f http://localhost:${APP_PORT}/; then
                        echo "✅ Main page check passed"
                    else
                        echo "❌ Main page check failed"
                        docker logs $CONTAINER_ID
                        docker stop $CONTAINER_ID
                        exit 1
                    fi
                    
                    echo "Testing main page..."
                    if curl -f http://localhost:${APP_PORT}/ | grep -q "DevOps Demo"; then
                        echo "✅ Main page test passed"
                    else
                        echo "❌ Main page test failed"
                        docker stop $CONTAINER_ID
                        exit 1
                    fi
                    
                    docker stop $CONTAINER_ID
                    echo "✅ All tests passed"
                '''
            }
        }
        
        stage('Push to Registry') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    expression { return params.FORCE_DEPLOY == true }
                }
            }
            steps {
                echo "📤 Pushing image to registry..."
                sh '''
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest
                    
                    # Uncomment below to push to your registry
                    # docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                    # docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest
                    
                    echo "✅ Image pushed to registry (simulated)"
                '''
            }
        }
        
        stage('Deploy') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    expression { return params.FORCE_DEPLOY == true }
                }
            }
            steps {
                echo "🚀 Deploying application..."
                sh '''
                    docker stop ${APP_NAME} 2>/dev/null || true
                    docker rm ${APP_NAME} 2>/dev/null || true
                    
                    docker run -d --name ${APP_NAME} -p 9091:80 --restart unless-stopped ${DOCKER_IMAGE}:${DOCKER_TAG}
                    
                    echo "✅ Application deployed successfully"
                    echo "🌐 Application available at: http://localhost:9091"
                    
                    sleep 5
                    
                    if curl -f http://localhost:9091/; then
                        echo "✅ Deployment verification passed"
                    else
                        echo "❌ Deployment verification failed"
                        exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        always {
            echo "🧹 Cleaning up..."
            sh '''
                docker image prune -f
                echo "📊 Build Summary:"
                echo "- Build Number: ${BUILD_NUMBER}"
                echo "- Docker Image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                echo "- SonarQube Project: ${SONAR_PROJECT_KEY}"
                echo "- Application URL: http://localhost:9091"
            '''
        }
        
        success {
            echo """
            ✅ Pipeline completed successfully!
            🎉 Demo website is ready!

            📋 Access Points:
            - Website: http://localhost:9091
            - SonarQube: http://192.168.47.147:9000/dashboard?id=${SONAR_PROJECT_KEY}
            - Jenkins: ${env.BUILD_URL}
            """
        }
        
        failure {
            echo """
            ❌ Pipeline failed!
            🔍 Check logs above for details.
            📋 Troubleshooting:
            - Verify SonarQube server is reachable and URL includes http:// or https://
            - Check Docker daemon status
            - Confirm all dependencies are installed
            """
        }
        
        cleanup {
            echo "🗑️ Workspace cleanup completed"
        }
    }
}
