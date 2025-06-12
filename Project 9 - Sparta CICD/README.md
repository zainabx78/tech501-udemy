# DevOps Project – CI/CD Pipeline Implementation

- The goal of this project is to implement a CI/CD pipeline utilising AWS or Azure services for efficient software delivery. 
- The system should use:
  - Jenkins 
  - Docker
  - Kubernetes

## 

[GitHub] → [Jenkins CI/CD] → [Docker Hub]
                             ↓
                [Kubernetes on Cloud VM]
                             ↓
                     [Running Web App]

## WORKFLOW
- You write or update code and push it to GitHub.

- GitHub notifies Jenkins: “Hey, new code is here!”

**Jenkins:**

- Pulls your code

- Builds a Docker container

- Pushes it to Docker Hub

- Tells Kubernetes to deploy it

**Kubernetes:**

- Pulls the new Docker image

- Starts or updates the app

- Keeps it running and healthy



##  CI/CD Workflow

1. Developer pushes code to GitHub.
2. GitHub triggers a **webhook** to Jenkins.
3. Jenkins:
   - Pulls the latest code.
   - Builds a Docker image and tags it with a commit hash.
   - Pushes the image to Docker Hub.
   - Uses `kubectl` to update the Kubernetes deployment with the new image.
4. Kubernetes performs a rolling update.


##  Prerequisites & Setup

###  1. Infrastructure Setup

- Create an EC2 instance (Ubuntu 20.04) or Azure VM.
- Open ports: 22 (SSH), 8080 (Jenkins), 80/30000+ (App), 6443 (K8s API).
- Install:
  ```bash
  sudo apt update && sudo apt install -y docker.io openjdk-11-jdk git
  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    ``` 


  HAVENT DONE ANY OF THIS JUST TRYING TO UNDERSTAND HOW TO START IT AND WHAT TO DO:

  - Need to install jenkins on the vm and access it. 
  - Need to install kubernetes and docker on the same vm .
  - Connect jenkins pipeline to github repo. (repo with app inside).