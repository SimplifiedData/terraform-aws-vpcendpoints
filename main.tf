provider "aws" {
  region = "ap-southeast-1"
}
locals {
  name        = "${var.tags["Service"]}-${var.tags["System"]}"
  environment = var.environment == "prod" ? "" : var.environment
}

data "aws_subnets" "nonexpose" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Name = "*nonexpose*"
  }
}
data "aws_route_tables" "this" {
  vpc_id = var.vpc_id
}

module "endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.6.0"

  vpc_id = var.vpc_id

  create_security_group      = true
  security_group_name_prefix = "${local.name}-${var.tags["Project"]}-sg"
  security_group_description = "Security group for Allow in VPC Endpoint Service: ${var.tags["Service"]} System: ${var.tags["System"]}."
  security_group_rules = merge(var.security_group_rules_other, {
    https = {
      type             = "ingress"
      description      = "Allow to HTTPS"
      protocol         = "tcp"
      from_port        = 443
      to_port          = 443
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    http = {
      type             = "ingress"
      description      = "Allow to HTTP"
      protocol         = "tcp"
      from_port        = 80
      to_port          = 80
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    egress = {
      type             = "egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  })

  endpoints = merge(var.endpoint_other, {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = data.aws_route_tables.this.ids
      tags            = { Name = "${local.name}-s3${local.environment}-vpc-endpoint" }
    }
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = data.aws_route_tables.this.ids
      tags            = { Name = "${local.name}-dynamodb${local.environment}-vpc-endpoint" }
    }
    api_gateway = {
      service             = "execute-api"
      service_type        = "Interface"
      subnet_ids          = data.aws_subnets.nonexpose.ids
      private_dns_enabled = false
      tags                = { Name = "${local.name}-apigw${local.environment}-vpc-endpoint" }
    }
    sqs = {
      service             = "sqs"
      service_type        = "Interface"
      subnet_ids          = data.aws_subnets.nonexpose.ids
      private_dns_enabled = false
      tags                = { Name = "${local.name}-sqs${local.environment}-vpc-endpoint" }
    }
    sns = {
      service             = "sns"
      service_type        = "Interface"
      subnet_ids          = data.aws_subnets.nonexpose.ids
      private_dns_enabled = false
      tags                = { Name = "${local.name}-sns${local.environment}-vpc-endpoint" }
    }
    forecast = {
      service             = "forecast"
      service_type        = "Interface"
      subnet_ids          = data.aws_subnets.nonexpose.ids
      private_dns_enabled = false
      tags                = { Name = "${local.name}-forecast${local.environment}-vpc-endpoint" }
    }
    forecastquery = {
      service             = "forecastquery"
      service_type        = "Interface"
      subnet_ids          = data.aws_subnets.nonexpose.ids
      private_dns_enabled = false
      tags                = { Name = "${local.name}-forecastquery${local.environment}-vpc-endpoint" }
    }
    personalize = {
      service             = "personalize"
      service_type        = "Interface"
      subnet_ids          = data.aws_subnets.nonexpose.ids
      private_dns_enabled = false
      tags                = { Name = "${local.name}-personalize${local.environment}-vpc-endpoint" }
    }
    cloudwatchlogs = {
      service             = "logs"
      service_type        = "Interface"
      subnet_ids          = data.aws_subnets.nonexpose.ids
      private_dns_enabled = false
      tags                = { Name = "${local.name}-cloudwatchlogs${local.environment}-vpc-endpoint" }
    }
    ecrapi = {
      service             = "ecr.api"
      service_type        = "Interface"
      subnet_ids          = data.aws_subnets.nonexpose.ids
      private_dns_enabled = false
      tags                = { Name = "${local.name}-ecrapi${local.environment}-vpc-endpoint" }
    }
    ecrdkr = {
      service             = "ecr.dkr"
      service_type        = "Interface"
      subnet_ids          = data.aws_subnets.nonexpose.ids
      private_dns_enabled = false
      tags                = { Name = "${local.name}-ecrdkr${local.environment}-vpc-endpoint" }
    }
  })

  tags = var.tags
}