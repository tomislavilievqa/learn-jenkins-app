pipeline {
    // Define the agent where the pipeline will run.
    agent any

    stages {
        // Build stage: This stage is responsible for building the project.
        stage('Build stage') {
            agent {
                // Use a Docker container with Node.js 18 (Alpine version) for this stage.
                docker {
                    image 'node:18-alpine'
                    reuseNode true // Reuse the same agent node for the Docker container.
                }
            }
            steps {
                script {
                    // Run a series of shell commands inside the Docker container.
                    sh '''
                    # List all files and directories with detailed info
                    ls -la
                    
                    # Display the installed Node.js version
                    node --version
                    
                    # Display the installed npm version
                    npm --version
                    
                    # Install dependencies based on package-lock.json
                    npm ci
                    
                    # Run the build script defined in package.json
                    npm run build
                    
                    # List files again to check the build output
                    ls -la
                    '''
                }
            }
        }
        
        // Test stage: This stage is for running tests.
        stage('Test stage') {
            agent {
                // Use a Docker container with Node.js 18 (Alpine version) for this stage.
                docker {
                    image 'node:18-alpine'
                    reuseNode true // Reuse the same agent node for the Docker container.
                }
            }
            steps {
                script {
                    // Run a series of shell commands inside the Docker container.
                    sh '''
                    # Check if index.html exists in the build directory
                    test -f build/index.html

                    # Run tests defined in package.json
                    npm test
                    '''
                }
            }
        }

        // E2E stage: This stage is for end-to-end testing.
        stage('E2E') {
            agent {
                // Use a Docker container with Playwright (version 1.47.0) for this stage.
                docker {
                    image 'mcr.microsoft.com/playwright:v1.47.0-noble'
                    reuseNode true // Reuse the same agent node for the Docker container.
                }
            }
            steps {
                script {
                    // Run a series of shell commands inside the Docker container.
                    sh '''
                    # Install the serve package globally to serve the build output
                    npm install serve
                    
                    # Serve the build directory and run it in the background
                    node_modules/.bin/serve -s build &
                    
                    # Wait for 10 seconds to ensure the server starts up
                    sleep 10
                    
                    # Run end-to-end tests with Playwright
                    npx playwright test
                    '''
                }
            }
        }
    }

    post {
        always {
            // Publish JUnit test results regardless of the build outcome
            junit 'jest-results/junit.xml'
        }
    }
}
