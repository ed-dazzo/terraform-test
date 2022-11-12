packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazonlinux2" {
  ami_name      = "hello-world-ecs-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami    = "ami-0fe77b349d804e9e6"
  ssh_username  = "ec2-user"
  tags = {
    OS_Version   = "AmazonLinux2"
    creator      = var.aws_user
    git_branch   = var.git_branch
    git_revision = var.git_revision
  }
}

build {
  name = "hello-world-ecs"
  sources = [
    "source.amazon-ebs.amazonlinux2"
  ]
  provisioner "file" {
    destination = "/tmp/config.json"
    source      = "${path.root}/agent-config.json"
  }

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install amazon-cloudwatch-agent -y",
      "sudo mv /tmp/config.json /opt/aws/amazon-cloudwatch-agent/etc/config.json",
      "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json"
    ]
  }
}


