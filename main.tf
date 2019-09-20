resource "aws_ecs_service" "service" {
  name = var.service_name
  cluster = var.cluster_id
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count = var.desired_count
  iam_role = var.iam_role

  // Error: InvalidParameterException: The new ARN and resource ID format must be enabled to work with ECS managed tags. Opt in to the new format and try again.
//  enable_ecs_managed_tags = true
//  propagate_tags = "TASK_DEFINITION"

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name = var.service_name
    container_port = var.ecs_container_port
  }

  ordered_placement_strategy {
    type = "spread"
    field = "instanceId"
  }

  placement_constraints {
    type = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b, eu-west-1c]"
  }
}

resource "aws_ecs_task_definition" "task" {
  family = var.service_name
  container_definitions = var.container_definitions

  task_role_arn = var.task_role_arn

  placement_constraints {
    type = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b, eu-west-1c]"
  }
}


resource "aws_lb_target_group" "ecs_target_group" {

  name = "${var.service_name}-tg"
  port = var.ecs_container_port
  protocol = var.lb_target_group_protocol

  vpc_id = var.vpc_id

    stickiness {
      type = "lb_cookie"
      enabled = false
    }

  dynamic "health_check" {
    for_each = var.lb_target_group_health_check
    content {
      matcher = lookup(health_check.value, "matcher", null)
      protocol = lookup(health_check.value, "protocol", null)
      port = lookup(health_check.value, "port", null)
    }
  }

  deregistration_delay = var.lb_target_group_deregistration_delay

  target_type = var.lb_target_type

  tags = var.tags

  lifecycle {
    create_before_destroy = false
  }
}

//dynamic "stage" {
//  for_each = var.build_stages
//  content {
//    name = stage.value.name
//
//    dynamic "action" {
//      for_each = lookup(stage.value, "actions", null)
//      content {
//        category = action.value.category
//        name = action.value.name
//        owner = action.value.owner
//        provider = action.value.provider
//        version = action.value.version
//        run_order = lookup(action.value, "run_order", null)
//
//        input_artifacts = lookup(action.value, "input_artifacts", null)
//        output_artifacts = lookup(action.value, "output_artifacts", null)
//
//        configuration = lookup(action.value, "configuration", null)
//
//      }
//    }
//
//  }
//}

variable "lb_listener_rule_condition" {
  type = any
  default = []
}

variable "alb_listener_arn" {
  default = ""
}

variable "lb_listener_rule_priority" {
  default = ""
}

resource "aws_lb_listener_rule" "ecs_listener_rule" {

  action {
    target_group_arn = "${aws_lb_target_group.ecs_target_group.arn}"
    type = "forward"
  }

  condition {
    field = "host-header"
    values = [
      "${var.dns_name}"]
  }

  listener_arn = var.alb_listener_arn
  priority = var.lb_listener_rule_priority
}

resource "aws_cloudwatch_log_group" "log_group" {
  count = "${var.create_log_group ? 1 : 0}"

  name = var.log_group_name
  retention_in_days = var.log_group_retention

  tags = var.tags
}

variable "dns_name" {}