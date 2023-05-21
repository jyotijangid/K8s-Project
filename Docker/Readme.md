# Build & Store Docker images

1. Create Dockerfile for frontend & backend application.
2. Build the images.
3. Push the docker images to docker repository.

#### 1. Create Dockerfile for frontend & backend application.
The dockerfiles are created /Docker directory. 
The files have a base image, the code is copied, other required packages are downloaded & then using `run & cmd` we are able to start the services.

#### 2. Build the images 
```
docker build app-frontend.dockerfile -t app-frontend:v1
docker build app-backend.dockerfile -t app-backend:v1
```

#### 3. Push the images to ECR (as we are using AWS).

```
# Frontend
docker tag app-frontend:v1 <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/app-frontend:v1
docker push <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/app-frontend:v1

# Backend
docker tag app-backend:v1 <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/app-backend:v1
docker push <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/app-backend:v1
```