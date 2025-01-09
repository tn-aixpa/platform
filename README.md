# Platform

This repository provides deployment guidelines and some example use cases for the platform.

The deployment and usage instructions for each use case can be found in the *docs* folder.

The platform deployment is managed via Docker Compose. Each documented use case requires a subset of components and has a corresponding YAML file in the *docker-compose* folder. The same folder also contains Docker Compose files for single components.

## Installation on minikube

### Prerequisites 
- [Helm](https://helm.sh/docs/intro/install/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)

### Installation

1. Start minikube (change 192.168.49.0 if your network setup is different):
```sh
    minikube start --insecure-registry "192.168.49.0/24" --memory 8192 --cpus 4
```
2. Get minikube external IP:
```sh
    minikube ip
```
3. Change the IP in  'global.registry.url' and 'global.externalHostAddress' properties in values file (*helm/platform/values.yaml*) with the one obtained in the previous step.
4. Add the platform repository:
```sh
helm repo add platform https://scc-digitalhub.github.io/digitalhub/
```
5. Install the platform with Helm:
```sh
    helm upgrade platform platform/platform -n platform --install --create-namespace --timeout 15m0s
```
6. Wait until all pods are in Running state
```sh
    kubectl --namespace platform get pods
```
7. Retrieve database and S3 secrets
```sh
    kubectl --namespace platform get secret minio -o yaml
    kubectl --namespace platform get secret platform-owner-user.database-postgres-cluster.credentials.postgresql.acid.zalan.do -o yaml
```
8. Decode secret values
```sh
    echo -n "<BASE64_VALUES_FROM_SECRET>" | base64 -d 
```
9. Create secret with previously decoded values
```
    kubectl -n platform create secret generic platform-common-creds --from-literal=POSTGRES_USER=<DECODED_VALUE> --from-literal=POSTGRES_PASSWORD=<DECODED_VALUE> --from-literal=AWS_ACCESS_KEY_ID=<DECODED_VALUE> --from-literal=AWS_SECRET_ACCESS_KEY=<DECODED_VALUE>
```
