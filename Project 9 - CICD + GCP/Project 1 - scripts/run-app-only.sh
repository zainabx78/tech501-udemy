#!/bin/bash

export DB_HOST=mongodb://172.31.63.185:27017/posts

cd /home/ubuntu/repo/app

npm install

pm2 start app.js