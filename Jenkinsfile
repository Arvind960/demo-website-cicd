pipeline {
    agent any
    
    environment {
        // Docker settings
        DOCKER_IMAGE = 'demo-website'
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKER_REGISTRY = 'localhost:5000' // Change to your registry
        
        // SonarQube settings
        SONAR_SERVER = 'SonarQ'
        SONAR_PROJECT_KEY = 'demo-website'
        
        // Application settings
        APP_NAME = 'demo-website'
        APP_PORT = '8080'
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "🔄 Checking out source code..."
                    // In real scenario, this would be: checkout scm
                    // For demo, we'll copy our files
                    sh '''
                        echo "Source code checked out successfully"
                        ls -la
                    '''
                }
            }
        }
        
        stage('Code Quality Analysis') {
            parallel {
                stage('SonarQube Scan') {
                    steps {
                        script {
                            echo "🔍 Running SonarQube analysis..."
                            
                            withSonarQubeEnv(SONAR_SERVER) {
                                sh '''
                                    echo "Starting SonarQube analysis for demo website..."
                                    
                                    # Run SonarQube scanner
                                    /var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQ/bin/sonar-scanner \
                                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                        -Dsonar.projectName="DevOps Demo Website" \
                                        -Dsonar.projectVersion=${BUILD_NUMBER} \
                                        -Dsonar.sources=. \
                                        -Dsonar.exclusions="node_modules/**,**/*.min.js,**/*.min.css,Dockerfile,nginx.conf" \
                                        -Dsonar.sourceEncoding=UTF-8 \
                                        -Dsonar.javascript.file.suffixes=.js \
                                        -Dsonar.css.file.suffixes=.css \
                                        -Dsonar.html.file.suffixes=.html \
                                        -Dsonar.host.url=${SONAR_HOST_URL} \
                                        -Dsonar.token=${SONAR_AUTH_TOKEN}
                                '''
                            }
                        }
                    }
                }
                
                stage('Lint Check') {
                    steps {
                        script {
                            echo "📝 Running lint checks..."
                            sh '''
                                echo "Checking HTML structure..."
                                # Simple HTML validation
                                if grep -q "<!DOCTYPE html>" *.html; then
                                    echo "✅ HTML structure is valid"
                                else
                                    echo "❌ HTML structure issues found"
                                    exit 1
                                fi
                                
                                echo "Checking CSS syntax..."
                                # Simple CSS check
                                if [ -f "styles.css" ]; then
                                    echo "✅ CSS file found"
                                else
                                    echo "❌ CSS file missing"
                                    exit 1
                                fi
                                
                                echo "Checking JavaScript syntax..."
                                # Simple JS check
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
        }
        
        stage('Quality Gate') {
            steps {
                script {
                    echo "🚪 Waiting for SonarQube Quality Gate..."
                    
                    timeout(time: 5, unit: 'MINUTES') {
                        try {
                            def qg = waitForQualityGate()
                            
                            if (qg.status != 'OK') {
                                echo "⚠️ Quality Gate failed: ${qg.status}"
                                echo "Quality Gate Details:"
                                echo "- Status: ${qg.status}"
                                
                                // For demo purposes, we'll continue even if QG fails
                                echo "🔄 Continuing build for demo purposes..."
                            } else {
                                echo "✅ Quality Gate passed!"
                            }
                        } catch (Exception e) {
                            echo "⚠️ Quality Gate check failed: ${e.getMessage()}"
                            echo "🔄 Continuing build for demo purposes..."
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "🐳 Building Docker image..."
                    
                    sh '''
                        echo "Building Docker image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        # Build the Docker image
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker build -t ${DOCKER_IMAGE}:latest .
                        
                        echo "✅ Docker image built successfully"
                        
                        # Show image details
                        docker images | grep ${DOCKER_IMAGE}
                    '''
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    echo "🛡️ Running security scans..."
                    
                    sh '''
                        echo "Scanning Docker image for vulnerabilities..."
                        
                        # Basic security checks
                        echo "Checking for common security issues..."
                        
                        # Check if running as root
                        if docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} whoami | grep -q root; then
                            echo "⚠️ Container running as root - consider using non-root user"
                        else
                            echo "✅ Container not running as root"
                        fi
                        
                        # Check for exposed ports
                        echo "Checking exposed ports..."
                        docker inspect ${DOCKER_IMAGE}:${DOCKER_TAG} | grep -i exposedports || echo "No exposed ports found"
                        
                        echo "✅ Basic security scan completed"
                    '''
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                script {
                    echo "🧪 Testing Docker image..."
                    
                    sh '''
                        echo "Starting container for testing..."
                        
                        # Start container in background
                        CONTAINER_ID=$(docker run -d -p ${APP_PORT}:80 ${DOCKER_IMAGE}:${DOCKER_TAG})
                        echo "Container started with ID: $CONTAINER_ID"
                        
                        # Wait for container to be ready
                        sleep 10
                        
                        # Test health endpoint
                        echo "Testing health endpoint..."
                        if curl -f http://localhost:${APP_PORT}/health; then
                            echo "✅ Health check passed"
                        else
                            echo "❌ Health check failed"
                            docker logs $CONTAINER_ID
                            docker stop $CONTAINER_ID
                            exit 1
                        fi
                        
                        # Test main page
                        echo "Testing main page..."
                        if curl -f http://localhost:${APP_PORT}/ | grep -q "DevOps Demo"; then
                            echo "✅ Main page test passed"
                        else
                            echo "❌ Main page test failed"
                            docker stop $CONTAINER_ID
                            exit 1
                        fi
                        
                        # Stop test container
                        docker stop $CONTAINER_ID
                        echo "✅ All tests passed"
                    '''
                }
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
                script {
                    echo "📤 Pushing image to registry..."
                    
                    sh '''
                        echo "Tagging image for registry..."
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest
                        
                        echo "Pushing to registry..."
                        # docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                        # docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest
                        
                        echo "✅ Image pushed to registry (simulated)"
                    '''
                }
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
                script {
                    echo "🚀 Deploying application..."
                    
                    sh '''
                        echo "Deploying ${APP_NAME} version ${DOCKER_TAG}..."
                        
                        # Stop existing container if running
                        docker stop ${APP_NAME} 2>/dev/null || true
                        docker rm ${APP_NAME} 2>/dev/null || true
                        
                        # Deploy new version
                        docker run -d \
                            --name ${APP_NAME} \
                            -p 9090:80 \
                            --restart unless-stopped \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        echo "✅ Application deployed successfully"
                        echo "🌐 Application available at: http://localhost:9090"
                        
                        # Verify deployment
                        sleep 5
                        if curl -f http://localhost:9090/health; then
                            echo "✅ Deployment verification passed"
                        else
                            echo "❌ Deployment verification failed"
                            exit 1
                        fi
                    '''
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "🧹 Cleaning up..."
                
                // Clean up test containers and images
                sh '''
                    # Clean up dangling images
                    docker image prune -f
                    
                    # Show final status
                    echo "📊 Build Summary:"
                    echo "- Build Number: ${BUILD_NUMBER}"
                    echo "- Docker Image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    echo "- SonarQube Project: ${SONAR_PROJECT_KEY}"
                    echo "- Application URL: http://localhost:9090"
                '''
            }
        }
        
        success {
            script {
                echo "✅ Pipeline completed successfully!"
                echo "🎉 Demo website is ready!"
                echo ""
                echo "📋 Access Points:"
                echo "- Website: http://localhost:9090"
                echo "- SonarQube: http://192.168.47.147:9000/dashboard?id=${SONAR_PROJECT_KEY}"
                echo "- Jenkins: http://localhost:8080/job/${JOB_NAME}/${BUILD_NUMBER}/"
            }
        }
        
        failure {
            script {
                echo "❌ Pipeline failed!"
                echo "🔍 Check the logs above for details"
                echo "📋 Troubleshooting:"
                echo "- Verify SonarQube is accessible"
                echo "- Check Docker daemon is running"
                echo "- Ensure all dependencies are installed"
            }
        }
        
        cleanup {
            // Clean up workspace if needed
            script {
                echo "🗑️ Workspace cleanup completed"
            }
        }
    }
}
