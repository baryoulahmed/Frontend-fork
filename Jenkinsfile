pipeline {
    agent any

    environment {
        SONAR_SCANNER_VERSION = '4.7.0.2747'
        SONAR_HOME = "${env.HOME}/.sonar/sonar-scanner-${SONAR_SCANNER_VERSION}-linux"
        REPO_URL = 'https://github.com/baryoulahmed/Frontend-fork.git'
        BRANCH = 'main'
        DOCKER_IMAGE = 'baryoul/frontend-app'
        SONAR_TOKEN = credentials('sonar-token-id')           // Jenkins secret
        DOCKER_CREDENTIALS = 'docker-hub-credentials-id'     // Jenkins secret
        DT_API_URL = 'http://192.168.79.148:8081'                 // Dependency-Track API no-auth
    }

    stages {

        stage('Clone Repository') {
            steps {
                deleteDir()
                sh "git clone -b ${BRANCH} ${REPO_URL} repo"
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('repo') {
                    withEnv(["PATH=/usr/bin:/usr/local/bin:$PATH"]) {
                        sh 'npm install -f'
                    }
                }
            }
        }

        stage('Build') {
            steps {
                dir('repo') {
                    sh 'npm -v'
                }
            }
        }

        stage('Test') {
            steps {
                dir('repo') {
                    sh 'npm -v'
                }
            }
        }

        stage('Install Sonar Scanner') {
            steps {
                sh """
                    mkdir -p \$HOME/.sonar
                    if [ ! -d "\$SONAR_HOME" ]; then
                        curl -sSLo \$HOME/.sonar/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
                        unzip -o \$HOME/.sonar/sonar-scanner.zip -d \$HOME/.sonar/
                    fi
                """
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('repo') {
                    withSonarQubeEnv('SonarQube') {
                        withEnv([
                            "PATH+SONAR=${env.SONAR_HOME}/bin",
                            "SONAR_SCANNER_OPTS=-server"
                        ]) {
                            sh 'sonar-scanner -Dsonar.login=$SONAR_TOKEN -Dsonar.projectKey=devSecOps -Dsonar.sources=. -Dsonar.host.url=http://192.168.79.148:9000'
                        }
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                dir('repo') {
                    script {
                        def imageTag = "${env.BUILD_NUMBER}"

                        // Login Docker Hub
                        withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        }

                        // Build Docker image
                        sh "docker build -t ${DOCKER_IMAGE}:${imageTag} ."

                        // Push Docker image
                        sh "docker push ${DOCKER_IMAGE}:${imageTag}"
                    }
                }
            }
        }

        // ✅ Nouvelle étape : Dependency-Track BOM scan (no-auth)
        stage('Generate BOM & Upload to Dependency-Track') {
            steps {
                script {
                    def imageTag = "${env.BUILD_NUMBER}"

                    // Installer syft si absent
                    sh '''
                        if ! command -v syft > /dev/null; then
                            curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
                        fi
                    '''

                    // Générer BOM depuis l'image Docker
                    sh "syft docker:${DOCKER_IMAGE}:${imageTag} -o cyclonedx-json > bom.json"
                    echo "BOM generated: bom.json"

                    // Upload automatique vers Dependency-Track (no-auth)
                    sh """
                        curl -X POST "${DT_API_URL}/api/v1/bom" \\
                             -F "projectName=Front" \\
                             -F "bom=@bom.json"
                    """
                    echo "BOM uploaded to Dependency-Track successfully (no-auth)."
                }
            }
        }

    }
}
