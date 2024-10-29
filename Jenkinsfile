pipeline {
    agent any

    environment {
        GIT_REPO_URL = 'https://github.com/TaranovPetryxa/web_shop.git'
        BRANCH = 'main'
        CONTAINER_NAME = 'web_shop'
        IMAGE_NAME = 'wordpress_custom'
        DOCKER_HUB_REPO = 'taranovpetryxa/web_shop'
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        PROD_SERVER = '192.168.1.10'
        PROD_DIR = '/home/user/'
        SSH_PORT = '222' // Указываем нестандартный порт
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: "${BRANCH}", url: "${GIT_REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${IMAGE_NAME} .'
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    sh 'docker run -d --name ${CONTAINER_NAME} -p 8080:80 ${IMAGE_NAME}'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    }
                    sh """
                        docker tag ${IMAGE_NAME}:latest ${DOCKER_HUB_REPO}:latest
                        docker push ${DOCKER_HUB_REPO}:latest
                    """
                }
            }
        }

        stage('Deploy to Production Server') {
            steps {
                script {
                    def sshKeyPath = '/root/.ssh/id_rsa'
                    sh """
                    ssh -i ${sshKeyPath} -o StrictHostKeyChecking=no -p ${SSH_PORT} user@${PROD_SERVER} << 'EOF'
                        set -e
                        echo "Deploying to production server at ${PROD_SERVER}..."

                        if [ ! -d "${PROD_DIR}" ]; then
                            git clone ${GIT_REPO_URL} --single-branch --branch ${BRANCH} ${PROD_DIR}
                        else
                            cd ${PROD_DIR} && git pull origin ${BRANCH}
                        fi
                        
                        docker compose pull
                        docker compose up -d
                        docker system prune -f
                    EOF
                    """
                }
            }
        }
    }
    
    post {
        always {
            script {
                sh 'docker rm -f ${CONTAINER_NAME} || true'
                sh 'docker rmi ${IMAGE_NAME}:latest || true'
            }
        }
    }
}
