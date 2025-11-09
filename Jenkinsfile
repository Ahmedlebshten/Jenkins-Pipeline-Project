pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        SONAR_TOKEN           = credentials('sonar-token')
        SONAR_SCANNER_PATH    = '/opt/sonar-scanner/bin/sonar-scanner'
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "🔹 Checking out repository..."
                git branch: 'master', url: 'https://github.com/Ahmedlebshten/Jenkins-Pipeline-Project'
            }
        }

        stage('Security Scan - Gitleaks') {
            steps {
                echo "🔹 Running Gitleaks to detect secrets..."
                sh '''
                    gitleaks detect --source . --no-git --report-path=gitleaks-report.json || true
                '''
                echo "✅ Gitleaks scan completed. Report generated: gitleaks-report.json"
            }
        }

        stage('Code Quality - SonarQube Analysis') {
            steps {
                echo "🔹 Running SonarQube analysis..."
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        $SONAR_SCANNER_PATH \
                        -Dsonar.projectKey=EKS-Infrastructure \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_TOKEN
                    '''
                }
                echo "✅ SonarQube analysis completed."
            }
        }

        stage('Terraform Format Check') {
            steps {
                echo "🔹 Checking Terraform format..."
                sh 'terraform fmt -check'
            }
        }

        stage('Terraform Validate') {
            steps {
                echo "🔹 Validating Terraform configuration..."
                sh '''
                    terraform init -backend=false
                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "🔹 Creating Terraform plan..."
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Apply infrastructure changes?', ok: 'Yes, apply'
                echo "🔹 Applying Terraform plan..."
                sh 'terraform apply -auto-approve tfplan'
                echo "✅ Terraform infrastructure deployed successfully!"
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline executed successfully! EKS cluster is ready."
        }
        failure {
            echo "❌ Pipeline failed. Please check the console output for details."
        }
    }
}
