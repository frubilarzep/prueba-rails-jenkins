pipeline {
    agent any

    environment {
        RAILS_ENV = 'test'
        DATABASE_URL = 'postgres://postgres:postgres@localhost:5432/prueba_rails_jenkins_test'
    }

    options {
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install deps') {
            steps {
                sh 'bundle install'
            }
        }

        stage('Test') {
            steps {
                sh 'bin/rails db:create db:schema:load'
                sh 'bundle exec rspec'
            }
        }

        stage('Lint') {
            steps {
                sh 'bundle exec rubocop'
            }
        }

        stage('Build image') {
            steps {
                sh 'docker build -t sandbox-cicd .'
            }
        }

        stage('Deploy') {
            when { branch 'production' }
            steps {
                withCredentials([string(credentialsId: 'sandbox-cicd-rails-master-key', variable: 'RAILS_MASTER_KEY')]) {
                    sh '''
                        docker rm -f sandbox-cicd || true
                        docker run -d \
                          --name sandbox-cicd \
                          --network course-net \
                          -p 127.0.0.1:4099:3000 \
                          -e RAILS_ENV=production \
                          -e RAILS_MASTER_KEY="$RAILS_MASTER_KEY" \
                          sandbox-cicd
                    '''
                }
            }
        }

        stage('Migrate') {
            when { branch 'production' }
            steps {
                // Sandbox deploy has no database provisioned yet, nothing to migrate.
                sh 'echo "No database configured for this sandbox deploy, skipping migrations"'
            }
        }

        stage('Health Check') {
            when { branch 'production' }
            steps {
                sh 'curl -f http://127.0.0.1:4099/health'
            }
        }
    }
}
