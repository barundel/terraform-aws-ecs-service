variable "cluster_id" {}
variable "service_name" {}
variable "desired_count" {default = 1}
variable "iam_role" {default = ""}
variable "container_definitions" {}
variable "create_log_group" {default = false}
variable "log_group_name" {}
variable "tags" {type = "map" default = {}}
variable "log_group_retention" {default = 7}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count   = var.desired_count
  iam_role        = var.iam_role

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b, eu-west-1c]"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                = var.service_name
  container_definitions = var.container_definitions

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b, eu-west-1c]"
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  count = "${var.create_log_group ? 1 : 0}"

  name              = var.log_group_name
  retention_in_days = var.log_group_retention

  tags = var.tags
}