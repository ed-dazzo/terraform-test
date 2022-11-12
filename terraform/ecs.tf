# Infrastructure and cluster settings for ECS

#
# Container Orchestration
#
module "ecs" {
  source       = "terraform-aws-modules/ecs/aws"
  version      = "~> 4.1.2"
  cluster_name = local.name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }
  }

  # Fargate is not available free tier eligible, disable for now
  default_capacity_provider_use_fargate = false

  autoscaling_capacity_providers = {
    asg = {
      auto_scaling_group_arn         = module.autoscaling.autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      # Increase the scaling steps to better deal with surges. Out of scope for
      # now, since costs are a concern
      managed_scaling = {
        maximum_scaling_step_size = 2
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 40
      }

      # These settings will be relevant if we use more than one capacity provider
      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }

  tags = local.tags
}

#
# EC2 infrastructure, required for ECS
#

# The ASG AMI
# Note: the ami is built by packer. In order to ensure we don't accidentally change
# the deployed ami image, we need to tag the desired ami with the "env" key equal to
# prod. This can eventually be automated.
data "aws_ami" "main" {
  owners = ["self"]
  filter {
    name   = "name"
    values = ["${local.name}*"]
  }
  filter {
    name   = "tag:env"
    values = ["prod"]
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  name = "${local.name}-asg"

  image_id      = data.aws_ami.main.id
  instance_type = "t3.micro"

  security_groups                 = [module.autoscaling_sg.security_group_id]
  user_data                       = base64encode(local.user_data)
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = local.name
  iam_role_description        = "ECS role for ${local.name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CloudWatchAgentAdminPolicy          = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
    CloudWatchAgentServerPolicy         = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "EC2"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  tags = local.tags
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Autoscaling group security group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp"]

  egress_rules = ["all-all"]

  tags = local.tags
}


resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.name}"
  retention_in_days = 7

  tags = local.tags
}
