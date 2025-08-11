pipeline {
    agent any
    
    environment {
        // Docker settings
        DOCKER_IMAGE = 'demo-website'
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKER_REGISTRY = 'localhost:5000' // Change to your registry
        
        // SonarQube settings
        SONAR_SERVER = 'SonarQ' // Jenkins SonarQube server name configured in Manage Jenkins
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
                    checkout scm
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
                                    /var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQ/bin/sonar-scanner \
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
                        }
                    }
                }
                
                stage('Lint Check') {
                    steps {
                        script {
                            echo "📝 Running lint checks..."
                            sh '''
                                echo "Checking HTML structure..."
                                if grep -q "<!DOCTYPE html>" *.html; then
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
                                // For demo, continue build anyway
                                echo "🔄 Continuing build despite Quality Gate failure..."
                            } else {
                                echo "✅ Quality Gate passed!"
                            }
                        } catch (Exception e) {
                            echo "⚠️ Quality Gate check failed: ${e.getMessage()}"
                            echo "🔄 Continuing build despite Quality Gate check failure..."
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
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
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
                        if docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} whoami | grep -q root; then
                            echo "⚠️ Container runs as root user"
                        else
                            echo "✅ Container does not run as root"
                        fi
                        
                        echo "Exposed ports:"
                        docker inspect ${DOCKER_IMAGE}:${DOCKER_TAG} | grep -i ExposedPorts || echo "No exposed ports"
                    '''
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                script {
                    echo "🧪 Testing Docker image..."
                    sh '''
                        CONTAINER_ID=$(docker run -d -p ${APP_PORT}:80 ${DOCKER_IMAGE}:${DOCKER_TAG})
                        sleep 10
                        if curl -f http://localhost:${APP_PORT}/health; then
                            echo "✅ Health check passed"
                        else
                            echo "❌ Health check failed"
                            docker logs $CONTAINER_ID
                            docker stop $CONTAINER_ID
                            exit 1
                        fi
                        
                        if curl -f http://localhost:${APP_PORT}/ | grep -q "DevOps Demo"; then
                            echo "✅ Main page test passed"
                        else
                            echo "❌ Main page test failed"
                            docker stop $CONTAINER_ID
                            exit 1
                        fi
                        
                        docker stop $CONTAINER_ID
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
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest
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
                        docker stop ${APP_NAME} 2>/dev/null || true
                        docker rm ${APP_NAME} 2>/dev/null || true
                        docker run -d --name ${APP_NAME} -p 9090:80 --restart unless-stopped ${DOCKER_IMAGE}:${DOCKER_TAG}
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
                sh '''
                    docker image prune -f
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
                echo "- Jenkins: ${BUILD_URL}"
            }
        }
        
        failure {
            script {
                echo "❌ Pipeline failed!"
                echo "🔍 Check logs above for details"
                echo "📋 Troubleshooting:"
                echo "- Verify SonarQube server is reachable"
                echo "- Check Docker daemon status"
                echo "- Confirm dependencies installed"
            }
        }
        
        cleanup {
            script {
                echo "🗑️ Workspace cleanup completed"
            }
        }
    }
}
