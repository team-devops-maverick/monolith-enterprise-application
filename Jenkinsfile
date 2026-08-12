pipeline {
    agent any

    tools {
        jdk 'JDK-17'
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
                    mvn clean verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar\
                    -Dsonar.projectKey=snowman \
                    -Dsonar.projectName='snowman'
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t snowman:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Push Docker Image to GHCR') {
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
                 docker login myacr.azurecr.io \
                          -u "$AZURE_CLIENT_ID" \
                          -p "$AZURE_CLIENT_SECRET"
                docker tag snowman:${BUILD_NUMBER} myacr.azurecr.io/snowman:${BUILD_NUMBER}
                docker push myacr.azurecr.io/snowman:${BUILD_NUMBER}
                    '''
                }
            }
        }
    }
}
