pipeline {
	options {
		buildDiscarder(logRotator(numToKeepStr: '5'))
		disableConcurrentBuilds()
		ansiColor('xterm')
	}
	agent any
	environment {
		IMAGE        = 'sphinxsearch'
		BRANCH_LOWER = "${BRANCH_NAME.toLowerCase().replaceAll('/', '-')}"
	}
	stages {
		stage('Environment') {
			parallel {
				stage('Master') {
					when {
						branch 'master'
					}
					steps {
						script {
							env.BUILD_TAG = 'latest'
						}
					}
				}
				stage('Other') {
					when {
						not {
							branch 'master'
						}
					}
					steps {
						script {
							// Defaults to the Branch name, which is applies to all branches AND pr's
							env.BUILD_TAG = "github-${BRANCH_LOWER}"
						}
					}
				}
			}
		}
		stage('Build') {
			steps {
				sh """docker build \\
				--pull \\
				--no-cache \\
				-f Dockerfile \\
				-t jc21/${IMAGE}:${BUILD_TAG} \\
				.
				"""
			}
		}
		stage('Push') {
			steps {
				withCredentials([usernamePassword(credentialsId: 'jc21-dockerhub', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
					sh 'docker login -u "${DOCKER_USER}" -p "${DOCKER_PASS}"'
					sh "docker push jc21/${IMAGE}:${BUILD_TAG}"
				}
			}
		}
		stage('PR Comment') {
			when {
				allOf {
					changeRequest()
					not {
						equals expected: 'UNSTABLE', actual: currentBuild.result
					}
				}
			}
			steps {
				script {
					def comment = pullRequest.comment("""Docker Image for build ${BUILD_NUMBER} is available on [DockerHub](https://cloud.docker.com/repository/docker/jc21/${IMAGE}) as:

- `jc21/${IMAGE}:github-${BUILD_TAG}`
""")
				}
			}
		}
	}
	post {
		success {
			juxtapose event: 'success'
			sh 'figlet "SUCCESS"'
		}
		failure {
			juxtapose event: 'failure'
			sh 'figlet "FAILURE"'
		}
		unstable {
			juxtapose event: 'unstable'
			sh 'figlet "UNSTABLE"'
		}
	}
}
