pipeline {

    agent any

    tools {
        jdk 'JDK8'
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
                mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                  -Dsonar.projectKey=snowman \
                  -Dsonar.projectName=Snowman
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
                    string(
                        credentialsId: 'github-token',
                        variable: 'GITHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "$GITHUB_TOKEN" | docker login ghcr.io \
                            -u vinaykumarshetkar \
                            --password-stdin

                        docker tag \
                            snowman:${BUILD_NUMBER} \
                            ghcr.io/team-devops-maverick/snowman:${BUILD_NUMBER}

                        docker push \
                            ghcr.io/team-devops-maverick/snowman:${BUILD_NUMBER}
                    '''
                }
            }
        }
    }
}
