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
    }
}
