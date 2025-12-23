 Objectives

- Learn and practice **Terraform (IaC)**
- Deploy infrastructure on **Amazon Web  Current Infrastructure (v1)

### ✅ EC2 Instance (Terraform – HCL)

```hcl
 LinkedIn
https://www.linkedin.com/in/ismail-trache-3865b7218/

resource "aws_instance" "monserveur" {
  ami           = " Planned Improvements
variables.tf

outputs.tf

Security Groups

Subnets (public/private)

Remote backend (S3 + DynamoDB)

Terraform modules

CIami-085f043560da76e08"
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
�� Project Structure
bash
Copier le code
.
├── main.tf
├── .terraform.lock.hcl
├── .gitignore
└── REA Getting Started
1️⃣ AWS Configuration (PServices (AWS)**
- Apply **DevOps best practices**
- Maintain a **clean and secure Git workflow**
- Build ️ Technologies & Ta **portfolio-r
