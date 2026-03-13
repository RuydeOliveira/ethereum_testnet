module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "blockchain-staking"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.128.0/24"]
  public_subnets  = ["10.0.1.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}
