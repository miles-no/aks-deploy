Noova Cluster Deployment Image
=======================================
The image responsible for handling deployments to clusters running in Azure AKS

#### Usage
```
docker pull milesdrift/aks-deploy

docker run docker run -e KUBE_SERVER=asd -e KUBE_USER_NAME=asd -e KUBE_USER_PASSWORD=asd -e GIT_SSH_PRIVATE_KEY="base64 encoded private key" -e GIT_REPO=asd -e GIT_REPO_NAME=asd -e GIT_BRANCH=asd -e DOCKER_TAG=asd -e TENANT_ID=asd -e CLUSTER_NAME=asd -e RESOURCE_GROUP=asd milesdrift/aks-deploy
```


#### Building and pushing the docker Image
```
docker login -u milesdrift -p xyz
docker build -t milesdrift/aks-deploy:latest .
docker push milesdrift/aks-deploy
```
