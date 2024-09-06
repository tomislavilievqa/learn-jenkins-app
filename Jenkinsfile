pipeline {
    agent any

    stages {
        stage('Build stage') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                script {
                    sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                    '''
                }
            }
        }
        
        stage('Test stage') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                script {
                    sh '''
                    # Verify if index.html exists in the build directory
                    test -f build/index.html

                    # Run npm tests
                    npm test
                    '''
                }
            }
        }

                stage('E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.47.0-noble'
                    reuseNode true
                    args '-u root:root'
                }
            }
            steps {
                script {
                    sh '''
                    npm install -g serve
                    node_modules/.bin/serve -s build &
                    sleep 10
                    npx playwright test
                    '''
                }
            }
        }
    }

    post {
        always {
            junit 'jest-results/junit.xml'
        }
    }
}