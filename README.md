This project demonstrates a small end-to-end infrastructure setup using Terraform — including provisioning of EC2, S3, IAM Role, IAM Policy, and Instance Profile

Overview:
This project provisions the following AWS resources using Terraform:
▪️ An S3 bucket for backups
▪️ An IAM Role with a custom policy allowing read-only access to the bucket
▪️ An IAM Instance Profile for EC2
▪️ A Security Group for the EC2 instance with defined ingress rules
▪️ An EC2 instance with the IAM profile attached, giving it access to the bucket

How to Run this project:
1. Configure AWS CLI:
   aws configure
   
2. Initalize Terraform
   terraform init
   
3. Review Plan
   terraform plan

4. Apply Changes
   terraform apply
