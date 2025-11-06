pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/Ahmedlebshten/Jenkins-Pipeline-Project'
            }
        }

        stage('Terraform FMT') {
            steps {
                sh '''
                    cd terraform
                    terraform fmt -check
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                    cd terraform
                    terraform init -backend=false
                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    cd terraform
                    terraform plan
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Apply changes?', ok: 'Yes, apply'
                sh '''
                    cd terraform
                    terraform apply -auto-approve
                '''
            }
        }
    }
}
