pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = 'spring-app-cluster'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/joannedada/Spring-Boot-API.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Docker Build & Push') {
    steps {
        script {
            // Login to Docker Registry (Docker Hub or Private)
            withCredentials([usernamePassword(
                credentialsId: 'docker-hub-creds',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )]) {
                sh "docker login -u $DOCKER_USER -p $DOCKER_PASS"
            }
            
            // Build and push
            docker.build("joannedada/spring-app:${env.BUILD_ID}")
            docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
                docker.image("joannedada/spring-app:${env.BUILD_ID}").push()
            }
        }
    }
}
        stage('Deploy to EKS') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'eks-credentials',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
            sh """
                aws eks update-kubeconfig --name spring-app-cluster --region us-east-1
                kubectl apply -f kubernetes/deployment.yaml
                kubectl apply -f kubernetes/service.yaml
                kubectl apply -f kubernetes/ingress.yaml
            """
        }
    }
}
    }
}