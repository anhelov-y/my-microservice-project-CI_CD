Terraform RDS Module
Універсальний Terraform-модуль для створення баз даних AWS RDS або Aurora Cluster.
Можливості

Створення звичайної RDS instance (PostgreSQL / MySQL)
Створення Aurora Cluster з writer instance
Автоматичне створення DB Subnet Group, Security Group, Parameter Group
Підтримка багаторазового використання через змінні

Структура модуля
modules/rds/
├── aurora.tf # Створення Aurora Cluster + writer instance
├── rds.tf # Створення звичайної RDS instance
├── shared.tf # Спільні ресурси: Subnet Group, Security Group, Parameter Groups
├── variables.tf # Змінні модуля
└── outputs.tf # Виводи: хост, порт, назва БД

Приклад використання
Звичайна RDS (PostgreSQL)
hclmodule "rds" {
source = "./modules/rds"

use_aurora = false
project_name = "my-project"
vpc_id = module.vpc.vpc_id
private_subnets = module.vpc.private_subnet_ids
app_security_group_id = module.eks.node_security_group_id

engine = "postgres"
engine_version = "15.4"
instance_class = "db.t3.micro"
parameter_group_family = "postgres15"

db_name = "mydb"
db_username = "admin"
db_password = "SecurePass123!"

allocated_storage = 20
multi_az = false
}
Aurora Cluster (PostgreSQL)
hclmodule "rds" {
source = "./modules/rds"

use_aurora = true
project_name = "my-project"
vpc_id = module.vpc.vpc_id
private_subnets = module.vpc.private_subnet_ids
app_security_group_id = module.eks.node_security_group_id

engine = "aurora-postgresql"
engine_version = "15.4"
instance_class = "db.t3.medium"
parameter_group_family = "aurora-postgresql15"

db_name = "mydb"
db_username = "admin"
db_password = "SecurePass123!"

aurora_instance_count = 1
}

Опис змінних
ЗміннаТипDefaultОписproject_namestring—Назва проєкту, використовується як префікс для ресурсівuse_auroraboolfalseЯкщо true — створюється Aurora Cluster, якщо false — звичайна RDS instancevpc_idstring—ID VPC, в якій розміщується база данихprivate_subnetslist(string)—Список ID приватних підмереж для DB Subnet Groupapp_security_group_idstring—ID Security Group додатку (EKS нод), якому дозволено доступ до БДenginestring"postgres"Тип двигуна БД: postgres, mysql, aurora-postgresql, aurora-mysqlengine_versionstring—Версія двигуна БД, наприклад "15.4" для PostgreSQLinstance_classstring"db.t3.micro"Клас інстансу БД, наприклад db.t3.micro, db.t3.mediumparameter_group_familystring—Сімейство parameter group, наприклад postgres15, aurora-postgresql15db_namestring—Назва бази данихdb_usernamestring—Ім'я користувача бази данихdb_passwordstring—Пароль користувача бази даних (sensitive)db_portnumber5432Порт бази даних (5432 для PostgreSQL, 3306 для MySQL)allocated_storagenumber20Розмір сховища в GB (тільки для звичайної RDS)multi_azboolfalseЯкщо true — RDS розгортається в кількох зонах доступностіaurora_instance_countnumber1Кількість інстансів в Aurora Cluster

Outputs
OutputОписdb_hostEndpoint для підключення до бази данихdb_portПорт бази данихdb_nameНазва бази даних

Як змінити параметри БД
Змінити тип БД (RDS → Aurora)
hcluse_aurora = true # false = RDS, true = Aurora
Змінити engine
hcl# PostgreSQL
engine = "postgres"
engine_version = "15.4"
parameter_group_family = "postgres15"

# MySQL

engine = "mysql"
engine_version = "8.0"
parameter_group_family = "mysql8.0"
db_port = 3306

# Aurora PostgreSQL

engine = "aurora-postgresql"
engine_version = "15.4"
parameter_group_family = "aurora-postgresql15"
Змінити клас інстансу
hclinstance_class = "db.t3.micro" # найменший, для dev
instance_class = "db.t3.medium" # середній
instance_class = "db.r5.large" # для production
Увімкнути Multi-AZ (тільки для RDS)
hclmulti_az = true
Збільшити кількість Aurora інстансів
hclaurora_instance_count = 2 # 1 writer + 1 reader

Вимоги

Terraform >= 1.0
AWS Provider >= 4.0
Наявний VPC з приватними підмережами в мінімум 2 зонах доступності
