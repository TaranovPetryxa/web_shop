pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'wordpress_custom'
        GIT_REPO_URL = 'https://github.com/TaranovPetryxa/web_shop.git'
        PROD_SERVER = 'prodServer'
        PROD_DIR = '/home/user/web_shop'
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
    }

    stages {
        stage('Git Clone') {
            steps {
                git url: "${GIT_REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Сборка образа
                    sh 'docker build -t ${DOCKER_IMAGE_NAME} .'
                }
            }
        }

        stage('Run and Test Image') {
            steps {
                script {
                    // Запуск контейнера
                    sh 'docker run --rm ${DOCKER_IMAGE_NAME} ./run-tests.sh' // Замените на команду для запуска тестов
                }
            }
        }

        stage('Push to Docker Hub') {
            when {
                expression { currentBuild.result == null } // Только если предыдущий этап успешен
            }
            steps {
                script {
                    // Загрузка образа в Docker Hub
                    sh 'docker push ${DOCKER_IMAGE_NAME}'
                }
            }
        }

        stage('Deploy to Production Server') {
            steps {
                script {
                    // Подключение к продакшн серверу
                    sh """
                    ssh user@${PROD_SERVER} '
                        cd ${PROD_DIR} &&
                        git clone ${GIT_REPO_URL} --single-branch --branch main . || (git pull origin main) &&
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
        cleanup {
            // Удаление временных файлов и контейнеров
            sh 'docker system prune -f'
        }
    }
}
