
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

    cluster.yml manifest deploys three-Node Cluster in Kubernetes on AWS EKS.
    resources.yml manifest deploys MongoDB Cluster
    Setup and auto attach AWS EBS volumes as PV.
    To obtain metrics from the MongoDB cluster prometheus-mongodb-exporter will be deployed.
    In real production need use Vault instead k8s Secret

### Prerequisite

1. Install awscli, eksctl, kubectl binaries
2. Define the variables in cluster.yml and resources.yml
3. Generate secrets for resources.yml -> Secret

    MONGO_ADMIN

    MONGO_ADMIN_PASSWORD

    MONGO_DB

    MONGO_USER

    MONGO_PASSWORD
    
    MONGO_USER_ROLE

with command:
```
echo -n '<secret>' | base64
```

### EKS cluster preparation

Create cluster
```
eksctl create cluster -f cluster.yml
```

Reconfigure kubectl to new cluster
```
aws eks --region <region> update-kubeconfig --name mongoClusterProd
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

















