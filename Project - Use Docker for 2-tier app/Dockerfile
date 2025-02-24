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