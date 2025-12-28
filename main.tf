provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.aws_az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_2
  availability_zone       = var.aws_az_2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Allow HTTP/HTTPS to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb-sg"
  }
}

resource "aws_security_group" "web" {
  name        = "${var.name}-sg"
  description = "Allow SSH and HTTP from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  ingress {
    description = "HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

resource "aws_s3_bucket" "uploads" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "uploads_public" {
  statement {
    sid     = "PublicReadUploadsOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.uploads.arn}/uploads/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "uploads_public" {
  bucket = aws_s3_bucket.uploads.id
  policy = data.aws_iam_policy_document.uploads_public.json

  depends_on = [aws_s3_bucket_public_access_block.uploads]
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_s3_access" {
  statement {
    sid     = "ListUploadsBackups"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.uploads.arn,
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "uploads/*",
        "backups/*",
        "${var.app_s3_prefix}*",
      ]
    }
  }

  statement {
    sid     = "WriteUploadsBackups"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
    ]
    resources = [
      "${aws_s3_bucket.uploads.arn}/uploads/*",
      "${aws_s3_bucket.uploads.arn}/backups/*",
    ]
  }

  statement {
    sid     = "ReadUploadsOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.uploads.arn}/uploads/*",
    ]
  }

  statement {
    sid     = "ReadAppBundle"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.uploads.arn}/${var.app_s3_prefix}*",
    ]
  }
}

resource "aws_iam_policy" "ec2_s3_access" {
  name   = "${var.name}-s3-access"
  policy = data.aws_iam_policy_document.ec2_s3_access.json
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_s3_access.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.name}-key"
  public_key = var.public_key
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.name}-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.web.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.root_volume_size
      volume_type = "gp3"
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -euo pipefail

              apt-get update -y
              apt-get install -y python3-venv python3-pip nginx awscli

              systemctl enable nginx

              mkdir -p /var/www/html
              chown -R ubuntu:ubuntu /var/www/html

              if aws s3 ls "s3://${var.s3_bucket_name}/${var.app_s3_prefix}" >/dev/null 2>&1; then
                aws s3 sync "s3://${var.s3_bucket_name}/${var.app_s3_prefix}" /var/www/html/
              fi

              cat >/etc/nginx/sites-available/flask_app <<'NGINX'
              server {
                listen 80;
                server_name ${var.domain_name} ${var.www_domain_name};

                location /health {
                  return 200 "ok";
                }

                location / {
                  proxy_pass http://127.0.0.1:8000;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                }
              }
              NGINX

              ln -sf /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled/flask_app
              rm -f /etc/nginx/sites-enabled/default
              nginx -t
              systemctl reload nginx

              cat >/usr/local/bin/flask_app_bootstrap.sh <<'BOOT'
              #!/bin/bash
              set -euo pipefail

              APP_DIR="/var/www/html"
              VENV_DIR="$APP_DIR/venv"

              if [[ ! -f "$APP_DIR/app.py" || ! -f "$APP_DIR/requirements.txt" ]]; then
                exit 0
              fi

              if [[ ! -d "$VENV_DIR" ]]; then
                python3 -m venv "$VENV_DIR"
              fi

              source "$VENV_DIR/bin/activate"
              pip install --upgrade pip
              pip install -r "$APP_DIR/requirements.txt" gunicorn
              deactivate

              systemctl restart flask_app
              BOOT

              chmod +x /usr/local/bin/flask_app_bootstrap.sh

              cat >/etc/systemd/system/flask_app.service <<'UNIT'
              [Unit]
              Description=Gunicorn for Flask app
              After=network.target
              ConditionPathExists=/var/www/html/app.py
              ConditionPathExists=/var/www/html/requirements.txt
              ConditionPathExists=/var/www/html/venv/bin/gunicorn

              [Service]
              User=ubuntu
              Group=www-data
              WorkingDirectory=/var/www/html
              Environment="PATH=/var/www/html/venv/bin"
              ExecStart=/var/www/html/venv/bin/gunicorn -w 2 -b 127.0.0.1:8000 ${var.flask_app_module}
              Restart=always
              RestartSec=5

              [Install]
              WantedBy=multi-user.target
              UNIT

              cat >/etc/systemd/system/flask_app_bootstrap.service <<'BOOTSRV'
              [Unit]
              Description=Bootstrap Flask app venv and deps

              [Service]
              Type=oneshot
              ExecStart=/usr/local/bin/flask_app_bootstrap.sh
              BOOTSRV

              cat >/etc/systemd/system/flask_app.path <<'PATHUNIT'
              [Unit]
              Description=Watch Flask app files

              [Path]
              PathExists=/var/www/html/app.py
              PathExists=/var/www/html/requirements.txt
              Unit=flask_app_bootstrap.service

              [Install]
              WantedBy=multi-user.target
              PATHUNIT

              systemctl daemon-reload
              /usr/local/bin/flask_app_bootstrap.sh
              systemctl enable --now flask_app.path
              systemctl enable --now flask_app.service
EOF)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name
    }
  }
}

resource "aws_lb" "web" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_b.id]
}

resource "aws_lb_target_group" "web" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.name}-asg"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.public.id, aws_subnet.public_b.id]
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
}
