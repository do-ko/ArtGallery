variable "name" { type = string }
variable "cluster_id" { type = string }
variable "task_definition" { type = string }
variable "subnets" { type = list(string) }
variable "security_groups" { type = list(string) }
variable "assign_public_ip" { type = bool }
variable "desired_count" {
  type    = number
  default = 1
}
variable "load_balancers" {
  description = "Optional list of load balancers to attach to the service"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}
