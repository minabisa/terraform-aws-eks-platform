pipeline {
    agent any

    options {
        ansiColor('xterm')
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(
            numToKeepStr: '20',
            artifactNumToKeepStr: '10'
        ))
        timeout(time: 90, unit: 'MINUTES')
    }

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev'],
            description: 'Terraform environment to deploy'
        )

        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy-plan'],
            description: 'Terraform operation'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION    = 'true'
        TF_INPUT            = 'false'
        TF_PLUGIN_CACHE_DIR = "${WORKSPACE}/.terraform-plugin-cache"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm

                sh '''
                    echo "Commit: $(git rev-parse HEAD)"
                    echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
                    git status --short
                '''
            }
        }

        stage('Tool Versions') {
            steps {
                sh '''
                    terraform version
                    aws --version
                    kubectl version --client
                    tflint --version
                    checkov --version
                '''
            }
        }

        stage('AWS Authentication') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-jenkins-terraform',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        set +x

                        aws sts get-caller-identity \
                          --query '{
                            Account:Account,
                            Arn:Arn,
                            UserId:UserId
                          }' \
                          --output table
                    '''
                }
            }
        }

        stage('Terraform Format') {
            steps {
                sh '''
                    terraform fmt -check -recursive
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-jenkins-terraform',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    ),
                    string(
                        credentialsId: 'terraform-state-bucket',
                        variable: 'TF_STATE_BUCKET'
                    )
                ]) {
                    dir("environments/${params.ENVIRONMENT}") {
                        sh '''
                            set +x

                            mkdir -p "${TF_PLUGIN_CACHE_DIR}"

                            cat > backend-ci.hcl <<BACKEND
bucket = "${TF_STATE_BUCKET}"
region = "${AWS_DEFAULT_REGION}"
BACKEND

                            terraform init \
                              -reconfigure \
                              -backend-config=backend-ci.hcl
                        '''
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh '''
                        terraform validate
                    '''
                }
            }
        }

        stage('TFLint') {
            steps {
                sh '''
                    tflint --init
                    tflint --recursive
                '''
            }
        }

        stage('Checkov') {
            steps {
                sh '''
                    checkov \
                      --directory . \
                      --config-file .checkov.yml \
                      --output cli \
                      --output junitxml \
                      --output-file-path console,checkov-report.xml
                '''
            }

            post {
    always {
        junit(
            allowEmptyResults: true,
            skipMarkingBuildUnstable: true,
            testResults: 'checkov-report.xml'
        )
    }
}
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-jenkins-terraform',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    dir("environments/${params.ENVIRONMENT}") {
                        script {
                            if (params.ACTION == 'destroy-plan') {
                                sh '''
                                    set +x

                                    terraform plan \
                                      -destroy \
                                      -out=tfplan

                                    terraform show \
                                      -no-color \
                                      tfplan > tfplan.txt

                                    terraform show \
                                      -json \
                                      tfplan > tfplan.json
                                '''
                            } else {
                                sh '''
                                    set +x

                                    terraform plan \
                                      -out=tfplan

                                    terraform show \
                                      -no-color \
                                      tfplan > tfplan.txt

                                    terraform show \
                                      -json \
                                      tfplan > tfplan.json
                                '''
                            }
                        }
                    }
                }
            }
        }

        stage('Archive Plan') {
            steps {
                archiveArtifacts(
                    artifacts: """
                        environments/${params.ENVIRONMENT}/tfplan,
                        environments/${params.ENVIRONMENT}/tfplan.txt,
                        environments/${params.ENVIRONMENT}/tfplan.json
                    """.stripIndent().trim(),
                    fingerprint: true
                )
            }
        }

        stage('Plan Summary') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh '''
                        echo "========================================"
                        echo "Terraform Plan Summary"
                        echo "========================================"

                        grep -E \
                          "Plan:|No changes.|Changes to Outputs:" \
                          tfplan.txt || true
                    '''
                }
            }
        }

        stage('Manual Approval') {
            when {
                expression {
                    return params.ACTION == 'apply'
                }
            }

            steps {
                timeout(time: 20, unit: 'MINUTES') {
                    input(
                        message: """
                        Review the archived Terraform plan.

                        Environment: ${params.ENVIRONMENT}
                        Action: ${params.ACTION}

                        Approve applying this exact saved plan?
                        """.stripIndent(),
                        ok: 'Approve Terraform Apply'
                    )
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    return params.ACTION == 'apply'
                }
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-jenkins-terraform',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    dir("environments/${params.ENVIRONMENT}") {
                        sh '''
                            set +x

                            terraform apply \
                              -auto-approve \
                              tfplan
                        '''
                    }
                }
            }
        }

        stage('Post-Deployment Verification') {
            when {
                expression {
                    return params.ACTION == 'apply'
                }
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-jenkins-terraform',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    dir("environments/${params.ENVIRONMENT}") {
                        sh '''
                            set +x

                            CLUSTER_NAME=$(terraform output -raw eks_cluster_name)

                            aws eks describe-cluster \
                              --name "${CLUSTER_NAME}" \
                              --region "${AWS_DEFAULT_REGION}" \
                              --query 'cluster.{
                                Name:name,
                                Status:status,
                                Version:version
                              }' \
                              --output table

                            aws eks update-kubeconfig \
                              --name "${CLUSTER_NAME}" \
                              --region "${AWS_DEFAULT_REGION}" \
                              --kubeconfig "${WORKSPACE}/kubeconfig"

                            export KUBECONFIG="${WORKSPACE}/kubeconfig"

                            kubectl get nodes
                            kubectl get pods -n kube-system
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            sh '''
                rm -f \
                  environments/*/backend-ci.hcl \
                  kubeconfig
            '''

            cleanWs(
                deleteDirs: true,
                notFailBuild: true
            )
        }

        success {
            echo 'Terraform pipeline completed successfully.'
        }

        failure {
            echo 'Terraform pipeline failed. Review the failed stage and console output.'
        }

        aborted {
            echo 'Terraform pipeline was aborted.'
        }
    }
}
