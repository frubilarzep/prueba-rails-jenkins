pipeline {
    agent any

    environment {
        RAILS_ENV = 'test'
        DATABASE_URL = 'postgres://postgres:postgres@localhost:5432/prueba_rails_jenkins_test'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'bundle install --deployment --without production'
            }
        }

        stage('Lint') {
            steps {
                sh 'bundle exec rubocop'
            }
        }

        stage('Security scan') {
            steps {
                sh 'bundle exec brakeman -q -w2'
                sh 'bundle exec bundler-audit check --update'
            }
        }

        stage('Prepare database') {
            steps {
                sh 'bin/rails db:create db:schema:load'
            }
        }

        stage('Test') {
            steps {
                sh 'bundle exec rspec'
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true, testResults: 'spec/reports/*.xml'
        }
    }
}
