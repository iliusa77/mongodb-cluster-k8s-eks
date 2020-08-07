
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

### Jenkins 

1. Install Jenkins plugins: "AWS Secrets Manager Credentials", "Pipeline", "Pipeline:AWS Steps"
2. Create 3 pairs secrets in Jenkins Credentials ("aws_access" - kind "AWS Credentials", "MONGO_ADMIN" - kind "Username with password", "MONGO_USER"- "kind Username with password")
3. Create Jenkins Pipeline with Additional Behaviours: "Wipe out repository & force clone"
4. Fill Pipeline parameters: 
- eks_cluster_name
- region
- ec2_type_server
- ec2_volume_size
- namespace
- mongo_db_name
- replicaset_name
5. During deploy in Jenkins build console get the
















