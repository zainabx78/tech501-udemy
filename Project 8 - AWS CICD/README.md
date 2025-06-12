# Building Microservices and a CI/CD Pipeline with AWS

## PLAN:
- Frontend = 
  - Route53 (DNS routing to load balancer)
  - Amazon CloudFront (Content delivery network for caching static content)
  - Amazon S3 (Store static assets- object storage).

- Application layer = 
  - Load Balancer (Load balances traffic to ECS services)
  - Amazon ECS (containerized microservices orchestration)
  - Amazon ECR (to store the docker container images)
  - AWS CodePipeline, and CodeBuild (for CICD pipeline)

- Database Layer
  - Amazon RDS (PostgreSQL/MySQL) – Managed relational DB for user, order data
  - Amazon DynamoDB – Optionally used for high-throughput NoSQL access (e.g., catalog)

- Networking
  - Amazon VPC with private/public subnets
  - NAT Gateway – For private resources to access the internet

- Monitoring & Logging
  - Amazon CloudWatch – Metrics, logs, alarms

- Blue/Green Deployment
  - AWS CodeDeploy integrated with ECS for blue/green deployments


# LAB:

## Testing the app
- Login to aws account - used AWS Academy lab. 
- Ec2 - monolithic app server ec2 - open public IP in browser (only opens http not https).
- Should see the coffee suppliers application. 
- If you add supplier and edit - should work too. 

## Getting into EC2 Instance

- From Lab page, click on `AWS details` and download the PPK ssh key. This is the ssh key for the EC2 instance. 
- Use putty or git bash command - ssh into EC2 using the ssh key. 
  - `ssh -i ~/.ssh/aws-key-zainab.pem ubuntu@34.240.212.209` - make sure path and file and ec2 ip is correct. This is just example of the command.
- Run `sudo lsof -i :80` command in ec2 terminal`
  - This command lists all processes using port 80 (the default HTTP port).
- Run `ps -ef | head -1; ps -ef | grep node`
  - This command:
    - Prints the header line of ps -ef
    - Then filters for lines that contain the word "node" — showing all node processes

![alt text](<Images/Screenshot 2025-06-09 145218.png>)

- Analyse the application structure

```
cd ~/resources/codebase_partner
ls
```
- Index.js file exists here. 
- Run `nmap -Pn <dbendpoint>` 
  - By default, nmap pings a target to check if it's alive before scanning ports.
  - With -Pn, nmap skips this ping and scans the ports directly.

### Connecting to db through ec2 terminal

- `mysql -h supplierdb.cl7oljwgcvhv.us-east-1.rds.amazonaws.com -u admin -p` Enter password too when prompted.

- `SHOW DATABASES;`
- `USE COFFEE;`
- `SHOW TABLES;`
- The coffee database has different tables in it. 
![alt text](<Images/Screenshot 2025-06-10 130300.png>)

- `SELECT * FROM suppliers;` - shows the database connected to the app - shows the entry you added. 

![alt text](<Images/Screenshot 2025-06-10 130338.png>)

## Creating a development environment and checking code into a Git repository

### Create a cloud9 IDE

- Name: `MicroservicesIDE`
- t3.small
- Amazon Linux 2
- Should support ssh connections
- Run in same VPC as EC2 (public, labvpc)