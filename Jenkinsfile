pipeline {
	agent any

	environment {
		IMAGE_NAME = "java-sample-webapp:latest"
		SCAN_REPORT = "trivy-report.json"
	}

	stages {
		stage('Build') {
			steps {
				sh 'chmod 777 run.sh'
				sh './run.sh'
			}
		}

		stage('Scan') {
			steps {
				sh 'trivy image --format json --output ${SCAN_REPORT} ${IMAGE_NAME}'
				sh 'trivy image ${IMAGE_NAME}'
			}
		}
	}

	post {
		always {
			echo 'Trivy scan complete'
			archiveArtifacts artifacts: '${SCAN_REPORT}', allowEmptyArchive: true
		}
		failure {
			emailext (
				to: '${CHANGE_AUTHOR_EMAIL}',
				subject: "Docker Trivy Scan Failed",
				body: "Trivy scan found vulnerabilities. Check Jenkins logs for details.",
				attachmentsPattern: '${SCAN_REPORT}'
			)
		}
	}
}
