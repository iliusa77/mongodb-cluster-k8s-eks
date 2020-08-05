pipeline {
    agent any
    options{
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }
        parameters{
            string(
                 name: 'eks_cluster_name',
                 defaultValue: '',
                 description: ''),
            string(
                 name: 'ec2_type_server',
                 defaultValue: 't2.micro',
                 description: ''),
            string(
                 name: 'region',
                 defaultValue: 'eu-west-1',
                 description: ''),
        }
 
 
stages {
        stage('Initialize'){
            steps{
                echo "Initialization"
                script {
                    manager.addShortText("${eks_cluster_name}", "black", "lightsalmon", "0px", "white")
                    manager.addShortText("${ec2_type_server}", "black", "lightblue", "0px", "white")
                }
            }
        }
        stage('Checkout'){
            steps {
                checkout scm
            }
        }
        stage('Deploy Cluster'){
            steps {
               withAWS(credentials: "aws_access", region: "${region}") {
                    bash """#!/bin/bash
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