#!/bin/sh
set -e

# Validate env variables
: "${KUBE_SERVER?Need to set env var KUBE_SERVER}"
: "${KUBE_USER_NAME?Need to set env var KUBE_USER_NAME}"
: "${KUBE_USER_PASSWORD?Need to set env var KUBE_USER_PASSWORD}"
: "${GIT_SSH_PRIVATE_KEY?Need to set env var GIT_SSH_PRIVATE_KEY}"
: "${GIT_REPO?Need to set env var GIT_REPO}"
: "${GIT_REPO_NAME?Need to set env var GIT_REPO_NAME}"
: "${GIT_BRANCH?Need to set env var GIT_BRANCH}"
: "${DOCKER_TAG?Need to set env var DOCKER_TAG}"
: "${TENANT_ID?Need to set env var TENANT_ID}"
: "${CLUSTER_NAME?Need to set env var CLUSTER_NAME}"
: "${RESOURCE_GROUP?Need to set env var RESOURCE_GROUP}"

echo "ENV"
echo "KUBE_SERVER: $KUBE_SERVER"
echo "KUBE_USER_NAME: $KUBE_USER_NAME"
echo "GIT_REPO: $GIT_REPO"
echo "GIT_REPO_NAME: $GIT_REPO_NAME"
echo "GIT_BRANCH: $GIT_BRANCH"
echo "DOCKER_TAG: $DOCKER_TAG"
echo "TENANT_ID: $TENANT_ID"
echo "CLUSTER_NAME: $CLUSTER_NAME"
echo "RESOURCE_GROUP: $RESOURCE_GROUP"
echo

# Make sure we are in the root directory
cd /

# Make git ssh key usable
echo $GIT_SSH_PRIVATE_KEY | base64 -d > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keygen -y -f /root/.ssh/id_rsa > /root/.ssh/id_rsa.pub
ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
ssh-keyscan github.com >> /root/.ssh/known_hosts
ssh-keyscan vs-ssh.visualstudio.com >> /root/.ssh/known_hosts

# echo "id_rsa"
# cat /root/.ssh/id_rsa
# echo "id_rsa.pub"
# cat /root/.ssh/id_rsa.pub

git clone --depth 1 $GIT_REPO $GIT_REPO_NAME -b $GIT_BRANCH

# Inject DOCKER_TAG into deployment file
sed -i 's/${DOCKER_TAG}/'$DOCKER_TAG'/' $GIT_REPO_NAME/k8s/deployment.yml

# Create connection to cluster
az login --service-principal -u $KUBE_USER_NAME -p $KUBE_USER_PASSWORD --tenant $TENANT_ID
az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
kubectl config use-context $CLUSTER_NAME

echo "Listing server and client version of K8S: $KUBE_SERVER"
kubectl version

if [ -f $GIT_REPO_NAME/k8s/namespaces.$CLUSTER_NAME ]
then
    echo
    echo "Server: $CLUSTER_NAME"
    echo

    git --git-dir=$GIT_REPO_NAME/.git --work-tree=$GIT_REPO_NAME status
    ls -l $GIT_REPO_NAME/k8s

    # Inject DOCKER_TAG into deployment files
    if [ -f $GIT_REPO_NAME/k8s/deployment.yml ]; then
      sed -i 's/${DOCKER_TAG}/'$DOCKER_TAG'/' $GIT_REPO_NAME/k8s/deployment.yml
    fi

    if [ -f $GIT_REPO_NAME/k8s/statefulsets.yml ]; then
      sed -i 's/${DOCKER_TAG}/'$DOCKER_TAG'/' $GIT_REPO_NAME/k8s/statefulsets.yml
    fi

    # Apply config files
    for namespace in $(cat $GIT_REPO_NAME/k8s/namespaces.$CLUSTER_NAME)
    do
      if [ ! -z "$namespace" ]
      then
        echo "Working in namespace $namespace"
        echo 

        if [ -f $GIT_REPO_NAME/k8s/secrets.$CLUSTER_NAME.yml ]; then
          echo "Updating secrets"
          echo "$(cat $GIT_REPO_NAME/k8s/secrets.$CLUSTER_NAME.yml)"
          kubectl apply -f $GIT_REPO_NAME/k8s/secrets.$CLUSTER_NAME.yml -n $namespace
          echo "---"
          echo
        fi

        if [ -f $GIT_REPO_NAME/k8s/configmaps.$CLUSTER_NAME.yml ]; then
          echo "Updating configmaps"
          echo "$(cat $GIT_REPO_NAME/k8s/configmaps.$CLUSTER_NAME.yml)"
          kubectl apply -f $GIT_REPO_NAME/k8s/configmaps.$CLUSTER_NAME.yml -n $namespace
          echo "---"
          echo
        fi

        if [ -f $GIT_REPO_NAME/k8s/deployment.yml ]; then
          echo "Updating deployment"
          echo "$(cat $GIT_REPO_NAME/k8s/deployment.yml)"
          kubectl apply -f $GIT_REPO_NAME/k8s/deployment.yml -n $namespace
          echo "---"
          echo
        fi

        if [ -f $GIT_REPO_NAME/k8s/statefulsets.yml ]; then
          echo "Updating stateful sets"
          echo "$(cat $GIT_REPO_NAME/k8s/statefulsets.yml)"
          kubectl apply -f $GIT_REPO_NAME/k8s/statefulsets.yml -n $namespace
          echo "---"
          echo
        fi

        if [ -f $GIT_REPO_NAME/k8s/replicasets.yml ]; then
          echo "Updating replica sets"
          echo "$(cat $GIT_REPO_NAME/k8s/replicasets.yml)"
          kubectl apply -f $GIT_REPO_NAME/k8s/replicasets.yml -n $namespace
          echo "---"
          echo
        fi

        if [ -f $GIT_REPO_NAME/k8s/services.yml ]; then
          echo "Updating services"
          echo "$(cat $GIT_REPO_NAME/k8s/services.yml)"
          kubectl apply -f $GIT_REPO_NAME/k8s/services.yml -n $namespace
          echo "---"
          echo
        fi

        if [ -f $GIT_REPO_NAME/k8s/daemonsets.yml ]; then
          echo "Updating daemon sets"
          echo "$(cat $GIT_REPO_NAME/k8s/daemonsets.yml)"
          kubectl apply -f $GIT_REPO_NAME/k8s/daemonsets.yml -n $namespace
          echo "---"
          echo
        fi

        if [ -f $GIT_REPO_NAME/k8s/jobs.yml ]; then
          echo "Updating jobs"
          echo "$(cat $GIT_REPO_NAME/k8s/jobs.yml)"
          kubectl apply -f $GIT_REPO_NAME/k8s/jobs.yml -n $namespace
          echo "---"
          echo
        fi

        if [ -f $GIT_REPO_NAME/k8s/backups.$CLUSTER_NAME.yml ]; then
          echo "Updating backups"
          echo "$(cat $GIT_REPO_NAME/k8s/backups.$CLUSTER_NAME.yml)"
          kubectl apply -f $GIT_REPO_NAME/k8s/backups.$CLUSTER_NAME.yml -n $namespace
          echo "---"
          echo
        fi
      fi
    done
else
  echo "Missing $GIT_REPO_NAME/k8s/namespaces.$CLUSTER_NAME file!"
  exit 1
fi