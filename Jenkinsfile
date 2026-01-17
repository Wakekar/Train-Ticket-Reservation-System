pipeline {
    agent any

    tools {
        jdk 'java'        // Configure in Jenkins → Global Tool Configuration
        maven 'maven'
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                checkout scm
                echo '✅ Source code checked out'
            }
        }

        stage('Verify Tools') {
            steps {
                sh '''
                    java -version
                    mvn -version
                '''
            }
        }

        stage('Build with Maven') {
            steps {
                sh '''
                    mvn clean package -DskipTests
                '''
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }

    post {
        success {
            echo '✅ CI pipeline completed successfully'
        }
        failure {
            echo '❌ CI pipeline failed'
        }
    }
}
