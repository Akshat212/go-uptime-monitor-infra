variable "subnet_ids" {
  type = list(string)
}

variable "sg_id" {
  type = string
}

variable "tg_arn" {
  type = string
}

variable "app_listener" {
  type = any
}

variable "ecs_task_execution_role_arn" {
  type = string
}