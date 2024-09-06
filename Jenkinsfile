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

        stage('Tests') {
            parallel {
                // Unit Tests stage: This stage is for running unit tests.
                stage('Unit Tests') {
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
                    post {
                        always {
                            // Publish JUnit test results regardless of the build outcome
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                // E2E stage: This stage is for end-to-end testing.
                stage('E2E') {
                    agent {
                        // Use a Docker container with Playwright (version 1.47.0) for this stage.
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
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
                            npx playwright test --reporter=html
                            '''
                        }
                    }
                    post {
                        always {
                            // Publish Playwright HTML report regardless of the build outcome
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, 
                                reportDir: 'playwright-report', reportFiles: 'index.html', 
                                reportName: 'Playwright HTML Report', reportTitles: '', 
                                useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            agent {
                // Use a Docker container with Node.js 18 (Alpine version) for this stage.
                docker {
                    image 'node:18-alpine'
                    reuseNode true // Reuse the same agent node for the Docker container.
                }
            }
            steps {
                    // Run a series of shell commands inside the Docker container.               
                   sh '''
                   npm install netlify-cli
                   node_modules/.bin/netlify
                   netlify --version
                    '''             
            }
        }
    }
}
