# Terraform AWS – First Infrastructure Project 🚀

## 📌 Overview

This repository contains my **first Terraform project using AWS**, created as a **hands-on learning experience** in **Infrastructure as Code (IaC)**.

The project is designed to evolve progressively while applying **DevOps, Cloud, and Git best practices**.

---

## 🎯 Objectives

- Learn and practice **Terraform (IaC)**
- Deploy infrastructure on **Amazon Web Services (AWS)**
- Apply **DevOps best practices**
- Maintain a **clean and secure Git workflow**
- Build a **portfolio-ready cloud project**

---

## 🛠️ Technologies & Tools

- **Terraform** `>= 1.2`
- **AWS Provider** `~> 5.92`
- **Amazon Web Services (AWS)`
- **PowerShell**
- **Git & GitHub**

---

## 🧱 Current Infrastructure (v1)

### ✅ EC2 Instance (Terraform – HCL)

hcl
resource "aws_instance" "monserveur" {
  ami           = "ami-085f043560da76e08"
  instance_type = "t3.micro"

  tags = {
    Name = "serveurInstance"
  }
}
✅ Virtual Private Cloud (Terraform – HCL)
hcl
Copier le code
resource "aws_vpc" "vpc_toronto_test" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "vpc_toronto_test"
  }
}
📂 Project Structure
bash
Copier le code
.
├── main.tf
├── .terraform.lock.hcl
├── .gitignore
└── README.md
🚀 Getting Started
1️⃣ AWS Configuration (PowerShell)
powershell
Copier le code
aws configure
2️⃣ Terraform Initialization (PowerShell)
powershell
Copier le code
terraform init
3️⃣ Terraform Plan (PowerShell)
powershell
Copier le code
terraform plan
4️⃣ Terraform Apply (PowerShell)
powershell
Copier le code
terraform apply
5️⃣ Destroy Infrastructure (PowerShell)
powershell
Copier le code
terraform destroy
🔐 Security & Git Best Practices
Terraform State Handling
text
Copier le code
terraform.tfstate  → NEVER committed
.terraform/        → NEVER committed
.gitignore (Git)
gitignore
Copier le code
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
.crash.log
*.exe

# OS
.DS_Store
Thumbs.db
🔄 Planned Improvements
variables.tf

outputs.tf

Security Groups

Subnets (public/private)

Remote backend (S3 + DynamoDB)

Terraform modules

CI/CD integration

📚 Skills Demonstrated
Infrastructure as Code (Terraform)

AWS resource provisioning

Version control with Git

Secure state management

DevOps workflow fundamentals

👤 Author
Ismail Trache
Computer Systems Technology Student
Cloud & DevOps Enthusiast

🔗 LinkedIn
https://www.linkedin.com/in/ismail-trache-3865b7218/

