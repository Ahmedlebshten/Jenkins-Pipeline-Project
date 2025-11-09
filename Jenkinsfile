pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        SONAR_TOKEN           = credentials('sonar-token')
    }

    tools {
        sonarScanner 'SonarScanner'
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Checking out repository..."
                git branch: 'master', url: 'https://github.com/Ahmedlebshten/Jenkins-Pipeline-Project'
            }
        }

        stage('Security Scan - Gitleaks') {
            steps {
                echo "Running Gitleaks to detect secrets..."
                sh '''
                    gitleaks detect --source . --no-git --report-path=gitleaks-report.json || true
                '''
                echo "Gitleaks scan completed. Report generated: gitleaks-report.json"
            }
        }

        stage('Code Quality - SonarQube Analysis') {
            steps {
                echo "Running SonarQube analysis..."
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=EKS-Infrastructure \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://<EC2-Public-IP>:9000 \
                        -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Terraform Format Check') {
            steps {
                echo "Checking Terraform format..."
                sh 'terraform fmt -check'
            }
        }

        stage('Terraform Validate') {
            steps {
                echo "Validating Terraform configuration..."
                sh '''
                    terraform init -backend=false
                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "Creating Terraform plan..."
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Do you want to apply these changes?', ok: 'Yes, apply'
                echo "Applying Terraform plan..."
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check the console output for details."
        }
    }
}
