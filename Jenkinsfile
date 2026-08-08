pipeline {

    agent any
    tools {
        jdk 'JDK8'
        maven 'Maven3'
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

        stage('Build & Unit Test') {
            steps {
                sh '''
                    mvn clean test
                '''
            }
        }

        stage('Package') {
            steps {
                sh '''
                    mvn package -DskipTests
                '''
            }
        }
    }
}
