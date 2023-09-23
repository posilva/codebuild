locals {
 name = "posilva-codebuild-test"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "service_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

}
data "aws_iam_policy_document" "build_policy" {

  statement {
    effect = "Allow"
    actions = [
      "iam:DeletePolicyVersion",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"

    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

}

resource "aws_iam_role_policy" "build_role_policy" {
  role   = aws_iam_role.service_role.name
  policy = data.aws_iam_policy_document.build_policy.json
}

module "ecr" {
  source = "cloudposse/ecr/aws"
  version     = "0.38.0"
  name                   = local.name
  principals_full_access = [aws_iam_role.service_role.arn]
  force_delete = true
}
resource "aws_codebuild_project" "project-with-cache" {
  name           = local.name
  description    = "test codebuild"
  build_timeout  = "120"
  queued_timeout = "120"


  service_role = aws_iam_role.service_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    privileged_mode             = true
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "IMAGE_NAME"
      value = local.name
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/posilva/codebuild.git"
    git_clone_depth = 1
    git_submodules_config {
      fetch_submodules = true
    }
  }

  tags = {
    Environment = "Test"
  }
}

data "aws_caller_identity" "current" {}
