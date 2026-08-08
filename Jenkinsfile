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
        stage('Docker Build') {
    steps {
        sh '''
            docker build -t snowman:${BUILD_NUMBER} .
        '''
    }
}
        tage('Push Docker Image to GHCR') {
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
                    ${IMAGE_NAME}:${IMAGE_TAG} \
                    ghcr.io/team-devops-maverick/snowman:${IMAGE_TAG}

                docker push \
                    ghcr.io/team-devops-maverick/snowman:${IMAGE_TAG}
            '''
        }
    }
}
    }
}
