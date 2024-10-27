pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/TaranovPetryxa/web_shop.git'
        BRANCH = 'main' // Имя нужной ветки репозитория
        //CONFIG_FILE = '/var/jenkins_home/workspace/pipline_app/Unison/appsettings.json' // Путь к  файлу  конфигурации
        CONTAINER_NAME = 'web_shop' // Имя контейнера
        IMAGE_NAME = 'wordpress_custom' // Имя Docker -  образа
        DOCKER_HUB_REPO = 'taranovpetryxa/web_shop' // Имя репозитория на Docker Hub
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials' // ID учетных данных Docker Hub в Jenkins
        PROD_SERVER = '192.168.1.10'
        PROD_DIR = '/home/user/web_shop'
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Клонирование нужной ветки
                git branch: "${BRANCH}", url: "${REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Сборка Docker образа
                    sh 'docker build -t ${IMAGE_NAME} .'
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    // Запуск контейнера с примонтированным файлом конфигурации
                    //sh """
                    //    docker run -d --name ${CONTAINER_NAME} -v ${CONFIG_FILE}:/app/ ${IMAGE_NAME} 
                    //   """
                    sh """
                        docker run -d --name ${CONTAINER_NAME} -p 8080:80 ${IMAGE_NAME} 
                       """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Аутентификация в Docker Hub
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    }
                    // Тегирование и отправка образа в Docker Hub
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
                    // Подключение к продакшн серверу
                    sh """
                    ssh user@${PROD_SERVER} -p 222'
                        cd ~ &&
                        git clone ${REPO_URL} --single-branch --branch main . || (git pull origin main) &&
                        cd ${PROD_DIR} &&
                        docker compose pull &&
                        docker compose up -d &&
                        docker system prune -f
                    '
                    """
                }
            }
        }   
    }

    post {
        always {
            // Удаление контейнера после завершения работы 
            script {
                sh 'docker rm -f ${CONTAINER_NAME} || true'
                sh 'docker rmi ${IMAGE_NAME}:latest || true'
           }
        }
     }
}
