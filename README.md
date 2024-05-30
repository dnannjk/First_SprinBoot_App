
None selected 

Skip to content
Using Gmail with screen readers
155 of 19,688
GitHub Actions Setup and Kubernetes Deployment
Inbox

Pradeep Kolpkar
Attachments
20 May 2024, 05:38 (10 days ago)
to me

Hi,


Attached to this email, you will find the following files:

maven.yml: This GitHub Actions workflow file automates the Maven build process for our project.
k8s.yaml: This Kubernetes Deployment manifest defines the deployment configuration for our application.
service.yaml: This Kubernetes Service manifest defines the service configuration for our application.
runner_infra.sh: This shell script automates the setup of necessary infrastructure components, such as Maven, Docker, AWS CLI, Kubernetes tools, and EKS cluster creation.
argocd-app.yaml: This YAML file defines the application configuration for Argo CD, facilitating continuous delivery and deployment.

Thank You,
Pradeep
 6 attachments
  • Scanned by Gmail
Thanks a lot for sharing.Thanks, I'll check them out.Thanks for the mail.
Pradeep Ko
#!/bin/bash

# Install Maven
sudo apt-get update
sudo apt-get install -y maven
mvn -version

# Install Docker
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker

# Install AWS CLI
sudo apt-get update
sudo apt-get install -y unzip  # Install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# Add GitHub Actions runner user to the docker group
sudo usermod -aG docker $USER

# Install kubectl
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

# Install Argo CD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd-linux-amd64
sudo mv argocd-linux-amd64 /usr/local/bin/argocd
argocd version --client

# Install eksctl
sudo apt-get update
sudo apt-get install -y curl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | sudo tar xz -C /usr/local/bin

# Set up AWS credentials
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region us-east-1

# Create Amazon EKS cluster
eksctl create cluster --name springboot-github-workflow-cluster --version 1.28 --nodes=1 --node-type=t2.small --region us-east-1

# Wait for EKS Cluster
sleep 300  # Wait for 5 minutes for the cluster to be ready

# Configure kubectl
aws eks update-kubeconfig --name springboot-github-workflow-cluster --region us-east-1
runner_infra.sh
Displaying k8s.yaml.

##################### Pre-requisite ##########################################################################################
## AWS CLI

## Chocolatey links (installer - for argocd cli deployment)
https://chocolatey.org/install

## Pre-requisite links
https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html

## kubectl

## argocd-cli
##############################################################################################################################
##################### Create AWS EKS clsuster ################################################################################
## Create EKS cluster
eksctl create cluster --name eksargocd --node-type t2.large --nodes 1 --nodes-min 1 --nodes-max 2 --region us-east-1 --zones=us-east-1a,us-east-1b,us-east-1c

## Get EKS Cluster service
eksctl get cluster --name eksargocd --region us-east-1

## Update Kubeconfig 
aws eks update-kubeconfig --name eksargocd

## Get EKS Pod data.
kubectl get pods --all-namespaces

## Delete EKS cluster
eksctl delete cluster --name eksargocd --region us-east-1

##################################################CREATE AWS EKS CD with ArgoCD #######################################################
## Installing Argo CD on Your Cluster
1.Check if kubectl is working as expected
  kubectl get nodes
  
2.Create namespace
  kubectl create namespace argocd
  
3.Run the Argo CD install script provided by the project maintainers.
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  
4. Check the status of your Kubernetes pods
  kubectl get pods -n argocd

## Forwarding Ports to Access Argo CD
5.1.Retrieve the admin password which was automatically generated during your installation and decode from base64 from online.
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"

5.2 forward those to arbitrarily chosen other ports, like 8080, like so:
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  
5.3 Access from ineternet from browser.
  http://localhost:8080 
  user id : admin
  password :base64 decoded password.
  
## Working with Argo CD from the Command Line
6. Use chocolatey utility to install in Windows ( with admin access)
   choco install argocd-cli
   
## Deploying an Example Application from argocd using argocd cli
7. Deploying an Example Application
  argocd login localhost:8080
  user id : admin
  password :base64 decoded password.
  argocd app create helm-guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path helm-guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
  
7.1 Check status inside argocd
  argocd app get helm-guestbook

7.2 Actually deploy the application
  argocd app sync helm-guestbook

7.3 Port foward from onther session check the application status
  kubectl port-forward svc/helm-guestbook 9090:80
  http://localhost:9090

#############################################################################################################################################
