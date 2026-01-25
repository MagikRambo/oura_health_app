# Oura Health App - K8s

## Deployment steps

docker build --platform linux/amd64 -t magikrambo.azurecr.io/oura-health-app:latest .

docker push magikrambo.azurecr.io/oura-health-app:latest

kubectl rollout restart deployment oura-health-app

