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
                 name: 'region',
                 defaultValue: 'eu-west-1',
                 description: '')
            string(
                 name: 'ec2_type_server',
                 defaultValue: 't2.micro',
                 description: '')
            string(
                 name: 'ec2_volume_size',
                 defaultValue: '8',
                 description: '')
            string(
                 name: 'namespace',
                 defaultValue: 'mongo',
                 description: '')

        }
 
 
stages {
        stage('Checkout'){
            steps {
                checkout scm
            }
        }
        /*stage('Deploy EKS Cluster'){
            steps {
               withAWS(credentials: "aws_access", region: "${region}") {
                    sh """
                        #!/bin/bash
                        eksctl create cluster \
                        --name ${eks_cluster_name} \
                        --region ${region} \
                        --nodes 3 \
                        --nodes-min 3
                        --nodes-max 5
                        --node-type ${ec2_type_server} 
                        --node-volume-size ${ec2_volume_size}
                        --node-volume-type gp2
                    """
                }
            }
        }*/
        stage('Deploy EKS Cluster'){
            steps {
               withAWS(credentials: "aws_access", region: "${region}") {
                    sh """
                        #!/bin/bash
                        export EKS_CLUSTER_NAME=${eks_cluster_name}
                        export REGION=${region}
                        export EC2_TYPE_SERVER=${ec2_type_server}
                        export EC2_VOLUME_SIZE=${ec2_volume_size}
                        envsubst < ci_cluster.yml | eksctl create cluster -f - 
                    """
                }
            }
        }
        stage('Deploy MongoDB Cluster'){
            steps {
                sh """
                   #!/bin/bash
                   export NAMESPACE=${namespace}
                   envsubst < ci_resources.yml | kubectl create -f -
                """              
            }
        }
    } 
}