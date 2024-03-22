pipeline {
    agent {
        kubernetes {
            yaml '''
              apiVersion: v1
              kind: Pod
              spec:
                containers:
                  - name: podman
                    imagePullPolicy: Always
                    image: docker.io/mysticrenji/podman
                    command:
                      - cat
                    tty: true
                    securityContext:
                      privileged: true
                    volumeMounts:
                      - mountPath: /var/lib/containers
                        name: podman-volume
                      - mountPath: /dev/shm
                        name: devshm-volume
                      - mountPath: /var/run
                        name: varrun-volume
                      - mountPath: /tmp
                        name: tmp-volume
                  - name: nix
                    image: nixpkgs/nix-flakes
                    imagePullPolicy: Always
                    command:
                      - cat
                    tty: true
                restartPolicy: Never
                volumes:
                  - name: podman-volume
                    emptyDir: {}
                  - emptyDir:
                      medium: Memory
                    name: devshm-volume
                  - emptyDir: {}
                    name: varrun-volume
                  - emptyDir: {}
                    name: tmp-volume

            '''
            inheritFrom 'default'
        }
    }
    stages {
        stage("Build") {
            steps {
                container("nix") {
                    sh "nix develop --command bash -c 'make requirements.txt'"
                }
                container("podman") {
                    sh "podman build ."
                }
            }
        }
    }
    post {
        always {
            chuckNorris()
            discordSend description: "Pipeline Build ${currentBuild.currentResult}", footer: currentBuild.description, link: env.BUILD_URL, result: currentBuild.currentResult, title: env.JOB_NAME, webhookURL: env.DISCORD_URL
        }
    }
}
