# Simple PHP Application

This is a simple PHP application that outputs "Hello, World!" when accessed via a web server. The application is containerized using Docker and can be deployed on a Kubernetes cluster.

## Project Structure

```
simple-php-app
├── src
│   └── index.php          # Entry point of the PHP application
├── Dockerfile             # Dockerfile to build the application image
├── kubernetes
│   ├── deployment.yaml    # Kubernetes deployment configuration
│   ├── service.yaml       # Kubernetes service configuration
│   └── ingress.yaml       # Kubernetes ingress configuration
├── .dockerignore          # Files to ignore when building the Docker image
├── README.md              # Project documentation
└── composer.json          # Composer configuration file
```

## Getting Started

### Prerequisites

- Docker
- Kubernetes (Minikube, GKE, AKS, etc.)
- Composer

### Building the Docker Image

To build the Docker image for the application, run the following command in the project root directory:

```
docker build -t simple-php-app .
```

### Running the Application Locally

You can run the application locally using Docker with the following command:

```
docker run -p 8080:80 simple-php-app
```

Alternatively, run:

```
docker compose up
```

Access the application at `http://localhost:8080`.

### Deploying to Kubernetes

1. Apply the deployment configuration:

```
kubectl apply -f kubernetes/deployment.yaml
```

2. Apply the service configuration:

```
kubectl apply -f kubernetes/service.yaml
```

3. (Optional) Apply the ingress configuration:

```
kubectl apply -f kubernetes/ingress.yaml
```

### Accessing the Application

Once deployed, you can access the application through the service or ingress, depending on your configuration.

## License

This project is licensed under the MIT License.