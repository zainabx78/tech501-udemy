# Provider - Google Cloud
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Network 
resource "google_compute_network" "vpc_network" {
  name = "jenkins-network"
}

# Firewall
resource "google_compute_firewall" "jenkins-firewall" {
  name    = "allow-jenkins"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080", "50000", "80", "443", "22"] # Jenkins + HTTP + HTTPS + SSH
  }

  source_ranges = ["0.0.0.0/0"]

  direction = "INGRESS"
  priority  = 1000
  # Optional: Add tags for targeting
  # target_tags = ["jenkins-server"]
}



# Jenkins VM  
resource "google_compute_instance" "jenkins-vm" {
  name         = "jenkins-instance"
  machine_type = "e2-small" # cheaper but still good
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20250805"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {} # Ephemeral public IP
  }


  metadata = {
    ssh-keys = "zainabfarooq001:${file("C:/Users/zaina/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = <<-EOF
  #!/bin/bash
  set -e
  export DEBIAN_FRONTEND=noninteractive

  apt-get update -y
  apt-get install -y openjdk-17-jre fontconfig wget gnupg apt-transport-https

  mkdir -p /etc/apt/keyrings
  wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    | sudo tee /etc/apt/sources.list.d/jenkins.list

  apt-get update -y
  apt-get install -y jenkins

  systemctl enable jenkins
  systemctl start jenkins
EOF

}


# Kubernetes App Deployment VM
resource "google_compute_instance" "k8s-vm" {
  name         = "k8s-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20250805"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${file("C:/Users/zaina/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = <<-EOF
#!/bin/bash
MARKER_FILE="/var/lib/startup-script-ran"

# Check if the marker file exists
if [ -f "$MARKER_FILE" ]; then
  echo "Startup script already ran, skipping..."
  exit 0
fi

set -e
export DEBIAN_FRONTEND=noninteractive

# --- Redirect all output to log ---
LOGFILE=/var/log/k8s-startup.log
exec > >(tee -a $LOGFILE) 2>&1

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

echo "--- Adding ubuntu user to Docker group ---"
usermod -aG docker ubuntu
echo "--- User added to Docker group ---"

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

KUBE_DIR=/home/ubuntu/.kube
USER_HOME=/home/ubuntu
mkdir -p $USER_HOME/.kube
chown -R ubuntu:ubuntu $USER_HOME/.kube
chmod 700 $USER_HOME/.kube

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

echo "--------------Installing Nginx--------------"
DEBIAN_FRONTEND=noninteractive apt install -yq nginx
 
echo "--------------Configuring Nginx reverse proxy --------------"
sed -i 's|try_files $uri $uri/ =404;|proxy_pass http://192.168.49.2:30001;|' /etc/nginx/sites-available/default
 
echo "--------------Checking Nginx config--------------"
nginx -t
 
echo "--------------Restarting Nginx--------------"
systemctl enable nginx
systemctl restart nginx

echo "starting minikube"
sudo -u ubuntu -i minikube start --driver=docker

echo "minikube COMPLETE--------------------------------"


#doesnt work
#echo "starting to apply yaml file----------------------"
#until kubectl get nodes > /dev/null 2>&1; do
  #echo "Waiting for Kubernetes API..."
  #sleep 5
#done
#kubectl apply -f /home/ubuntu/app.yaml


# Mark as completed
touch "$MARKER_FILE"
echo "Startup script completed and marker file created."
 

EOF
}



