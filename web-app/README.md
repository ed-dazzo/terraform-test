# Introduction
The primary web appliation

# Build

Run `docker build . -t 726163525079.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest`

#Deploy

```
# Log into the ecr repo
aws ecr get-login-password --region=us-east-1 | docker login --username AWS --password-stdin 726163525079.dkr.ecr.us-east-1.amazonaws.com/hello-world
# Push the docker image to the hello-world repo
docker push 726163525079.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest
# Initiate an update
aws ecs update-service --cluster arn:aws:ecs:us-east-1:726163525079:cluster/hello-world --service hello-world  --force-new-deployment --region=us-east-1
```
