Noova Cluster Deployment Image
=======================================
The image responsible for handling deployments to clusters running in Azure AKS

#### Building and pushing the docker Image
```
docker login -u milesdrift -p xyz
docker build -t milesdrift/aks-deploy:latest .
docker push milesdrift/aks-deploy
```
