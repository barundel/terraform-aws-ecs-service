variable "create_lb_listener_rule" {
  default = false
}
variable "ecs_container_port" {
  default = ""
}
variable "lb_target_group_protocol" {
  default = ""
}
variable "vpc_id" {
  default = ""
}
variable "lb_target_group_health_check" {
  type = any
}
variable "lb_target_group_deregistration_delay" {
  default = "300"
}
variable "lb_target_type" {
  default = ""
}

variable "cluster_id" {}
variable "service_name" {}
variable "desired_count" {
  default = 1
}
variable "iam_role" {
  default = ""
}
variable "container_definitions" {}
variable "create_log_group" {
  default = false
}
variable "log_group_name" {
  default = ""
}
variable "tags" {
  type = "map"
  default = {}
}
variable "log_group_retention" {
  default = 7
}