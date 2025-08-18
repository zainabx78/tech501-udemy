# Run Sparta Test App in a Container

1. Remove all running containers and images (docker rm -f or docker rmi -f).
2. Clone app into a folder with no dockerfile (new folder or current one if you used a new one previously).
   - `git clone https://github.com/zainabx78/tech501-sparta-app repo`
   - `ls` `cd repo` `unzip nodejs20-sparta-test-app.zip`

3. Create a Dockerfile in a new folder (one dockerfile per folder).
- In dockerfile:
```
# from which image
FROM node:20

# label
LABEL maintainer="zainabfarooq002@gmail.com" \
      description="A Node.js app with Docker"

# set the default working directory to /usr/src/app
WORKDIR /usr/src/app

# copy app folder (to same place as Dockerfile, then copy to default location in container)
COPY repo/app /usr/src/app

# COPY package*.json ./
COPY repo/app/package*.json ./

# install dependencies with npm
RUN npm install

# expose port
EXPOSE 80

# CMD [node app.js or npm start]
CMD ["npm", "start"]
```

## Build image from dockerfile

- `docker build -t zainab-sparta-app:v1 .`

## Run container with that image

- `docker run -d -p80:80 --name zainab-sparta-app-run zainab-sparta-app:v1`
- If you change things in the dockerfile, need to recreate the image to run the container with. 
- I had to change the directory structure in the Dockerfile since my app was in a repo folder first then app folder.
- `docker build -t zainab-sparta-app:v2 .`
- Use  `docker ps -a` with `docker rm <containerID>` to remove the unworking containers as you troublshoot. 
- BLOCKER: I was using node:14 and the version was too old. Upgraded to node:20 in the Dockerfile.

Then, I ran my updated image as a container:
`docker run -d -p80:80 --name zainab-sparta-app-run zainab-sparta-app:v3` (instead of making new names for the images everytime I created a new one for updates/changed to my dockerfile, i just changed versions at the end e.g. v1, v2, v3).

![](<../Images/Screenshot 2025-02-24 145019.png>)

- BLOCKER - when i did `docker logs <ID>` , my app was shown as running but I couldn't access it on port 80. This is because inside the container, my app is listening on port 3000. So, I had to change the ports to be able to access my app. 
- Removed the previous container that was running on port 80. 
- Created the container again 
- `docker run -d -p80:3000 --name zainab-sparta-app-run zainab-sparta-app:v3` 
- -p 80:3000: This means that port 80 on your host machine (the left side of the colon) is mapped to port 3000 inside the container (the right side of the colon).

![alt text](<../Images/Screenshot 2025-02-24 145710.png>)

## Push image to Docker Hub

- `docker tag 4f568d25fecf zainab7861/zainab-sparta-app:v3`
- `docker push zainab7861/zainab-sparta-app:v3`

- Remove local copy of the images `docker images` `docker rmi <id>`.
- Create container with pulled image from your docker hub:
`docker run -d -p80:3000 --name zainab-sparta-app-run zainab7861/zainab-sparta-app:v3`

![alt text](<../Images/Screenshot 2025-02-24 150657.png>)

![alt text](<../Images/Screenshot 2025-02-24 150650.png>)

## Using Docker Compose to run app and database

1. Create docker-compose.yml file:
```
version: "3.8"

services:
  mongo:
    image: mongo:7.0  # Use a stable MongoDB version
    container_name: mongo
    restart: always
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
    command: ["mongod", "--bind_ip", "0.0.0.0"]

  app:
    image: zainab7861/zainab-sparta-app:v3  # Replace with your actual image
    container_name: app
    restart: always
    depends_on:
      - mongo
    environment:
      DB_HOST: mongodb://mongo:27017/posts  # Set the correct MongoDB URI
    ports:
      - "3000:3000"
    stdin_open: true
    tty: true  # Allows SSH-like interaction

volumes:
  mongo-data:


```
2. Run the file to create the containers- `docker compose up -d`

![alt text](<../Images/Screenshot 2025-02-25 113458.png>)
![alt text](<../Images/Screenshot 2025-02-25 113504.png>)

3. SSH into the app container
`docker exec -it app bash` or sh at the end

4. When troublshooting and you change docker compose file, can restart the docker compose containers by stopping them and starting them again. 

![alt text](<../Images/Screenshot 2025-02-25 120345.png>)

## BLOCKER: App page working but not able to get posts page up:

![alt text](<../Images/Screenshot 2025-02-25 123431.png>)

![alt text](<../Images/Screenshot 2025-02-25 123440.png>)

SOLVED: Changed the environment variable in docker compose to the one used previously for db connection instead of a different way. 
- `DB_HOST: mongodb://mongo:27017/posts`

- Once db connection is established, seed the db:
- `docker exec -it app sh` - enter the app container
- `npm install`


![alt text](<../Images/Screenshot 2025-02-25 140546.png>)

- Go to the posts URL - should be working. 

![alt text](<../Images/Screenshot 2025-02-25 140520.png>)

## Automated way of connecting to db:

  `command: sh -c "npm install && node seeds/seed.js && npm start"`
- Add this command to the end of app container configuration to reduce manually going into the container to seed the db. 