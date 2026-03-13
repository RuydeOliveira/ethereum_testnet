resource "aws_route53_zone" "internal_zone" {
  name = "staking.internal"

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  force_destroy = true
}
