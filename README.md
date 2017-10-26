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
To create the PVC run: `kubectl apply -f spark-pvc.yml` (Assuming your are running from the same directory).
>If you need to know more about Persistent Volumes go to the [Kubernetes Persistent Voumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) page. This is a nice post about [Creating hostPath volumes on Kubernetes](https://myjavabytes.wordpress.com/2017/03/12/getting-a-host-path-persistent-volume-to-work-in-minikube-kubernetes-run-locally/).

>I'm using a shared volume so we have a place to store the spark jobs or keep a directory in it sinchronized with some git repository. Besides that, it also allows you to read data from the shared volume into some Spark job since all workers need to have access to that.

3.It's time to create the Spark master deployment, it will be just one replica since it's the master.<BR>
Make sure to change the image name within the `spark-master-dep.yml` file (line 14) so it's the same as you have in your registry.<BR>
Run the following command:
```
kubectl create -f spark-master-dep.yml
```

4. Create the Spark master headless service. This is the service used to give the master a fixed name so all the workers and notebooks are able to connect to the Spark cluster. Run the following command:
```
kubectl create -f spark-master-service.yml
```

5. Now that our Spark master is running and accessible from within the cluster, let's create the slave / worker deployment.<BR>
Double check if the image name is the same as you are using in your environment in the `spark-slave-dep.yml` file (line 14).<BR>
Run the following command to create the deployment:
  ```
  kubectl create -f spark-slave-dep.yml
  ```
>This is the amazing thing about Kubernetes, it's only needed one deployment for the slaves. Since I set the 'replicas' parameter to 2 in this case, we have a standalone spark cluster with 2 workers and we can easily scale it as I'll show you later.
  
By now your cluster should be up and running. You can check that your 3 pods are up running `kubectl get pods`. You should see 3 pods one called spark-master-... and two called spark-slave-....

### Accessing the Spark UI
Since we don't want to expose our Spark master UI interface publicly and also improve security in our environment, we can use a feature Kubernetes provide called 'port-forward' which allows us to map a specific port from a specific port within the Kubernetes cluster to our local machine and make that accessible though our localhost for the time needed (like running a nodejs or python flask app locally). To do so, first get your spark master complete pod name. Run `kubectl get pods` and copy its name and then run:
```
kubectl port-forward <your spark master pod name> 8080:8080
```
That's it, just go to your browser and open localhost:8080 to access the Spark master UI.
>You might need to port-forward the workers UI as well if you want to check workers details. To do that simply follow the same process above replacing the pod name for the one you want to. The default port workers UI listen to is 8081. To avoid port conflicts on your local machine you can map the ports (right number to the colon) to whichever you want too.

### Create and Run the Jupyter notebook
Assuming you have already created the Jupyter image on step one above let's create the jupyter deployment. Run the following and don't forget to replace the image name in the file (line 14) for the one you have.
```
kubectl create -f jupyter-dep.yml
```
To access the interface you need to port-forward the pod port 8000 like I showed previously.
>I setup this notebook in a way more than one user is able to access it, so I installed JupyterHub to manage access. By default the user 'jupyter' and password 'spark' is the admin. You can create more users by adding new users to the linux image the notebook is running.<BR><BR>
For more details on managing users go to the [JupyterHub page](https://jupyterhub.readthedocs.io/en/latest/getting-started/authenticators-users-basics.html).<BR><BR>
I've also setup SSL access. To view the implementation details check the 'init.sh' script in the 'JupyterImage' directory and to learn more go the the [SSL Page for JupyterHub](https://jupyterhub.readthedocs.io/en/latest/getting-started/security-basics.html).

To access and run your notebook using your Spark cluster, after creating a new Python 3 Jupyter notebook, use the following code on the first cell:
```
import os
import pyspark

os.environ["SPARK_HOME"] = "/home/spark/spark-2.2.0-bin-hadoop2.7"
os.environ["PYSPARK_PYTHON"]="/usr/bin/python3"

sc = pyspark.SparkContext('spark://spark-master:7077')
```
To test you can run the following code snippet in a second cell:
```
rdd = sc.parallelize(range(10))
rdd.collect()
```
After running the second sell you should be able to view the ten number printed.

### Final Comments
This code is still under development, there are several features to add and improve like allowing users to install libs straight from the notebook, setup the notebooks to run pyspark during the notebook startup avoiding the spark context created in the notebook cell, adding high availability to the spark master and others. Feel free to collaborate.
