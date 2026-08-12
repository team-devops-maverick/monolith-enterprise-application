pipeline {
    agent any

    tools {
        jdk 'JDK-8'
    }

    environment {
        IMAGE_NAME = 'snowman'
        APP_PORT = '8050'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Check Java') {
            steps {
                sh '''
                    echo "JAVA_HOME=$JAVA_HOME"
                    java -version
                    mvn -version
                '''
            }
        }

        stage('Get Application Version') {
            steps {
                script {
                    env.IMAGE_TAG = sh(
                        script: '''
                            mvn help:evaluate \
                              -Dexpression=project.version \
                              -q \
                              -DforceStdout
                        ''',
                        returnStdout: true
                    ).trim()

                    if (!env.IMAGE_TAG) {
                        error "Version not found in pom.xml"
                    }

                    echo "Application version: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Package') {
            steps {
                sh '''
                    mvn clean install -DskipTests
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                 export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
                export PATH="$JAVA_HOME/bin:$PATH"

                java -version

                mvn org.sonarsource.scanner.maven:sonar-maven-plugin:5.7.0.6970:sonar \
                  -DskipTests \
                  -Dsonar.projectKey=snowman \
                  -Dsonar.projectName=snowman
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                      -t ${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'acr-service-principal',
                        usernameVariable: 'AZURE_CLIENT_ID',
                        passwordVariable: 'AZURE_CLIENT_SECRET'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "$AZURE_CLIENT_SECRET" | docker login teammaverick.azurecr.io \
                          --username "$AZURE_CLIENT_ID" \
                          --password-stdin

                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} \
                          teammaverick.azurecr.io/snowman:${IMAGE_TAG}

                        docker push \
                          teammaverick.azurecr.io/snowman:${IMAGE_TAG}
                    '''
                }
            }
        }
    }
}
