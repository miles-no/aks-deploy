Noova Cluster Deployment Image
=======================================
The image responsible for handling deployments to clusters running in Azure AKS

#### Building and pushing the docker Image
```
az acr login --name amestoregistry
docker build -t noovaregistry.azurecr.io/deploy:latest .
docker push noovaregistry.azurecr.io/noova-deploy
```
