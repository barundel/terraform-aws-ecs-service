variable "cluster_id" {}
variable "service_name" {}
variable "desired_count" {default = 1}
variable "iam_role" {default = ""}
variable "container_definitions" {}

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