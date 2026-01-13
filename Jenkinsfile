pipeline {
    agent any

    environment {
        DEPLOY_DIR = "/var/www/html"
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                git url: 'https://github.com/Wakekar/Train-Ticket-Reservation-System.git',
                    branch: 'main'
            }
        }

        stage('Validate Project Files (CI)') {
            steps {
                sh '''
                echo "Checking project files..."

                if [ -f index.html ]; then
                    echo "index.html found ✅"
                else
                    echo "index.html NOT found ❌"
                    exit 1
                fi
                '''
            }
        }

        stage('Static Code Check (CI)') {
            steps {
                sh '''
                echo "Listing project files:"
                ls -l
                '''
            }
        }

        stage('Install Web Server (CD)') {
            steps {
                sh '''
                if ! command -v nginx >/dev/null; then
                    echo "Installing Nginx..."
                    sudo apt-get update
                    sudo apt-get install -y nginx
                else
                    echo "Nginx already installed"
                fi
                '''
            }
        }

        stage('Deploy Application (CD)') {
            steps {
                sh '''
                echo "Deploying application..."

                sudo rm -rf ${DEPLOY_DIR}/*
                sudo cp -r ./* ${DEPLOY_DIR}/

                sudo systemctl restart nginx

                echo "Deployment completed successfully 🚀"
                '''
            }
        }
    }

    post {
        success {
            echo "CI/CD Pipeline executed successfully ✅"
        }
        failure {
            echo "Pipeline failed ❌"
        }
    }
}
