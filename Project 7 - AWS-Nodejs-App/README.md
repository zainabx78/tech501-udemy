# Migrate a Nodejs + PostgreSQL application to AWS

## Create a VPC
1. Using AWS Cloudshell - create a VPC:
   
```
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=team-12-shop}]'

```
- This creates a VPC with a cidr block of `10.0.0.0/16` and a tag called `team-12-shop`.

## Create a subnet in that new VPC using cloudshell

```
aws ec2 create-subnet \
    --vpc-id vpc-08f1c524f3a0fc93a \
    --cidr-block 10.0.0.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ipv4-public-subnet-1}]'

```

- Create a 2nd subnet:

```
aws ec2 create-subnet \
    --vpc-id vpc-08f1c524f3a0fc93a \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ipv4-public-subnet-2}]'

```
## Create an internet gateway using cloudshell

```
aws ec2 create-internet-gateway
```
- Then, attach the internet gateway to the vpc

```
aws ec2 attach-internet-gateway \
    --internet-gateway-id igw-0ce00c5541798ddee \
    --vpc-id vpc-08f1c524f3a0fc93a

```
## Create a route using cloudshell
- This route ensures that any traffic from the VPC that doesn't match any other routes in the route table will be directed to the internet using the internet gateway. 

```
aws ec2 create-route \
    --route-table-id rtb-0e93cc59da6700c95 \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id igw-0ce00c5541798ddee

```
## Modify vpc settings:

```
aws ec2 modify-vpc-attribute \
    --vpc-id vpc-08f1c524f3a0fc93a \
    --enable-dns-hostnames


aws ec2 modify-vpc-attribute \
    --vpc-id vpc-08f1c524f3a0fc93a \
    --enable-dns-support

```

- both should now show as enabled in the vpc home page. 


## Create a new Elastic Beanstalk application

1. Use eb init to initialize a new application named shop in the us-east-1 region using the Node.js 18 platform:

```
eb init \
    --region us-east-1 \
    --platform "Node.js 18 running on 64bit Amazon Linux 2023" \
    shop
```
- In elastic beanstalk - menu - applications - should see an app created called shop.

2. Use the eb create command creates a single-instance, sample Elastic Beanstalk environment named "shop-production" within the specified VPC and subnets.

```
eb create shop-production \
    --vpc.id vpc-08f1c524f3a0fc93a \
    --vpc.ec2subnets subnet-04e03cde0852663be,subnet-0fe6cb1a85d2155ab \
    --single \
    --sample

```

- In the elastic beanstalk environment - applications - shop - shop production - status should be  `OK`. 
- If you click the URL of the application, should take you to a default `congratulations` page. 


## Deploy a new version of the application

- Download code - `wget https://github.com/vdespa/sample-shop-nodejs-postgres/releases/download/0.1.0/store-0.1.0.zip`
- Verify the size of the package installed - should be 4MB 
    `ls -l --block-size=M`
- Modify the config.yml file and add in the new file you downloaded into config.yml so it gets used for the application. 
    `nano .elasticbeanstalk/config.yml`
- At the end of file add in:
  
```
deploy:
  artifact: store-0.1.0.zip

```
- Save and exit (ctrl +x and then press enter to keep the same name for the file).
- Deploy the application: `eb deploy --label 0.1.0`
- Once health status is `OK` - open application url and it should be a different app page not the default congrats one. 


## Create an Amazon RDS database instance
- Need to create a subnet group for this
## Connect to database from AWS cloudshell

## Migrate the postgreSQL database to Amazon RDS

## Configure the application using environment variables

## Terminate all resources in the VPC