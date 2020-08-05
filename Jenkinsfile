pipeline {
    agent any
    options{
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }
        parameters{
            string(
                 name: 'eks_cluster_name',
                 defaultValue: '',
                 description: '')
            string(
                 name: 'ec2_type_server',
                 defaultValue: 't2.micro',
                 description: '')
            string(
                 name: 'region',
                 defaultValue: 'eu-west-1',
                 description: '')
        }
 
 
stages {
        stage('Checkout'){
            steps {
                checkout scm
            }
        }
        stage('Deploy Cluster'){
            steps {
               withAWS(credentials: "aws_access", region: "${region}") {
                    sh """
                        #!/bin/bash
                        eksctl create cluster \
                        --name ${eks_cluster_name} \
                        --region ${region} \
                        --nodes 3 \
                        --node-type ${ec2_type_server} 
                    """
                }
            }
        }
    } 
}