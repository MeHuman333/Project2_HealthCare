pipeline {
  agent any

  environment {
    AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
  }

  stages {
    stage('Build the Project') {
      steps {
        // Check out the source code from Git
        git 'https://github.com/MeHuman333/Project2_HealthCare.git'
        // Run Maven to clean and package the project
        sh 'mvn clean package'
      }
    }
    stage('Build Docker Image') {
      steps {
        script {
          // Build the Docker image
          sh 'docker build -t mehooman/HealthCare:v1 .'
          // List Docker images to confirm build
          sh 'docker images'
        }
      }
    }
    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
          // Log in to Docker Hub
          sh 'echo "$PASS" | docker login -u "$USER" --password-stdin'
          // Push the Docker image to Docker Hub
          sh 'docker push mehooman/HealthCare:v1'
        }
      }
    }
  }
}
