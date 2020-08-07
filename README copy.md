
# Task

1. Provide a solution code that will:

    1.1. Setup a production-like three-Node MongoDB Cluster in Kubernetes.  
    1.2. Create a unique mongo-collection and a user with write permissions to that collection  
    1.3. The output should include a collection with user credentials  
    1.4. Validate deployment.  
    1.5. Expose an endpoint for Prometheus metrics.  

2. Pick a set of metrics to ensure reliable functionality of the cluster

Notes:  *production-like* is not meant in sense of performance, but in sense of maintenance.

# Solution

## Mongodb Cluster Deployment on AWS EKS

### Description

    The "cluster.yml" deploys three-Node Cluster in Kubernetes on AWS EKS.
    The "resources.yml" deploys MongoDB Cluster (master-slave-slave)
    Setup and auto attach AWS EBS volumes as PV.
    To obtain metrics from the MongoDB cluster prometheus-mongodb-exporter will be deployed.

### Prerequisite

1. Install Jenkins plugins: "AWS Secrets Manager Credentials", "Pipeline", "Pipeline:AWS Steps"
2. Create 3 pairs secrets in Jenkins Credentials ("aws_access" - kind "AWS Credentials", "MONGO_ADMIN" - kind "Username with password", "MONGO_USER"- "kind Username with password")
3. Create Jenkins Pipeline with Additional Behaviours: "Wipe out repository & force clone"


### EKS cluster preparation

Create cluster
```
eksctl create cluster -f cluster.yml
```

Reconfigure kubectl to new cluster
```
aws eks --region <region> update-kubeconfig --name <clustername>
```

### Deploy MongoDB resources

```
kubectl create -f resources.yml
```

Check pods
```
kubectl get pods --namespace=mongo
NAME      READY   STATUS    RESTARTS   AGE
mongo-0   2/2     Running   0          99s
mongo-1   2/2     Running   0          72s
mongo-2   2/2     Running   0          53s
```

Check cluster members
```
kubectl exec -it --namespace=mongo mongo-0 bash
mongo
rs.status()
_id" : 0,
			"name" : "mongo-0.mongo.mongo.svc.cluster.local:27017",
			"stateStr" : "PRIMARY",
"_id" : 1,
			"name" : "mongo-1.mongo.mongo.svc.cluster.local:27017",
			"stateStr" : "SECONDARY",
"_id" : 2,
			"name" : "mongo-2.mongo.mongo.svc.cluster.local:27017",
			"stateStr" : "SECONDARY",
```

Get LoadBalancer (for MongoDB URI)
```
kubectl get all --namespace=mongo | grep LoadBalancer
<elb_url>
```

Create MongoDB URI
```
mongodb://<MONGO_ADMIN>:<MONGO_ADMIN_PASSWORD>@<elb_url>:27017/admin
```



### Prometheus (install, expose and check prometheus-mongodb-exporter)

```
helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm inspect values stable/prometheus-mongodb-exporter > prometheus-mongodb-exporter.values

vim prometheus-mongodb-exporter.values
   uri: "mongodb://<MONGO_ADMIN>:<MONGO_ADMIN_PASSWORD>@<elb_url>:27017/admin"
   service:
      type: LoadBalancer
   serviceMonitor:
      enabled: false

helm upgrade --install mongo-cluster stable/prometheus-mongodb-exporter --values prometheus-mongodb-exporter.values --namespace mongo

kubectl get all --namespace=mongo | grep LoadBalancer | grep 9216
service/mongo-cluster-prometheus-mongodb-exporter  <exporter_elb_url>   9216:32295/

curl http://<exporter_elb_url>:9216/metrics
```

### Drop MongoDB and EKS cluster resources

```
helm uninstall mongo-cluster --namespace mongo
kubectl delete -f resources.yml 
eksctl delete cluster -f cluster.yml
```

### What I wanted but could not do

1. Configure ConfigMap/StatefulSet(volumeMounts/volumes) with mongod.conf and use `mongod --config /etc/mongod.conf`
2. Configure security on cluster with --clusterAuthMode keyFile and --auth



export NAMESPACE=mongo
export MONGO_DB=proddb
export MONGO_ADMIN=admin
export MONGO_ADMIN_PASSWORD=adminpass
export MONGO_USER=user1
export MONGO_PASSWORD=pass1
export REPLICASET_NAME=MainRepSet

envsubst < ci_resources.yml | kubectl create -f -






kubectl exec --namespace=mongo mongo-0 mongo --eval "db = db.getSiblingDB(\"$MONGO_DB\"); db.createUser({ user: \"$MONGO_USER\", pwd: \"$MONGO_PASSWORD\", roles: [{ role: \"readWrite\", db: \"$MONGO_DB\" }]});";


        stage('Deploy prometheus-mongodb-exporter'){
            steps {
               withAWS(credentials: "aws_access", region: "${region}") {
                    sh """
                        #!/bin/bash
                        export MONGO_ADMIN=${MONGO_ADMIN_NAME}
                        export MONGO_ADMIN_PASSWORD=${MONGO_ADMIN_PASSWORD}
                        export ELB_URL=$(kubectl get svc -n mongo | grep LoadBalancer | awk '{print $4}')
                        helm repo add stable https://kubernetes-charts.storage.googleapis.com
                        envsubst < prometheus-mongodb-exporter.values | helm upgrade --install mongo-cluster stable/prometheus-mongodb-exporter --values - --namespace ${namespace}
                        sleep 15
                        exporter_elb_url=$(kubectl get svc -n ${namespace} | grep LoadBalancer | grep 9216 | awk '{print $4}')
                        echo "endpoint for Prometheus metrics is $exporter_elb_url:9216/metrics"
                    """
                }           
            }
        }



helm upgrade --install mongo-cluster stable/prometheus-mongodb-exporter --namespace mongo -mongodb.uri "mongodb://admin:adminpass@$(kubectl get svc -n mongo | grep LoadBalancer | awk '{print $4}'):27017/admin" -serviceMonitor.enabled false -service.type LoadBalancer














