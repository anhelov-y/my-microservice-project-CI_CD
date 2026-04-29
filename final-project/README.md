# Final Project — DevOps Infrastructure on AWS

Фінальний проєкт розгортає повну DevOps інфраструктуру на AWS за допомогою Terraform.

## Що входить

- VPC з публічними і приватними підмережами
- EKS кластер з EBS CSI Driver та IAM ролями
- ECR репозиторій для Docker образів
- RDS база даних (PostgreSQL або Aurora)
- Jenkins для CI/CD
- Argo CD для GitOps деплою
- Prometheus + Grafana для моніторингу
- S3 + DynamoDB для Terraform state

## Структура проєкту

```
final-project/
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду (S3 + DynamoDB)
├── outputs.tf               # Загальні виводи ресурсів
├── README.md                # Документація проєкту
├── Dockerfile               # Docker образ для додатку
├── Jenkinsfile              # Pipeline для Jenkins
├── requirements.txt         # Python залежності
├── trust-policy.json        # IAM trust policy для EBS CSI
├── .gitignore
│
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml
│
└── modules/
    ├── s3-backend/          # Модуль для S3 та DynamoDB
    │   ├── s3.tf
    │   └── dynamodb.tf
    │
    ├── vpc/                 # Модуль для VPC
    │   ├── vpc.tf
    │   ├── routes.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ecr/                 # Модуль для ECR репозиторію
    │   ├── ecr.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── eks/                 # Модуль для EKS кластера
    │   ├── eks.tf           # Cluster + Node Group + EBS CSI IAM Role
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── rds/                 # Модуль для бази даних
    │   ├── rds.tf           # Звичайна RDS instance
    │   ├── aurora.tf        # Aurora Cluster
    │   ├── shared.tf        # Subnet Group + Security Group + Parameter Group
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── jenkins/             # Модуль для Jenkins
    │   ├── jenkins.tf       # Helm release (persistence=false)
    │   ├── providers.tf     # Kubernetes + Helm провайдери
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── values.yaml
    │
    ├── argo_cd/             # Модуль для Argo CD
    │   ├── jenkins.tf       # Helm release для Argo CD
    │   ├── providers.tf     # Kubernetes + Helm провайдери
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── values.yaml
    │   └── charts/          # Helm-чарт для app'ів
    │       ├── Chart.yaml
    │       ├── values.yaml
    │       └── templates/
    │           ├── application.yaml
    │           └── repository.yaml
    │
    └── monitoring/          # Модуль для моніторингу
        ├── monitoring.tf    # Helm release kube-prometheus-stack
        ├── providers.tf     # Kubernetes + Helm провайдери
        ├── variables.tf
        ├── outputs.tf       # grafana_url, prometheus_url
        └── values.yaml      # Grafana + Prometheus конфігурація

```

## Як запустити

```bash
cd final-project
terraform init
terraform apply
```

Після apply підключи kubectl:

```bash
aws eks update-kubeconfig --region eu-central-1 --name django-cluster
```

## Перевірка сервісів

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

## Доступ через port-forward

Відкрий 3 окремих термінали у ВМ:

```bash
# Термінал 1 — Jenkins
kubectl port-forward svc/jenkins 8080:8080 -n jenkins --address 0.0.0.0

# Термінал 2 — Argo CD
kubectl port-forward svc/argocd-server 8081:80 -n argocd --address 0.0.0.0

# Термінал 3 — Grafana
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring --address 0.0.0.0
```

Відкривай у браузері всередині ВМ:

- Jenkins: http://localhost:8080
- Argo CD: http://localhost:8081
- Grafana: http://localhost:3000

## Паролі

```bash
# Jenkins
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins \
  -- /bin/cat /run/secrets/additional/chart-admin-password && echo

# Argo CD
kubectl get secret -n argocd argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

Grafana: логін `admin` / пароль `admin123`

---

## Вирішення типових проблем

### kubectl не підключений після перезавантаження ВМ

```bash
aws eks update-kubeconfig --region eu-central-1 --name django-cluster
```

### Версія провайдерів не співпадає

```bash
terraform init -upgrade
```

### Ресурси вже існують в AWS після незавершеного apply

```bash
terraform import module.eks.aws_eks_node_group.main django-cluster:django-node-group
terraform import module.argo_cd.helm_release.argocd argocd/argocd
terraform import module.monitoring.helm_release.prometheus monitoring/prometheus
terraform import module.rds.aws_db_instance.this[0] django-project-db-instance
terraform apply
```

### Helm release вже існує (cannot re-use a name)

```bash
helm uninstall jenkins -n jenkins
helm uninstall argocd -n argocd
helm uninstall prometheus -n monitoring
terraform apply
```

### Helm release заблокований (upgrade in progress)

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm rollback argocd -n argocd
helm rollback prometheus -n monitoring
terraform apply
```

### Jenkins pod в статусі Pending — Too many pods

```bash
# Додати третю ноду
aws eks update-nodegroup-config \
  --cluster-name django-cluster \
  --nodegroup-name django-node-group \
  --scaling-config minSize=2,maxSize=4,desiredSize=3 \
  --region eu-central-1

# Перевірити ноди
kubectl get nodes
kubectl get pods -n jenkins
```

### EBS CSI Driver не встановлений (PVC Pending)

```bash
# Встановити driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.28"

# Перевірити pods
kubectl get pods -n kube-system | grep ebs

# Прив'язати IAM роль
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
kubectl annotate sa ebs-csi-controller-sa -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_Role

# Перезапустити controller
kubectl rollout restart deployment ebs-csi-controller -n kube-system
```

### Jenkins PVC не створюється — створити вручну

```bash
kubectl apply -f - <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp2
  resources:
    requests:
      storage: 8Gi
YAML

kubectl delete pod jenkins-0 -n jenkins
```

### Оновити Jenkins без persistence

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm upgrade jenkins jenkins/jenkins \
  --namespace jenkins \
  --set persistence.enabled=false \
  --set controller.serviceType=LoadBalancer
```

---

## RDS Module

### Звичайна RDS (PostgreSQL)

```hcl
module "rds" {
  source                 = "./modules/rds"
  use_aurora             = false
  project_name           = "my-project"
  vpc_id                 = module.vpc.vpc_id
  private_subnets        = module.vpc.private_subnet_ids
  app_security_group_id  = module.eks.node_security_group_id
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.micro"
  parameter_group_family = "postgres15"
  db_name                = "mydb"
  db_username            = "admin"
  db_password            = "SecurePass123!"
  allocated_storage      = 20
  multi_az               = false
}
```

### Aurora Cluster

```hcl
module "rds" {
  source                 = "./modules/rds"
  use_aurora             = true
  project_name           = "my-project"
  vpc_id                 = module.vpc.vpc_id
  private_subnets        = module.vpc.private_subnet_ids
  app_security_group_id  = module.eks.node_security_group_id
  engine                 = "aurora-postgresql"
  engine_version         = "15.4"
  instance_class         = "db.t3.medium"
  parameter_group_family = "aurora-postgresql15"
  db_name                = "mydb"
  db_username            = "admin"
  db_password            = "SecurePass123!"
  aurora_instance_count  = 1
}
```

## Змінні RDS модуля

| Змінна                   | Тип          | Default     | Опис                                |
| ------------------------ | ------------ | ----------- | ----------------------------------- |
| `use_aurora`             | bool         | false       | true = Aurora, false = звичайна RDS |
| `project_name`           | string       | —           | назва проєкту                       |
| `vpc_id`                 | string       | —           | ID VPC                              |
| `private_subnets`        | list(string) | —           | приватні підмережі                  |
| `app_security_group_id`  | string       | —           | security group EKS нод              |
| `engine`                 | string       | postgres    | тип БД                              |
| `engine_version`         | string       | —           | версія, наприклад 15.4              |
| `instance_class`         | string       | db.t3.micro | розмір інстансу                     |
| `parameter_group_family` | string       | —           | наприклад postgres15                |
| `db_name`                | string       | —           | назва бази                          |
| `db_username`            | string       | —           | юзер                                |
| `db_password`            | string       | —           | пароль (sensitive)                  |
| `db_port`                | number       | 5432        | порт (3306 для MySQL)               |
| `allocated_storage`      | number       | 20          | розмір в GB                         |
| `multi_az`               | bool         | false       | кілька зон доступності              |
| `aurora_instance_count`  | number       | 1           | кількість інстансів Aurora          |

## Вимоги

- Terraform >= 1.0
- AWS CLI налаштований
- kubectl встановлений
- helm встановлений
