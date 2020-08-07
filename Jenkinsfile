pipeline {
    agent any
    options{
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }
        parameters{
            string(
                 name: 'eks_cluster_name',
                 defaultValue: 'mC2',
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
            string(
                 name: 'mongo_db_name',
                 defaultValue: 'proddb',
                 description: '')
            string(
                 name: 'replicaset_name',
                 defaultValue: 'MainRepSet',
                 description: '')

        }

    environment {
        MONGO_ADMIN = credentials("MONGO_ADMIN")
        MONGO_ADMIN_NAME = "${env.MONGO_ADMIN_USR}"
        MONGO_ADMIN_PASSWORD = "${env.MONGO_ADMIN_PSW}"
        MONGO_USER = credentials("MONGO_USER")
        MONGO_USER_NAME = "${env.MONGO_USER_USR}"
        MONGO_USER_PASSWORD = "${env.MONGO_USER_PSW}"
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
               withAWS(credentials: "aws_access", region: "${region}") {
                    sh """
                        #!/bin/bash
                        export NAMESPACE=${namespace}
                        export MONGO_DB=${mongo_db_name}
                        export MONGO_ADMIN=${MONGO_ADMIN_NAME}
                        export MONGO_ADMIN_PASSWORD=${MONGO_ADMIN_PASSWORD}
                        export MONGO_USER=${MONGO_USER_NAME}
                        export MONGO_PASSWORD=${MONGO_USER_PASSWORD}
                        export REPLICASET_NAME=${replicaset_name}
                        envsubst < ci_resources.yml | kubectl create -f -
                    """
                }           
            }
        }*/
        stage('Provision'){
            steps {
               withAWS(credentials: "aws_access", region: "${region}") {
                    sh """
                        #!/bin/bash
                        kubectl exec -it --namespace=${namespace} mongo-0 bash
                        mongo --eval "db = db.getSiblingDB(\"admin\"); db.createUser({ user: \"${MONGO_ADMIN}\", pwd: \"${MONGO_ADMIN_PASSWORD}\", roles: [{ role: \"userAdminAnyDatabase\", db: \"admin\" }, { role: \"readWriteAnyDatabase\", db: \"admin\" }]});";
                        mongo --eval "db = db.getSiblingDB(\"${mongo_db_name}\"); db.createUser({ user: \"${MONGO_USER}\", pwd: \"${MONGO_PASSWORD}\", roles: [{ role: \"readWrite\", db: \"${MONGO_DB}\" }]});";
                        mongo --eval "db = db.getSiblingDB(\"${mongo_db_name}\"); db.insertOne({'firstname': 'Sarah', 'lastname': 'Smith'});";
                    """
                }           
            }
        }
        /*stage('Deploy prometheus-mongodb-exporter'){
            steps {
               withAWS(credentials: "aws_access", region: "${region}") {
                    sh """
                        #!/bin/bash
                        curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
                        kubectl create serviceaccount --namespace kube-system tiller
                        kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
                        kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
                        helm init --service-account tiller --upgrade
                        helm repo add stable https://kubernetes-charts.storage.googleapis.com
                        export MONGO_ADMIN=${MONGO_ADMIN_NAME}
                        export MONGO_ADMIN_PASSWORD=${MONGO_ADMIN_PASSWORD}
                        export ELB_URL=\$(kubectl get svc -n ${namespace} | grep LoadBalancer | cut -d ' ' -f10)
                        envsubst < prometheus-mongodb-exporter.values | helm install --name mongo-cluster stable/prometheus-mongodb-exporter --namespace ${namespace} --values -
                        sleep 15
                        export ENDPOINT_PROMETEUS_METRICS=\$(kubectl get svc -n ${namespace} | grep LoadBalancer | grep 9216 | cut -d ' ' -f10):9216/metrics
                    """
                }           
            }
        }*/
    } 
}