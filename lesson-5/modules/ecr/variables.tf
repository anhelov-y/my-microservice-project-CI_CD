variable "ecr_name" {
  description = "Назва репозиторію ECR"
  type        = string
}

variable "scan_on_push" {
  description = "Чи сканувати образи на вразливості при завантаженні"
  type        = bool
  default     = true
}