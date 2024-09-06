pipeline {
    agent any

    stages {
        stage('Without Docker') {
            steps {
                sh 'echo Without Docker'
            }
        }
        
        stage('With Docker') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                script {
                    // Unset DOCKER_HOST to ensure the local Docker daemon is used
                    sh 'unset DOCKER_HOST'
                    sh 'echo With Docker'
                    sh 'node -v'
                    sh 'npm --version'
                }
            }
        }
    }
}