# Standalone Spark Cluster on Kubernetes
This repo contains code and details on how to create a Standalone Spark cluster along with a Jupyter notebook image so you can run some code on the cluster.

This cluster is made of one deployment object for the spark master (spark-master-dep.yml), a headless service (spark-master-service.yml) for spark master so all the slaves and the notebook know how to reach the master and a deployment for the spark slaves or workers (spark-slave-dep.yml). Deployments are being used so the slaves can be easily scaled and it's possible to upgrade the pods without downtime.

