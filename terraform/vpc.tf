#
# Network configuration
#
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.0.0.0/16"

  # Containers are currently set up to use 1 container per node, give each private subnet 4096 addresses
  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = false

  tags = local.tags
}
