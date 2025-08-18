# Deploying a webapp using a terraform to create a CICD pipeline on GCP

1. Write Terraform code to set up your cloud infrastructure (GKE cluster, Jenkins server, etc.) on GCP.

2. Push your app code (with a Dockerfile) to GitHub (or other version control).

3. Jenkins watches for changes in the code (like when you push to GitHub).

4. When changes are detected, Jenkins:

5. Pulls the latest code

6. Builds a Docker image

7. Pushes it to DockerHub

8. Deploys (or updates) the app in Kubernetes (GKE)
   
```
GitHub (code pushed)
      ↓
   Jenkins (CI/CD)
      ↓
Docker Image built & pushed to DockerHub
      ↓
Kubernetes (GKE) pulls new image & deploys
      ↓
  App running on GCP
```

## Install GCP CLI

Run this command in windows powershell and the gcp downloader will pop up. 

```
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")

& $env:Temp\GoogleCloudSDKInstaller.exe
```

In terminal, set up gcloud cli by running `gcloud init` and configuring settings. 

### Setting up

Create a new project in gcp console: `Project-CICD`. This will go in terraform script. 

## Project steps

1. Provision infrastructure using terraform
    - Vm instance for jenkins - prebuilt image for jenkins or use script in terraform to install jenkins on vm.
    - kubernetes cluster on gcp?
2. Install jenkins on the vm
3. Connect jenkins with github, dockerhub, kubernetes.
    - Credentials- github, dockerhub
    - configure jenkins pipeline with the different jobs- clone repo, build docker image, push to dockerhub, deploy to kubernetes.
4. Write a jenkinsfile- save in github. 
5. Deploy app to kubernetes (need deployment and service files).
    - Jenkins will update image on each build but have to deploy manually first time. 


## Using Terraform to provision Jenkins

- Create Terraform scripts: 

1. `main.tf`

```
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "jenkins-network"
}

resource "google_compute_firewall" "jenkins-firewall" {
  name    = "allow-jenkins"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080", "50000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "jenkins-vm" {
  name         = "jenkins-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20230801"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      # Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    docker run -d -p 8080:8080 -p 50000:50000 --name jenkins jenkins/jenkins:lts
  EOF
}

```

2. `variables.tf`

```

variable "project_id" {
  description = "Project-CICD"
}

variable "region" {
  default     = "us-central1"
  description = "GCP region"
}

variable "zone" {
  default     = "us-central1-a"
  description = "GCP zone"
}

```

3. `outputs.tf`

```
output "jenkins_url" {
  value = "http://${google_compute_instance.jenkins-vm.network_interface[0].access_config[0].nat_ip}:8080"
}

```

### Executing terraform: vscode terminal

First:

- `gcloud auth application-default login` - might get error saying running scripts is disabled. 
  - `Get-ExecutionPolicy` - shows as restricted. 
  - `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`
  - `Get-ExecutionPolicy` - should be remoteSigned now. 

1. Run `gcloud auth application-default login` again and login to the gcloud console popup and give it access to everything (check box). Should be a successful login. 

2. In the vscode terminal:
   - switch to the project folder: `cd "Project 9 - CICD + GCP"`
   - Run `terraform init`
   - Run `terraform plan`
   - Run `terraform apply`
   -  Permission errors so- enable google api to allow gcp to create a vm.     
  `gcloud services enable compute.googleapis.com --project=project-cicd-468413`

3. Make sure the image exists- go onto gcp console and check images and copy and paste name of the one you want into terraform configuration. 
4. `terraform apply --auto-approve`


## SSh into the jenkins vm:

- Create ssh key: `ssh-keygen -t rsa -b 4096 -C "zainabfarooq001@gmail.com"`
- ssh into vm: `ssh -i "C:\Users\zaina\.ssh\id_rsa" zainabfarooq001@35.188.53.48`
- `ps -ef | grep jenkins` - no jenkins running.  

## Install jenkins + Java

- Install jenkins:

```
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

```

- Install Java:

```
sudo apt update
sudo apt install fontconfig openjdk-21-jre
java -version
openjdk version "21.0.3" 2024-04-16
OpenJDK Runtime Environment (build 21.0.3+11-Debian-2)
OpenJDK 64-Bit Server VM (build 21.0.3+11-Debian-2, mixed mode, sharing)

```
- Enable jenkins:
`sudo systemctl enable jenkins`

- Start jenkins:
`sudo systemctl start jenkins`

- Check status of jenkins:
`sudo systemctl status jenkins`

![alt text](<Images/Screenshot 2025-08-12 113741.png>)

Now at browser: enter url for jenkins vm : `http://35.188.53.48:8080/`

- To find password: 
`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
- Install suggested plugins
- save and finish.

### Install Docker on Jenkins

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```
```
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

```
- `sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
- Test - `sudo docker run hello-world` - should show it pulling the image from dockerhub. 

####### JENKINS INSTALLATION COMPLETE #######

## Configuring the app to run (TESTING IF WORKS LOCALLY FIRST)

### Cloning app into my repo

`git clone https://github.com/kyle8998/Vynchronize.git`

- Make sure the Dockerfile is inside the app folder (where the code is).
- Create Dockerfile

Dockerize the application:

```
# Use official Node.js LTS image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy rest of the app source code
COPY . .

# Expose port 3000
EXPOSE 3000

# Use environment variables from Kubernetes ConfigMap/Secret for API keys
CMD ["node", "server"]
```

- Build docker image from the app (TEST LOCALLY):

`docker build -t myapp .`
`docker run -p 3000:3000 myapp`
- Access application locally on  `http://localhost:3000/`
- As the application is deployed locally right now, no one else can access it. 


## Deploy app onto kubernetes and integrate with jenkins so it's accessible over internet

Create another VM in GCP for kubernetes:

################################## current- 

## WORKED LOCALLY- NOW MOVE ON TO CICD AND KUBERNETES AND JENKINS


- Run script (`terraform apply --auto-approve`)
- Make sure terraform main.tf file is in LF format (in vscode check bottom right corner).
- Ssh into the jenkins vm: `ssh -i "C:\Users\zaina\.ssh\id_rsa" zainabfarooq001@35.192.172.243`
- When connecting to vm again after destroying and recreating through terraform, ssh key may not be accepted- `ssh-keygen -R 35.192.172.243` (From bash shell not vm).
  - this removes old key and then retry connecting to the vm again- should work!

`sudo grep startup-script /var/log/syslog` - check vms for logs of script running
- Password for jenkins: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

## For kubernetes vm setup:

1. Run docker desktop and make sure kubernetes is enabled. 
2. Install minikube- 
```
sudo -v
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
minikube start --cpus=2 --memory=3g --addons=ingress
alias kubectl="minikube kubectl --"
kubectl version --short

```
- `minikube version` - should show minikube version, meanining it's installed. 
2. Docker should also be installed - (already installed through tf script).
- `sudo systemctl status docker` - should show docker installed and active. 
3. `minikube start --driver=docker` - start minikybe using docker desktop. 
4. Install kubernetes:
   - Install kubectl binary: `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" `
   - Make the kubectl binary executable: `chmod+x kubectl`
   - Move the binary to PATH: `sudo mv kubectl /usr/local/bin`
  
## Docker Image:

- `docker tag myapp:latest zainab7861/myapp:latest`
- `docker login`
- `docker push zainab7861/myapp:latest`
- Should show the app in dockerhub online now. 

5. Create the necessary files:
 - `nano app.yaml`
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: zainab7861/myapp:latest
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  type: NodePort
  selector:
    app: app
  ports:
  - protocol: TCP
    port: 3000
    targetPort: 3000
    nodePort: 30001

```

- So the names/ports are different layers:
  - containerPort → container itself
  - targetPort → what the Service forwards to inside the container
  - port → internal cluster port for other pods
  - nodePort → external access port on the node



## All in kubernetes vm :


1. `minikube start`
2. Install nginx: 
   - `sudo apt install nginx`.
- Check the file is configured well `sudo nginx -t`.
- Edit the file for reverse proxy `sudo nano /etc/nginx/sites-available/default`
- `192.168.49.2:30001` as the proxy pass. 
1. Error- even though pods are running, theyre unreachable - 
   - Troublshooting = 
   - `kubectl get pods -l app=app` - shows pods
   - `kubectl exec -it app-78cbcbcdfd-vvvv7 -- sh` - ssh into one of the pods.
   - `netstat -tulpn` - shows what port the app is listening on. Check if its the same as the port your yaml file has. 
   - E.g. if it says port 3000, your yaml file should have port 3000 too. 


- Apply the yaml file: `kubectl apply -f app.yaml` - should see the deployment and service file created. 
- Test the deployment: `curl <minikube ip>:30001` - doesnt work. 

**Troubleshooting:**
- `kubectl get deployments`
- `minikube status`
- `kubectl get pods -o wide`


App should be accessible on : `http://VM-IP/`
In local bash terminal (in udemy folder)- not vm - 


## Minikube NodePort vs VM IP - INFO

- NodePort exposes a Kubernetes service on a port (e.g., 30001) on the node.
- When you run minikube start, Minikube creates a VM (or container) with its own internal IP (like 192.168.49.2).
- Inside the Minikube VM, NodePort works. But external IP access requires additional routing.



THINGS TO DO LEFT:


1. Try to make it so that the kubernetes pipeline is configured with the yaml files every time i do terraform destroy and apply again. 
2. Configure jenkins pipeline
3. Add credentials of github to jenkins, add credentials of vm to jenkins, add credentials of dockerhub to jenkins.
4. 3 jobs on pipeline- merge, create docker i,mage from the updated version of app, test, push changes to working app in kubernetes (use the updated image). 

  
## Checking log files after running terraform script (to see why it works or didnt work)

- In the terraform main.tf file - in the startup script - add this in to get logs in this file of all the steps of script happening:
```
LOGFILE=/var/log/k8s-startup.log
exec > >(tee -a $LOGFILE) 2>&1
```
- Once tf script ran, run this in vm: `cat /var/log/k8s-startup.log ` - shows all steps of script and what worked and where the config failed. 

- `ssh-keygen -R 35.192.172.243` if ssh key fails. 


## THE TERRAFORM START-UP SCRIPT AND WHAT IT DOES: Kubernetes vm 

1. Creates marker file. 
2. Log file creation
3. Installs docker and other dependencies (updates and upgrades).
4. Adds user to docker group. 
5. Installs kubernetes and minikube. 
6. Creates the yaml file for minikube and stores in the vm. 
7. Installs nginx and configures reverse proxy.



- This part starts the script and adds a marker file - GCP by default runs the startup script everytime the vm is started.  This stops vm from recreating the script on startup if its already been created once before. 
```
  metadata_startup_script = <<-EOF 
#!/bin/bash
MARKER_FILE="/var/lib/startup-script-ran"

# Check if the marker file exists
if [ -f "$MARKER_FILE" ]; then
  echo "Startup script already ran, skipping..."
  exit 0
fi
```

- set -e means script stops if any one step fails. Then the logs are all put into a log file on creation. Can access log files to see exactly which step the fail was on. 
```
set -e
export DEBIAN_FRONTEND=noninteractive

# --- Redirect all output to log ---
LOGFILE=/var/log/k8s-startup.log
exec > >(tee -a $LOGFILE) 2>&1
```
- Installing dependencies and docker
```
echo "===== Kubernetes VM setup started at $(date) ====="

echo "--- Updating system packages ---"
apt-get update -y
apt-get upgrade -y
echo "--- System packages updated ---"

echo "--- Installing dependencies (docker, curl, kubectl prerequisites) ---"
apt-get install -y docker.io apt-transport-https ca-certificates curl gnupg lsb-release conntrack
echo "--- Dependencies installed ---"

echo "--- Enabling and starting Docker ---"
systemctl enable docker
systemctl start docker
echo "--- Docker status ---"
systemctl status docker
```

- Adds the user to docker group to prevent further permission errors. After this, ubuntu user can run docker commands without using sudo. 
```
echo "--- Adding ubuntu user to Docker group ---"
usermod -aG docker ubuntu
echo "--- User added to Docker group ---"
```

- Installs kubernetes and minikube. 
```
echo "--- Installing kubectl ---"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
kubectl version --client
echo "--- kubectl installed ---"

echo "--- Installing Minikube ---"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
echo "--- Minikube installed ---"
```

- default directory where kubernetes stores config files 
- stores home directory path for user ubuntu
- creates the .kube directory in ubuntus home.
- Changes ownership of .kube to the ubuntu user.
- sets permissions so that only the owner (ubuntu) can read, write or execute inside .kube.

```
KUBE_DIR=/home/ubuntu/.kube
USER_HOME=/home/ubuntu
mkdir -p $USER_HOME/.kube
chown -R ubuntu:ubuntu $USER_HOME/.kube
chmod 700 $USER_HOME/.kube
```

- This is the yaml file i want to be created everytime i start up this script in my vm through terraform apply. 
```
cat <<YAML > $USER_HOME/app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: zainab7861/myapp:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  type: NodePort
  selector:
    app: app
  ports:
  - protocol: TCP
    port: 3000
    targetPort: 3000
    nodePort: 30001
YAML

chown ubuntu:ubuntu $USER_HOME/app.yaml
```

- This installs nginx and automatically configures the reverse proxy for me. 
```
echo "--------------Installing Nginx--------------"
DEBIAN_FRONTEND=noninteractive apt install -yq nginx
 
echo "--------------Configuring Nginx reverse proxy --------------"
sed -i 's|try_files $uri $uri/ =404;|proxy_pass http://192.168.49.2:30001;|' /etc/nginx/sites-available/default
 
echo "--------------Checking Nginx config--------------"
nginx -t
 
echo "--------------Restarting Nginx--------------"
systemctl enable nginx
systemctl restart nginx
```

- Starts minikube with docker driver. 
```
echo "starting minikube"
sudo -u ubuntu -i minikube start --driver=docker

echo "minikube COMPLETE--------------------------------"
```

- The end part of the marker file. 
```
# Mark as completed
touch "$MARKER_FILE"
echo "Startup script completed and marker file created."
 

EOF
}
```

**When entering vm after terraform apply:**
- Need to do `minikube start` and `kubectl apply -f app.yaml`. App should be running after these 2 commands with the terraform startup script. 


# Jenkins pipeline

- SSH into jenkins vm to get password- `ssh -i "C:\Users\zaina\.ssh\id_rsa" zainabfarooq001@34.29.22.3`
- ` sudo cat /var/lib/jenkins/secrets/initialAdminPassword `
- Set it up. 


## In Jenkins vm:

1. Install docker
```
sudo apt update
sudo apt install -y docker.io
systemctl status docker

sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

```
2. Install Git:
```

# Update package lists and upgrade installed packages
sudo apt update -y
sudo apt upgrade -y

# Install git
sudo apt install -y git

# Check git version
git --version

```
3. Create DockerFile in jenkins vm:
- `nano DockerFile`

```
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]

```

4. Manage jenkins - system - change jenkins url value to something random - faster loading speed of jenkins.

5. Add the app.yml script from minikube vm to your github so jenkins can pull it from there.
- just create a new yml file and paste contents into it. 

## In Github (local):
When pushing repo with terraform - maybe be error due to large files - create .gitignore + do these commands:
```
git filter-repo --path "Project 9 - CICD + GCP/.terraform/pr... 
  53 git filter-repo --path "Project 9 - CICD + GCP/.terraform/pr... 
```
- Make sure app is also in local repo - push it to remote repo too. 

## In jenkins online:
- Create new job - pipeline job.
- Add following plugins from settings:
  - Install `docker pipeline` plugin. 
  - Install `kubernetes CLI` plugin. 
  - Install `github integration` plugin. 
  - Install `SSH Agent` plugin.
  - Restart jenkins after these are installed. 

## Credentials
1. Dockerhub credentials into jenkins
  - In dockerhub, create PAT to use for jenkins-
  - account settings - Personal access tockens - generate new token. 
  - Use the token and add it into jenkins credentials along with the docker username. 
  - Username with password option. 
2. Github credentials into jenkins
  - Create new ssh key (.pub and private key).
  - Im using premade keys - `aws-key` and `aws-key.pub`
  - public key on github
  - private key on jenkins (add creds - ssh username with private key).
3. Kubernetes VM into jenkins
  - Copy minikube vm private ssh key to jenkins vm so jenkins can access it
  - Use the private key of the vm (the private key you use to access the kubernetes vm)
  - `scp -i /c/Users/zaina/.ssh/id_rsa /c/Users/zaina/.ssh/id_rsa zainabfarooq001@34.29.22.3:~`
  - Create folder for jenkins user - `sudo mkdir -p /var/lib/jenkins/.ssh `
  - Copy key from home folder to jenkins .ssh folder
  - `sudo cp /home/zainabfarooq001/id_rsa /home/lib/jenkins/.ssh/`
  - Change permissions - `chmod 600 ~/id_rsa`
  - `sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa`

## Add webhook
Github- your app repo
- settings - webhooks
- Add webhook:
  - Payload Url: 
    - The jenkins server ip goes in this.
    - `http://34.29.22.3:8080/github-webhook/`
    - Disable SSL verification
    - Save.

## Jenkins with kubernetes

Minikube automatically creates a kubeconfig file under the current user (usually your own, like ubuntu or ec2-user). But Jenkins usually runs as a different user (like jenkins), and it won’t have access to your kubeconfig by default.

Copy the kubeconfig to the jenkins user (on kubernetes vm).
  - `sudo -i` - switch to root user if needed.
  - `sudo mkdir -p /var/lib/jenkins/.kube` - create kube directory for Jenkins.
  - `sudo cp /home/ubuntu/.kube/config /var/lib/jenkins/.kube/config` - copy config file from your current user to jenkins. 

- Jenkins file: ``


```
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'zainab7861/myapp'
        TARGET_VM = '34.60.2.172'
    }

    stages {
        stage('Checkout dev') {
            steps {
                git branch: 'dev',
                    url: 'https://github.com/zainabx78/tech501-udemy.git',
                    credentialsId: 'aws-key'
            }
        }

        stage('Merge dev into main') {
            steps {
                sshagent(['aws-key']) {
                    sh '''
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins"
                        git checkout main
                        git pull origin main --rebase
                        git merge dev --no-ff -m "merged dev to main with jenkins"
                        git remote set-url origin git@github.com:zainabx78/tech501-udemy.git
                        git push origin main
                    '''
                }
            }
        }

        stage('Build Docker image') {
            steps {
                script {
                    env.IMAGE_TAG = "${DOCKER_IMAGE}:${BUILD_NUMBER}"
                    dockerImage = docker.build(env.IMAGE_TAG, 'app')
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub password', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    script {
                        docker.withRegistry('https://index.docker.io/v1/', 'dockerhub password') {
                            dockerImage.push()
                        }
                    }
                }
            }
        }

        stage('Deploy to Minikube.') {
            steps {
                script {
                    def dockerImage = env.IMAGE_TAG

                    // Copy the K8s manifest file to the remote server
                    sh "scp -i /var/lib/jenkins/.ssh/id_rsa Project\\ 9\\ -\\ CICD\\ +\\ GCP/app.yaml ubuntu@${TARGET_VM}:/home/ubuntu/"

                    // SSH into the remote server and apply the manifest & update the deployment image
                sh """#!/bin/bash
ssh -i /var/lib/jenkins/.ssh/id_rsa ubuntu@${TARGET_VM} <<EOF
kubectl apply -f /tmp/app.yaml
kubectl set image deployment/app app=${dockerImage} --record
EOF
"""

                }
            }
        }
    }
}
```

## Running pipeline

- Make change in dev branch - 
- `git checkout -b dev`
- `git push origin dev`

When pipeline runs:

- Hostkey verification fails- Try this `sudo ssh-keyscan github.com | sudo tee -a /var/lib/jenkins/.ssh/known_hosts`


**Running pipeline:**
-  `cd "Project 9 - CICD + GCP"`
- `cd app`, `cd vynchronize`, `notepad .\index.html` - to edit the index file. 
- This push will trigger jenkins pipeline.