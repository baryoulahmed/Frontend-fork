pipeline {
    agent any
    
     environment {     
	ANSIBLE_PLAYBOOK = 'ansible-deploy.yaml'
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "http://192.168.137.129:1111"
        NEXUS_REPOSITORY = "back-end" 
        NEXUS_CREDENTIAL_ID = "admin"
        DOCKER_IMAGE_NAME = "front-end"
	BUILD_NUMBER = "${BUILD_NUMBER}"
        DOCKER_IMAGE_TAG = "${NEXUS_REPOSITORY}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}" 
    }
    stages {
        stage('Checkout Code') {
            steps {
                // Checkout your source code from your Git repository
                script {
                    git branch: 'main', url: 'https://github.com/Wassim-Bessioud/PFE-Frontend.git'
                }
            }
        }
	stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    def customImage = docker.build("${DOCKER_IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image to Nexus') {
            steps {
                script {
                    // Log in to Docker registry
                    docker.withRegistry("${NEXUS_URL}", "${NEXUS_CREDENTIAL_ID}") {
                        // Push the Docker image to Nexus
                        def customImage = docker.image("${DOCKER_IMAGE_TAG}")
                        customImage.push()
                    }
                }
            }
        }
	    	stage('Ansible Deployment') {
            steps {
                script {
                    
			sh "sed -i 's|<IMAGE_TAG>|${BUILD_NUMBER}|' k8s-deply.yaml"
                    sh "ansible-playbook -i inventory.ini ${ANSIBLE_PLAYBOOK}"
                }
            }
        }
	stage('Sonar Analysis') {
            steps {
                script {
                    nodejs(nodeJSInstallationName: 'Node') {
                        sh "npm install"
                        sh "npm install sonar-scanner"
                        sh "npm run sonar"
                    }
                }
            }
		
        }
	     
  

      
        
    }
}
