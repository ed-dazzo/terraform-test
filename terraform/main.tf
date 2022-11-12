terraform {
  required_providers {
    aws = "~> 4.38.0"
  }
}

provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  name   = "hello-world"

  user_data = <<-EOT
    #!/bin/bash
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.name}
    ECS_LOGLEVEL=debug
    EOF
  EOT

  tags = {
    Name = local.name
  }
}
