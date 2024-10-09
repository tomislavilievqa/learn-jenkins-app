pipeline {
    // Define the agent where the pipeline will run. 
    //agent any: The entire pipeline (or a stage) can run on any available agent.
    //Purpose: Specifies that the pipeline can run on any available Jenkins agent (also referred to as a "node"). 
    //In Jenkins, agents are machines or environments where builds can be executed.
    //This means that the pipeline will execute on any node, whether it's a physical machine, virtual machine, or container that Jenkins has access to.
    agent any

    environment{
        NETLIFY_SITE_ID = 'be8c400e-466c-4095-855e-c94f6e771e66'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {
        // Build stage: This stage is responsible for building the project.
        stage('Build stage') {
            //Allows you to define more specific details about the environment or agent on which a stage will run.
            //This specifies that the "Build stage" should run in a Docker container that uses the node:18-alpine image.
            agent {
                // Use a Docker container with Node.js 18 (Alpine version) for this stage.
                docker {
                    image 'node:18-alpine'
                    //Here, Jenkins will run the Docker container on the same node that was used to initiate the stage, 
                    //reusing the workspace and other configurations already set up on that node.
                    //Explanation: When using Docker as an agent, typically, Jenkins starts a new Docker container and runs all the steps in that container. 
                    //By setting reuseNode true, Jenkins reuses the same underlying Jenkins node (or machine) to host the Docker container. 
                    //This avoids setting up a new environment from scratch each time a new container is started, which can save time and resources.
                    reuseNode true
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
                                reportName: 'Playwright Local Report', reportTitles: '', 
                                useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }

        stage('Deploy Staging') {
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
                   npm install netlify-cli node-jq
                   node_modules/.bin/netlify -- version
                   echo "Deploying to staging. Side ID: $NETLIFY_SITE_ID"
                   node_modules/.bin/netlify status
                   
                   # Deploying the build folder to production
                   node_modules/.bin/netlify deploy --dir=build -json > deploy-output.json
                   node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json
                    '''             
            }
        }

        stage('Approval') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Ready for deploy?', ok: 'Yes, it is ready to be deployed!'
                }
            }
        }

        stage('Deploy Production') {
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
                   echo 'Small change'
                   npm install netlify-cli
                   node_modules/.bin/netlify
                   node_modules/.bin/netlify --version
                   echo "Deploying to production. Side ID: $NETLIFY_SITE_ID"
                   node_modules/.bin/netlify status
                   
                   # Deploying the build folder to production
                   node_modules/.bin/netlify deploy --dir=build --prod 
                    '''             
            }
        }

        stage('Production E2E') {
            agent {
                // Use a Docker container with Playwright (version 1.47.0) for this stage.
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true // Reuse the same agent node for the Docker container.
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'https://kaleidoscopic-entremet-8e2fea.netlify.app'
            }

            steps {
                script {
                    // Run a series of shell commands inside the Docker container.
                    sh '''
                    npx playwright test --reporter=html
                    '''
                }
            }
            post {
                always {
                    // Publish Playwright HTML report regardless of the build outcome
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, 
                        reportDir: 'playwright-report', reportFiles: 'index.html', 
                        reportName: 'Playwright Production E2E Report', reportTitles: '', 
                        useWrapperFileDirectly: true])
                }
            }
        }

        



    }
}
