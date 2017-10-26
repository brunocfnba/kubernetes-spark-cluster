# Standalone Spark Cluster on Kubernetes
This repo contains code and details on how to create a Standalone Spark cluster along with a Jupyter notebook image so you can run some code on the cluster.

This cluster is made of one deployment object for the spark master (spark-master-dep.yml), a headless service (spark-master-service.yml) for spark master so all the slaves and the notebook know how to reach the master and a deployment for the spark slaves or workers (spark-slave-dep.yml). Deployments are being used so the slaves can be easily scaled and it's possible to upgrade the pods without downtime.

### Creating Docker Spark and Jupyter Images
1. Build the image from Dockerfile located in SparkImage folder. You can build the image locally or directly on your cloud provider. <BR>
If you are doing locally go to the Dockerfile directory and run `docker build -t spark2_2 .` and then use `docker pull` to put the image into your repository.<BR>
Name the spark image as `spark2_2` and the jupyter image as `jupyter`.
>If you plan on pulling your image you might have to tag it with the repository address first.

>If you plan to use the Jupyter and JupyterHub image use the Python 3.5 image otherwise pick the one you want to.

2. Since the idea is to have a shared volume across all Spark nodes, we need to create a persistent volume claim in the Kubernetes cluster. The file `spark-pvc.yml` is the one I'm using on IBM Bluemix, you can replace that for any PVC you want to. If you keep its name you don't have to worry about the other objects we are going to create further on.
>If you need to know more about Persistent Volumes go to the [Kubernetes Persistent Voumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) page. This is a nice post about [Creating hostPath volumes on Kubernetes](https://myjavabytes.wordpress.com/2017/03/12/getting-a-host-path-persistent-volume-to-work-in-minikube-kubernetes-run-locally/).
