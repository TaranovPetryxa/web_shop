pipeline {
    agent any

    stages {
        stage('Git Clone') {
            steps {
                // Клонируем репозиторий
                git url: 'https://github.com/TaranovPetryxa/web_shop.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Собираем образ из Dockerfile
                script {
                    def appName = 'wordpress_custom'
                    def imageTag = 'latest'
                    sh "docker build -t ${appName}:${imageTag} ."
                }
            }
        }

        stage('Run and Test Image') {
            steps {
                script {
                    // Запускаем образ и тестируем его
                    sh "docker run --rm wordpress_custom:latest your-test-command"
                }
            }
        }

        stage('Push to Docker Hub') {
            when {
                // Проверяем, прошли ли тесты
                expression { currentBuild.result == null }
            }
            steps {
                script {
                    def appName = 'wordpress_custom'
                    def imageTag = 'latest'
                    // Логинимся в Docker Hub
                    sh "echo '${DOCKERHUB_PASSWORD}' | docker login -u '${DOCKERHUB_USERNAME}' --password-stdin"
                    // Загружаем образ в Docker Hub
                    sh "docker push ${appName}:${imageTag}"
                }
            }
        }

        stage('Deploy to Production Server') {
            steps {
                script {
                    def prodServer = 'prodServer'
                    def appName = 'wordpress_custom'
                    def imageTag = 'latest'
                    
                    // Подключаемся к продакшн-серверу
                    sh """
                    ssh user@${prodServer} 'bash -s' <<-'EOF'
                        # Клонируем проект
                        git clone https://github.com/TaranovPetryxa/web_shop.git /home/user/
                        cd /home/user/web_shop
                        # Скачиваем образ из Docker Hub
                        docker pull ${appName}:${imageTag}
                        # Запускаем через docker-compose
                        docker compose up -d
                        # Удаляем лишние образы и контейнеры
                        docker system prune -af
                    EOF
                    """
                }
            }
        }
    }

    environment {
        DOCKERHUB_USERNAME = credentials('dockerhub-username') // Credentials for Docker Hub username
        DOCKERHUB_PASSWORD = credentials('dockerhub-password') // Credentials for Docker Hub password
    }

    post {
        always {
            // Cleanup, если необходимо
            sh 'docker system prune -af'
        }
    }
}
