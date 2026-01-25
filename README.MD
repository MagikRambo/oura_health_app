# Oura Health App

A Node.js application for integrating with the Oura Ring API, built with TypeScript and Express. This application handles OAuth authentication and retrieves health data from Oura Ring devices.

## Features

- OAuth 2.0 authentication with Oura API
- Retrieves sleep, activity, and other health metrics
- Containerized deployment with Docker
- Kubernetes-ready for Azure Kubernetes Service (AKS)

## Prerequisites

- Node.js 20.x or higher
- Docker
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS) cluster
- Oura API credentials ([developer.ouraring.com](https://developer.ouraring.com))

## Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
OURA_CLIENT_ID=your_client_id
OURA_CLIENT_SECRET=your_client_secret
OURA_REDIRECT_URI=http://your-domain.com/callback
OURA_SCOPE=email personal daily
```

## Local Development

### Install Dependencies

```bash
npm install
```

### Run in Development Mode

```bash
npm run dev
```

The application will start on `http://localhost:3000`

### Build for Production

```bash
npm run build
npm start
```

## Docker Deployment

### Build the Image

Build the Docker image for AMD64 architecture (required for AKS):

```bash
docker build --platform linux/amd64 -t magikrambo.azurecr.io/oura-health-app:latest .
```

### Push to Azure Container Registry

```bash
docker push magikrambo.azurecr.io/oura-health-app:latest
```

### Run Locally with Docker

```bash
docker run -p 3000:3000 --env-file .env magikrambo.azurecr.io/oura-health-app:latest
```

## Kubernetes Deployment

### Create Secrets

Create a Kubernetes secret with your Oura API credentials:

```bash
kubectl create secret generic oura-secrets \
  --from-literal=OURA_CLIENT_ID=your_client_id \
  --from-literal=OURA_CLIENT_SECRET=your_client_secret \
  --from-literal=OURA_REDIRECT_URI=http://20.84.17.177/callback \
  --from-literal=OURA_SCOPE="email personal daily"
```

### Deploy to AKS

```bash
kubectl apply -f k8s-deployment.yaml
```

### Verify Deployment

```bash
kubectl get pods
kubectl get services
```

### Update Deployment

After making code changes and pushing a new image:

```bash
kubectl rollout restart deployment oura-health-app
```

### View Logs

```bash
kubectl logs -l app=oura-health-app --tail=100 -f
```

## API Endpoints

- `GET /` - Home page with login link
- `GET /login` - Initiates OAuth flow with Oura
- `GET /callback` - OAuth callback endpoint that exchanges code for access token

## Project Structure

```
.
├── src/
│   └── index.ts          # Main application entry point
├── Dockerfile            # Multi-stage Docker build
├── k8s-deployment.yaml   # Kubernetes deployment and service
├── .dockerignore         # Docker build exclusions
├── .npmrc                # NPM registry configuration
├── package.json          # Dependencies and scripts
└── tsconfig.json         # TypeScript configuration
```

## Security Notes

- Never commit `.env` files to version control
- Use Kubernetes secrets for sensitive data in production
- Consider using Azure Key Vault for enhanced secret management
- The application requires HTTPS for production deployments

## License

ISC

## Author

MagikRambo
