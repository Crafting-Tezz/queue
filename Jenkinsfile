// CI/CD pipeline for the queue microservice (doc pages 69-76, updated):
//  - images go to Docker Hub user motez00, logged in with the 'dockerhub' Jenkins credential
//  - deploys only this service's manifest (k8s/deployment.yaml)
def commit_id

pipeline {
    agent any

    environment {
        IMAGE = 'motez00/fleetman-queue'
    }

    stages {
        stage('Preparation') {
            steps {
                checkout scm
                sh 'git rev-parse --short HEAD > .git/commit-id'
                script {
                    commit_id = readFile('.git/commit-id').trim()
                }
            }
        }

        stage('Image Build') {
            steps {
                echo "Building ${IMAGE}:${commit_id}"
                sh "docker build -t ${IMAGE}:${commit_id} -t ${IMAGE}:latest ."
            }
        }

        stage('Image Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_TOKEN')]) {
                    // single quotes: the shell expands the secret, Groovy never sees it
                    sh 'echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh "docker push ${IMAGE}:${commit_id}"
                    sh "docker push ${IMAGE}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying to Kubernetes'
                sh "sed -i 's|${IMAGE}:.*|${IMAGE}:${commit_id}|' k8s/deployment.yaml"
                sh 'kubectl apply -f k8s/'
                sh 'kubectl rollout status deployment/queue --timeout=180s'
                sh 'kubectl get pods -l app=queue -o wide'
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
