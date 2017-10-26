cd /home/spark/jupyter_conf

openssl req -x509 -nodes -days 365 -newkey rsa:1024  -batch -keyout jupyterhub_key.key -out jupyter_cert.pem
echo "key and certificate generated"

jupyterhub --generate-config
echo "jupyterhub config file generated"

echo "c.JupyterHub.ssl_cert = '/home/spark/jupyter_conf/jupyter_cert.pem'" >> /home/spark/jupyter_conf/jupyterhub_config.py
echo "c.JupyterHub.ssl_key = '/home/spark/jupyter_conf/jupyterhub_key.key'" >> /home/spark/jupyter_conf/jupyterhub_config.py
echo "c.Authenticator.admin_users = {'jupyter'}" >> /home/spark/jupyter_conf/jupyterhub_config.py

adduser --home /home/jupyter --disabled-password --gecos "" jupyter

echo "jupyter:spark"|chpasswd
