# Terraform AWS Webserver Project

## Description
This project provisions a basic AWS infrastructure using Terraform, including networking components and an EC2 instance. The EC2 instance runs Apache to serve a simple web page for demonstration.

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/a7e8b065-fc2c-42e2-8045-cd35c67e4250" />


## Resources Created
1. **VPC** – Custom virtual private cloud (`10.0.0.0/16`)  
2. **Internet Gateway** – For outbound/inbound internet access  
3. **Route Table** – With routes to the internet  
4. **Subnet** – Public subnet (`10.0.1.0/24`)  
5. **Route Table Association** – Associates subnet with the route table  
6. **Security Group** – Allows SSH (22), HTTP (80), and HTTPS (443)  
7. **Network Interface (ENI)** – Attached to the subnet with a private IP  
8. **Elastic IP** – Public IP for the instance  
9. **EC2 Instance** – Ubuntu/AMI with Apache installed and configured  
10. **Elastic IP Association** – Binds the Elastic IP to the EC2 instance  

## How to Use
1. Clone this repository.  
2. Update the file with your own values (e.g., `key_pair_name`).  
3. Initialize Terraform:  
   ```bash
   terraform init
   terraform plan
   terraform apply
