#Spark Master
FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
 wget \
 vim \
 sudo \
 default-jdk \
 python3 \
 python3-pip \
 npm \
 nodejs-legacy \
 scala && cd /home && mkdir spark && cd spark && mkdir jupyter_conf && \
 wget http://ftp.unicamp.br/pub/apache/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz && \
 tar -xvf spark-2.2.0-bin-hadoop2.7.tgz && \
 pip3 install --upgrade pip && \
 pip3 install jupyter && \
 pip3 install pyspark && \
 python3 -m pip install jupyterhub && \
 npm install -g configurable-http-proxy

COPY init.sh /home/spark/init.sh

RUN chmod -R 775 /home/spark/

RUN sh /home/spark/init.sh

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV SPARK_HOME /home/spark/spark-2.2.0-bin-hadoop2.7
ENV PYSPARK_PYTHON python3
#ENV PYSPARK_SUBMIT_ARGS "--master spark-master:7077"
ENV PATH /home/spark/spark-2.2.0-bin-hadoop2.7/bin:${PATH}
