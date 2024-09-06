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
                    if [ -f build/index.html ]; then
                        echo "index.html file exists."
                    else
                        echo "index.html file is missing!"
                        exit 1
                    fi

                    # Run npm tests
                    npm test
                    '''
                }
            }
        }
    }
}