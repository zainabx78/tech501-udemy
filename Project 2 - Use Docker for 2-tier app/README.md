# DevOps Project 8 – Use Docker for App Deployment

## Microservices

- Architectural style - Application is structured as a collection of small, loosely coupled services. 
- Independent - Each service can be deployed independently.
- Resilience - One failure doesn't bring down the whole system. 

## Containers

- Lightweight, portable and self-sufficient units that package an application and all it's dependencies.
- Ensure that software runs consistently across different computing environments.
- Portability: Can run across various operating systems and cloud platforms.
- Isolation: Ensures that applications do not interfere with each other.
- Efficiency: Uses fewer resources compared to virtual machines.
- Speed: Faster boot-up and deployment.

## VMs vs Containers

### VMs
- Full OS for each VM.
- High resource usage (each VM requires an OS).
- Boot time = slow.
- Portability is limited due to OS dependencies.
- Less scalable due to resource needs.

### Containers
- Shares OS kernel.
- Lightweight (shares OS, fewer resources).
- Boot time = fast.
- High portability.
- Easily scalable.


## Docker

- Containerization platform that enables developers to build, deploy and manage containers efficiently. 
- Key Components of Docker:
    - Docker Engine: The core runtime for building and running containers.
    - Docker Hub: A cloud-based registry for sharing container images.
    - Docker Compose: A tool to define and run multi-container applications.
    - Dockerfile: A script containing instructions to build a Docker image.
    - Images: Read-only templates for creating containers.
    - Containers: Instances of Docker images.
    - Volumes: Persistent storage for containers.
    - Networking: Enables communication between containers and external systems.

Docker uses a client-server architecture:
- Docker Engine: Runs and manages containers.
- Docker Client: CLI tool to interact with Docker.
- Docker Daemon: Background service handling container operations.
- Docker Hub/Registry: Cloud-based storage for container images.

Alternatives to Docker

- Podman (Docker-compatible, daemonless, rootless security model)
- LXC (Linux Containers) (Lightweight OS-level virtualization)
- rkt (Rocket by CoreOS) (Security-focused container runtime)
- OpenShift (Enterprise Kubernetes distribution with container support)
- Kubernetes (Primarily for container orchestration but works with different runtimes)

## Docker compose 

- Tool for defining and managing multi-container Docker applications.
- Simplifies development, testing and deployment by allowing users to define and run multiple services using a single YAML configuration file (docker-compose.yml).
- Key benefits include:

  - Easier Multi-Container Management: Simplifies starting and stopping multiple services (e.g., databases, APIs, frontends).
  - Declarative Configuration: Uses a YAML file to define services, networks, and volumes
  - Portability: Enables easy environment replication across development, testing, and production.
  - Dependency Management: Ensures all required services start in the correct order.
  - Scalability: Supports service scaling for different workloads.

### How to use Docker Compose:
- 

# PROJECT - Using Docker For App Deployment

- Docker desktop already installed on my pc. 
- `docker ps` to show all the containers running currently on my pc - should show none for now. 
- `docker ps -a` to show all current and past containers.

![alt text](<../Images/Screenshot 2025-02-24 103427.png>)

## Creating a docker container
1. Authenticate - `docker login` (account created already from before).
   - Get username and password from chrome password manager (docker.com).
  
![alt text](<../Images/Screenshot 2025-02-24 105356.png>)

1. `docker pull ubuntu:22.04` - Pulls the image from a public repository. 


![alt text](<../Images/Screenshot 2025-02-24 113521.png>)

3. Check the image has been downloaded: `docker images`

![alt text](<../Images/Screenshot 2025-02-24 105639.png>)

4. Create the docker container - 
   - `docker run` - this command pulls image and starts docker container at the same time. 
   - `docker run -d -p 6000:6379 --name hello-world-sparta ubuntu:22.04`
   - By default, Ubuntu containers start, execute their command, and then exit if no interactive process is running.
   - `docker ps -a` - Should see container was running but exited straight away. 

![alt text](<../Images/Screenshot 2025-02-24 110635.png>)



- Multiple containers can run on the same host machine (pc, laptop etc).

- Your laptop or pc only has certain ports available.

- This could create conflict when the same port is used on your host machine.

- The container won't be reachable without port binding.

## Run nginx web server in a Docker container

- Install the latest image of nginx:
  `docker pull nginx`

![alt text](<../Images/Screenshot 2025-02-24 113952.png>)

- Run the container image on port 80 
- `docker run -d -p 80:80 --name sparta-nginx nginx` 
- The `-d` flag ensures to run the container in detached mode so it doesn't stop. 
- When you run a container with -d, it runs in the background instead of keeping the terminal occupied. This is useful when running services that should keep running independently.
- `docker ps` to check the running container
  
![alt text](<../Images/Screenshot 2025-02-24 114101.png>)

- If it's running correctly, should see it running in browser on local host (127.0.0.1).

![alt text](<../Images/Screenshot 2025-02-24 114618.png>)

- Stop the container using `docker stop <containerID>`.

![alt text](<../Images/Screenshot 2025-02-24 115239.png>)

## Remove a running container

- Remove the previous container `docker rm <containerID>` (it's stopped).
- Start nginx container again
- `docker run -d -p 80:80 --name sparta-nginx nginx`
- Try to remove the running container - get error.

![alt text](<../Images/Screenshot 2025-02-24 120005.png>)

- Can forcefully remove a running container with `-f`
`docker rm -f <containerID>`

![](<../Images/Screenshot 2025-02-24 120444.png>)

## Modify nginx default page in our running container

- Re-run the container on port 80.
- `docker run -d -p 80:80 --name sparta-nginx nginx`
- Access the shell of the container running:
`docker exec -it <containerID> /bin/bash`

- Recieved an error 

![alt text](<../Images/Screenshot 2025-02-24 121305.png>)

- To fix this, just use bash at the end instead of /bin/bash

`docker exec -it sparta-nginx bash`

![](<../Images/Screenshot 2025-02-24 121547.png>)

- Run these commands in the shell:
    - `apt update`
    - `apt upgrade`
    - when using `sudo`, gives the error of no sudo command found.
    - Install sudo `apt install sudo`
    - Navigate to the index.html file of nginx.
      - `cd /usr/share/nginx/html/`
      - `nano index.html`
      - nano command not found - install nano.
      - `sudo apt install nano`
      - Edit the file from `welcome to nginx` to `welcome to the tech501 Dreamteam!`- save and exit.
      - Should be able to see the changes on the webpage.
  
![alt text](<../Images/Screenshot 2025-02-24 122925.png>)

## Running a 2nd container on port 80- won't work.

- `docker run -d -p 80:80 --name sparta-2nd daraymonsta/nginx-257:dreamteam`
- This container won't run due to conflicting ports (nginx container already running on port 80).

![alt text](<../Images/Screenshot 2025-02-24 123225.png>)

- Remove the container that didn't start 
  - `docker rm <containerID>`
- Should only see nginx container when running `docker ps -a`.
- Run the container again but this time on port 90 on local machine but still port 80 on container (it's a different container so port is free).
- `docker run -d -p 90:80 --name sparta-2nd daraymonsta/nginx-257:dreamteam`
- Check access by accessing this container on localhost:90
- Should show a different tech group (on nginx container its tech501 but on port 90 its 257).

![alt text](<../Images/Screenshot 2025-02-24 124507.png>)

## Creating an image from the container and pushing it to Docker Hub

- Create an image from the container:
`docker commit sparta-nginx custom-nginx`
- Sparta-nginx = running container.
- custom-nginx = new image.
- commit = to commit changes made to nginx container to the image.
- `docker images` - should see your new image created.

Pushing the image to dockerhub:
- Already used `docker login` to authenticate. 
- Tag the image: `docker tag custom-nginx zainab7861/custom-nginx:latest`
- Push the image to my docker hub 
`docker push zainab7861 custom-nginx:latest`

![alt text](<../Images/Screenshot 2025-02-24 130058.png>)

- Run a container using that custom image from dockerhub:
`docker run -d -p 100:80 --name my-nginx-fromimage zainab7861/custom-nginx:latest`
- Used port 100 to avoid port clashes.
- Should see same nginx file that i edited on port 100 too.


![alt text](<../Images/Screenshot 2025-02-24 130421.png>)

## Automate docker image creation using a dockerfile

- New folder in the udemy repo- `tech501-mod-nginx-dockerfile`
- Add a nginx page to use instead of the default one `echo "<h1>Welcome to My Custom Nginx Page</h1>" > index.html`

**Create a dockerfile:**
- `touch Dockerfile`
- `nano Dockerfile`
- Enter these contents into the dockerfile:
```
# Use the official Nginx base image
FROM nginx:latest

# Copy custom index.html to the default Nginx web root
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80
```
**Build custom image from dockerfile:**

`docker build -t tech501-nginx-auto:v1 .`
The `.` means current directory.

![alt text](<../Images/Screenshot 2025-02-24 131657.png>)

**Run the container with docker image created from docker file:**

- `docker run -d -p 8080:80 --name my-custom-nginx tech501-nginx-auto:v1`
- Should see the custom html page in browser on port 8080:

![alt text](<../Images/Screenshot 2025-02-24 132007.png>)


**Pushing custom image to dockerhub:**
- First tag the image for dockerhub - `docker tag tech501-nginx-auto:v1 zainab7861/tech501-nginx-auto:v1`
- Push the image to my Docker Hub:
`docker push zainab7861/tech501-nginx-auto:v1`

- Run a container using this new image:
`docker run -d -p 8081:80 --name my-custom-nginx3 zainab7861/tech501-nginx-auto:v1`

- Use `docker rmi` to remove images locally.
- Clean up - remove the running containers.
- Delete the local images created using the docker file.
-  `docker rmi -f <image name:tag>`
- Create a new image by pulling custom image from dockerhub:

    `docker run -d -p 8080:80 --name my-custom-nginx zainab7861/tech501-nginx-auto:v1`

![alt text](<../Images/Screenshot 2025-02-24 133910.png>)
