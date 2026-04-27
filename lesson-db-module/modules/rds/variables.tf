variable "project_name" {
  type        = string
  description = "Назва проєкту, використовується як префікс для всіх ресурсів"
}

variable "use_aurora" {
  type        = bool
  default     = false
  description = "Якщо true — створюється Aurora Cluster + writer instance. Якщо false — звичайна RDS instance"
}

variable "vpc_id" {
  type        = string
  description = "ID VPC, в якій розміщується база даних"
}

variable "private_subnets" {
  type        = list(string)
  description = "Список ID приватних підмереж для DB Subnet Group (мінімум 2 підмережі в різних AZ)"
}

variable "app_security_group_id" {
  type        = string
  description = "ID Security Group додатку (EKS нод), якому дозволено доступ до бази даних"
}

variable "engine" {
  type        = string
  default     = "postgres"
  description = "Тип двигуна БД: postgres, mysql, aurora-postgresql, aurora-mysql"
}

variable "engine_version" {
  type        = string
  description = "Версія двигуна БД, наприклад '15.4' для PostgreSQL або '8.0' для MySQL"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Клас інстансу БД. Наприклад: db.t3.micro (dev), db.t3.medium, db.r5.large (prod)"
}

variable "parameter_group_family" {
  type        = string
  description = "Сімейство parameter group. Наприклад: postgres15, mysql8.0, aurora-postgresql15"
}

variable "db_name" {
  type        = string
  description = "Назва бази даних, яка буде створена"
}

variable "db_username" {
  type        = string
  description = "Ім'я головного користувача бази даних"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Пароль головного користувача бази даних"
}

variable "db_port" {
  type        = number
  default     = 5432
  description = "Порт бази даних."
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Розмір сховища в GB."
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Якщо true — RDS розгортається в кількох зонах доступності для високої доступності. Тільки для RDS"
}

variable "aurora_instance_count" {
  type        = number
  default     = 1
  description = "Кількість інстансів в Aurora Cluster."
}
