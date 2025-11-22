pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = 'hello-devops-production-cluster'
        GIT_BRANCH = 'master'
        GIT_URL = 'https://github.com/Ahmedlebshten/Jenkins-Pipeline-Build-Infra'
    }

    options {
        ansiColor('xterm')
        timestamps()
        skipDefaultCheckout(true)
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "🔹 Checking out repository..."
                // using checkout step is more explicit than shorthand git
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: env.GIT_BRANCH]],
                    userRemoteConfigs: [[url: env.GIT_URL]]
                ])
            }
        }

        stage('Terraform Init') {
            steps {
                echo "🔹 Initializing Terraform..."
                sh '''
                    set -e
                    # ensure terraform binary exists in PATH
                    if ! command -v terraform >/dev/null 2>&1; then
                      echo "terraform not found in PATH"
                      exit 2
                    fi
                    terraform init -reconfigure
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "🔹 Creating Terraform plan..."
                sh '''
                    set -e
                    terraform plan -out=tfplan
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                echo "🔹 Applying Terraform..."
                sh '''
                    set -e
                    terraform apply -auto-approve tfplan
                '''
                echo "✅ Infrastructure deployed successfully!"
            }
        }

        stage('Install ArgoCD + IAM Mapping') {
            steps {
                echo "🔹 Install ArgoCD + IAM mapping (safe-mode)..."
                sh '''
                    set -e

                    # verify required CLIs
                    for cmd in aws kubectl eksctl; do
                      if ! command -v $cmd >/dev/null 2>&1; then
                        echo "$cmd is not installed or not in PATH"
                        exit 2
                      fi
                    done

                    export AWS_REGION="${AWS_REGION}"
                    export CLUSTER_NAME="${CLUSTER_NAME}"

                    echo "🔹 Updating kubeconfig..."
                    aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

                    echo "🔹 Mapping Jenkins EC2 IAM Role to EKS RBAC (idempotent)..."
                    eksctl create iamidentitymapping \
                      --region "$AWS_REGION" \
                      --cluster "$CLUSTER_NAME" \
                      --arn arn:aws:iam::420606830171:role/Jenkins-EC2-Role \
                      --username jenkins-ec2-role \
                      --group system:masters || true

                    echo "🔹 Installing ArgoCD..."
                    kubectl create namespace argocd || true
                    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

                    echo "⏳ Waiting for ArgoCD to become ready..."
                    kubectl -n argocd wait --for=condition=Available deployment/argocd-server --timeout=300s || true

                    echo "🎉 ArgoCD Installed Successfully!"
                '''
            }
        }

        // Uncomment this block only when you want to destroy infra
        /*
        stage('Terraform Destroy') {
            steps {
                echo "🗑️ Destroying Terraform infrastructure..."
                sh '''
                    set -e
                    terraform destroy -auto-approve
                '''
                echo "🔥 Infrastructure destroyed successfully!"
            }
        }
        */
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
        always {
            echo "🔚 Pipeline finished at ${new Date()}"
        }
    }
}
