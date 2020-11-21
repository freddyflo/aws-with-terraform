provider aws {
    region =  "eu-west-3"
}


# create IAM user
resource "aws_iam_user" "freddyflo-user" {
  name = "freddyflo"
  path = "/"

  tags = {
    tag-key = "terraform"
    "group" = "data.aws_iam_group.admin-group.group_name" 
  }
}


resource "aws_iam_access_key" "freddyflo-access-key" {
  user = aws_iam_user.freddyflo-user.name
}

resource "aws_iam_user_policy" "freddyflo_policy" {
  name = "freddyflo_policy"
  user = aws_iam_user.freddyflo-user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# aws login profile   
resource "aws_iam_user_login_profile" "freddyflo-profile" {
  user    =  aws_iam_user.freddyflo-user.name
  pgp_key = "keybase:freddyflo"
}



# fetch existing group admin
data "aws_iam_group" "admin-group" {
  group_name = "admin"
}

# add user to group admin
resource "aws_iam_user_group_membership" "membership-admin" {
  user = aws_iam_user.freddyflo-user.name

  groups = [
    data.aws_iam_group.admin-group.group_name
  ]
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# default vpc
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}


# security group
resource "aws_security_group" "ssh_web" {
  name = "ssh_web"
  description = "Allow standard http and http ports inbound and everything outbound"
  

  # inbound traffic
  ingress  {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  } 
  ingress  {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress  {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }  

  # outbound traffic
  egress   {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  } 

  tags = {
    "Terraform": "true"
  }
  
}



# generate key pair
resource "tls_private_key" "test_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "fred-key"
  #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDB6yRGs2Y0Jn2Po8gG6gR8NgeEDq6fBgWchUZRcEgdhqEgm7FOSfVJto2egzk/yPQchp20WMMx8SOleU0EOCG/xT772EXY+abBfbFnLOByAkKK0eQYKrdWn9ZObefcMKVEOyifpaEhaKI6yuXYGispKI14OPQrhP+UV0Bo4yoZ5xkTlFg12rY7E+KkkJS54xLKouGmSncSTQ1AIIrAOOfy6pWKDZJbS9qdPfSljwNL7+XRkvq1Bm7YCu2hsfGw35QN1RPqbTtbho+u01v9uJFV2nMCCRxv/C2GZx1Z+HKp8gu7YfdTD8YcjToLemQEUnDjv3yQeN8o55/hE7HRok/9 fred@fred-ThinkPad-P43s"
  public_key = tls_private_key.test_key.public_key_openssh
}

resource "aws_instance" "web" {
  ami              = data.aws_ami.ubuntu.id
  instance_type    = "t3.micro"

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ssh_web.id]
  key_name                    = aws_key_pair.generated_key.key_name
  user_data                   = <<-EOF
                                #!/bin/bash
                                apt-get update -y
                                apt install apache2 -y
                                echo "Welcome to My First EC2 Instance Web Server" > /var/www/html/index.html
                                service http start
                                EOF
 
  tags = {
    Name = "TestSSH"
  }
}


# generated with keybase
output "password" {
  value = aws_iam_user_login_profile.freddyflo-profile.encrypted_password
}

# get private ssh key
output "private_ssh_key" {
  value = tls_private_key.test_key.private_key_pem

}

output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.web.public_ip
}

# subnet - availability zone


