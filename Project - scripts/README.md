# Project
## Use Scripting and User Data for 2-Tier App Deployment

![alt text](<../Images/Screenshot 2025-02-20 113434.png>)

## Why the manual process isn't ideal

- Time-consuming process for every new instance.
- Prone to human errors during setup.
- Difficult to ensure consistency across multiple deployments.
- Requires SSH access and manual intervention.
- Slows down recovery in case of instance failure.
- Inefficient for scaling when deploying multiple instances.

## The automated process using bash scripts and user data 

In this project, I created 3 bash scripts for my 2-tier app deployment. 
These scripts include:
- [prov-app.sh](app-bash-script)
- [prov-db.sh](db-bash-script)
- [run-app-only.sh](run-app-only.sh)



The prov-db.sh bash script:
- My bash script for the deployment of my database. This includes installation of mongodb and configurating it to be running and be accepting access from 0.0.0.0/0.

The prov-app.sh bash script:
- My bash script for the deployment of my app. This script installs the dependencies for the app and also gets the app code from the github repository. It also allows connection to the db. 

The run-app-only.sh bash script:
- This bash script is used after images are created from the other 2 scripts. Once the images are created, this bash script is used in the userdata section when creating an ec2 from the app image. This is so I can change the private IP of the database in the image as it will overwrite it so I can connect to the db. 

## Blockers:

- When using the app image to deploy the app, I found that the app couldn't connect to the database. This was due to the private IP of the database changing everytime I deployed a db using the image. 
    - I solved this by creating the run-app-only.sh bash script which allowed me to change the private IP in the image. Connection was then allowed. 

## Benefits

- Significant reduction in setup time.

- Less human error during deployments.

- Easier instance recovery and scaling.

## Project Management

- Tasks were tracked using GitHub Projects.

- Board included columns: To Do, In Progress, Done.
  
![alt text](<../Images/Screenshot 2025-02-20 114418.png>)