# Simple PHP Application with New Relic Instrumentation

This repository contains a simple PHP application instrumented with the New Relic APM agent.
It includes instructions for building and deploying the application using Docker locally, and on a Kubernetes (Minikube) cluster for APM.
Additionally, an example for setting up New Relic infrastructure monitoring for the Kubernetes cluster itself is provided.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* [Minikube](https://minikube.sigs.k8s.io/docs/start/) (for Kubernetes deployment)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (for Kubernetes deployment)
* [Helm](https://helm.sh/docs/intro/install/) (if deploying Kubernetes infrastructure monitoring via Helm)
* A New Relic account and your **Ingest License Key**. You can find this in your New Relic account under (Account settings > API keys > Ingest - License). Replace all instances of `<YOUR_NEW_RELIC_LICENSE_KEY>` in the commands below with your actual key.

## Project Structure

A brief overview of the typical project structure:

```
.
├── kubernetes/                # Kubernetes manifest files
│   ├── deployment.yaml
│   └── service.yaml
├── src/                       # PHP application source code
│   └── index.php              # Main PHP application file
├── Dockerfile                 # Defines the Docker image for the PHP application
├── docker-entrypoint.sh       # Script to configure New Relic at container startup
└── README.md                  # This file
```

---

## 1. Local Docker Deployment (Application APM)

This section describes how to build and run the instrumented PHP application locally using Docker.

**a. Build the Docker Image:**

```bash
# For M1/ARM64 Mac users, explicitly specifying the platform is recommended:
docker build --no-cache --platform linux/arm64 -t simple-php-app .

# For other platforms (e.g., Intel Macs, Linux amd64), you can often omit --platform:
# docker build --no-cache -t simple-php-app .
```

Note: --no-cache ensures a fresh build, useful during development but can be slower. Omit it for subsequent builds to use Docker's cache.

**b. Run the Docker Container:**

Replace <YOUR_NEW_RELIC_LICENSE_KEY> with your actual New Relic Ingest License Key.

```bash
docker run --platform linux/arm64 -d \
  -e NEW_RELIC_LICENSE_KEY="<YOUR_NEW_RELIC_LICENSE_KEY>" \
  -e NEW_RELIC_APP_NAME="Simple PHP App (Local Docker)" \
  -p 8080:8080 \
  --name my-php-app-instance \
  simple-php-app
```

Note: If you built without --platform linux/arm64, omit it from the docker run command as well.

Once the container is running, your application should be accessible at http://localhost:8080, and APM data should start appearing in your New Relic account under the application name "Simple PHP App (Local Docker)".

---

## 2. Kubernetes Deployment (Minikube - Application APM)

This section guides you through deploying the instrumented application to a local Minikube Kubernetes cluster.

**a. Start Minikube:**

If Minikube is not already running:

```bash
minikube start
```

For M1/ARM64 Mac users, you might need to specify a driver compatible with arm64, e.g., `--driver=docker` or ensure your Minikube VM supports arm64.

**b. Build the Docker Image within Minikube's Environment:**

To ensure Minikube can find the image, build it within Minikube's Docker daemon:
```bash
eval $(minikube -p minikube docker-env)

# Build the image.
# Ensure your Minikube VM's architecture is compatible with the build.
# For default Minikube (often amd64) or M1 Macs with an arm64 Minikube VM:
docker build --no-cache -t simple-php-app .
# If you are on an M1 Mac and your Minikube VM is specifically arm64,
# you might use --platform linux/arm64, but test compatibility.
```

Note: After this, if you want to use your local Docker daemon again, you might need to run `eval $(minikube docker-env -u)`.

**c. Create Kubernetes Secrets for New Relic:**

Replace `<YOUR_NEW_RELIC_LICENSE_KEY>` with your actual key.
```bash
kubectl create secret generic newrelic-secret \
  --from-literal=NEW_RELIC_LICENSE_KEY="<YOUR_NEW_RELIC_LICENSE_KEY>" \
  --from-literal=NEW_RELIC_APP_NAME="Simple PHP App (K8s)"
```
**d. Deploy the Application:**

This assumes you have deployment.yaml and service.yaml files in a kubernetes/ directory within this repository. These files should define how your application is deployed and exposed. Ensure the deployment.yaml references the newrelic-secret for environment variables.

```bash
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
```

(You should provide example deployment.yaml and service.yaml files in the repo for users).

**e. Accessing the Application:**

1. View Kubernetes Dashboard (Optional):
    
    ```bash
    minikube dashboard
    ```

    This provides a web UI to inspect your cluster, pods, logs, etc.

2. Expose the Service:
    If your service.yaml defines a service of type LoadBalancer, use minikube tunnel in a separate terminal window:
    ```bash
    minikube tunnel
    ```

    This will provide an external IP for your service. If using NodePort, find the Minikube IP (minikube ip) and the assigned NodePort.

3. Access in Browser:
    Once exposed, you should be able to access the application (e.g., `http://<EXTERNAL_IP_FROM_TUNNEL>:8080` or `http://$(minikube ip):<NODE_PORT>)`. APM data will appear under "Simple PHP App (K8s)".

---
## 3. Kubernetes Cluster Monitoring with New Relic (Example)

To monitor the Kubernetes cluster itself (nodes, overall pod health, events, logs, etc.), you can install New Relic's Kubernetes integration.

Important: New Relic's installation methods, Helm chart versions, and recommended configurations for Kubernetes evolve rapidly. Always refer to the [official New Relic Kubernetes integration documentation](https://docs.newrelic.com/docs/kubernetes-pixie/kubernetes-integration/get-started/introduction-kubernetes-integration/) for the most current, detailed, and guided installation steps. The New Relic UI often provides the most up-to-date instructions.

The following Helm command is provided as an example of how this might be done and may require adjustments:

```bash
# Define your New Relic License Key and Cluster Name
export NR_LICENSE_KEY="<YOUR_NEW_RELIC_LICENSE_KEY>"
export NR_CLUSTER_NAME="minikube-cluster" # Choose a name for your cluster

# Add New Relic Helm repo
helm repo add newrelic https://helm-charts.newrelic.com
helm repo update

# Create a namespace for New Relic components
kubectl create namespace newrelic

# Example Helm installation command (verify options against current New Relic docs)
helm upgrade --install newrelic-bundle newrelic/nri-bundle \
  --set global.licenseKey=$NR_LICENSE_KEY \
  --set global.cluster=$NR_CLUSTER_NAME \
  --namespace=newrelic \
  --set newrelic-metadata-injection.enabled=true \
  --set newrelic-infrastructure.privileged=true \
  --set global.lowDataMode=true \
  --set kube-state-metrics.enabled=true \
  --set kubeEvents.enabled=true \
  --set newrelic-prometheus-agent.enabled=true \
  --set newrelic-prometheus-agent.lowDataMode=true \
  --set newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled=false \
  --set logging.enabled=true \
  --set newrelic-logging.lowDataMode=true
```

Replace `<YOUR_NEW_RELIC_LICENSE_KEY>` before running.
This example installs various components. You can customize these based on your needs by referring to the `nri-bundle` chart's values and the official documentation.

**Optional: Using values.yaml for New Relic Kubernetes Integration:**

For more control over the New Relic Kubernetes integration configuration, you can use a sample values file that's included in the repository:

```bash
# Copy the sample values file to create your own configuration
cp values.sample.yaml values.yaml

# Replace placeholders with your actual values
sed -i '' "s/YOUR_LICENSE_KEY/$NR_LICENSE_KEY/" values.yaml
sed -i '' "s/YOUR_CLUSTER_NAME/$NR_CLUSTER_NAME/" values.yaml

# Review the values file and make any additional customizations
cat values.yaml

# Install using the values file
helm upgrade --install newrelic-bundle newrelic/nri-bundle \
  -f values.yaml \
  --namespace newrelic
```

This approach provides more flexibility and makes configuration changes easier to track. The sample values file includes commonly used settings that you can customize for your environment.

---
## Verification

- APM Data: After deploying your application (local Docker or Kubernetes) and generating some traffic, log in to your New Relic account. Navigate to "APM & Services." You should see your application listed (e.g., "Simple PHP App (Local Docker)" or "Simple PHP App (K8s)") and be able to drill into transaction traces, errors, etc.
- Kubernetes Cluster Data: If you installed the Kubernetes integration, navigate to "Infrastructure" -> "Kubernetes" in New Relic to see data from your cluster.
- It might take 5-10 minutes for initial data to appear.

---
## Troubleshooting

- Ensure your `NEW_RELIC_LICENSE_KEY` is correct and an Ingest License Key.
- Check container/pod logs for any errors from the New Relic agent or daemon.
  - Local Docker: `docker logs my-php-app-instance`
  - Kubernetes: `kubectl logs <your-pod-name> -n <namespace>`
- Verify network connectivity from your container/pods to New Relic collector endpoints if data is missing.
- Consult the [New Relic Diagnostics CLI](https://www.google.com/search?q=https://docs.newrelic.com/docs/new-relic-solutions/troubleshooting-guides/diagnose/new-relic-diagnostics/) for advanced troubleshooting.
