# Creating images from the bash scripts:

1. Create EC2's with the bash scripts:
   - First create the db vm as we need the private IP of the db to connect to the db from the app vm. 

- For the db vm: 
  - Need port 22 and 27017 open. 

- For the app vm:
  - Need port 3000 and 80 (http) and 22 (ssh) open.

2. Once vm's from the scripts are properly working (db is running and app is accessible with posts page), make the images from them:

![alt text](<../Images/Screenshot 2025-02-20 103039.png>)
![alt text](<../Images/Screenshot 2025-02-20 103310.png>)
![alt text](<../Images/Screenshot 2025-02-20 103408.png>)

## Launch instances from those AMI's.

1. First launch the db image ec2.
2. For the app image ec2, take the private ip of the db image ec2 and put it into userdata as it would have changed from the previous IP in the userdata:

```
#!/bin/bash

export DB_HOST=mongodb://172.31.63.185:27017/posts
cd /home/ubuntu/repo/app
npm install
pm2 start app.js

```

This private IP in the bash script will overwrite the one in the userdata in the image. 


![alt text](<../Images/Screenshot 2025-02-20 110507.png>)