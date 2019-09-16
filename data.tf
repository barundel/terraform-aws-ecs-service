data "aws_iam_policy_document" "trust_profile" {
  statement {
    sid = "AuthAssumeRole"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]
  }
}

// The boundary sets what IAM actions can be used, this just enables the permission.
data "aws_iam_policy_document" "permissions" {
  statement {
    sid = "ECSPermissions"
    effect = "Allow"
    actions = [
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}