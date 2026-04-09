Lesson 7: Повний цикл розгортання інфраструктури (AWS, Terraform, EKS, Helm)

Цей проєкт демонструє створення хмарної інфраструктури "з нуля" та запуск контейнеризованого Django-застосунку.

## Повний список використаних команд

### 1. Підготовка інфраструктури (Terraform)

Спочатку ми налаштовуємо модулі та створюємо ресурси в AWS.

```bash
# Ініціалізація проєкту (завантаження плагінів)
terraform init

# Перевірка правильності конфігурації (синтаксис)
terraform validate

# Перегляд плану змін (що саме буде створено)
terraform plan

# Створення інфраструктури в хмарі
terraform apply -auto-approve

2. Робота з Docker та ECR
# Авторизація в Docker для AWS ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Збірка образу
docker build -t django-app .

# Тегування образу для ECR
docker tag django-app:latest <ACCOUNT_ID>[.dkr.ecr.us-east-1.amazonaws.com/django-app:latest](https://.dkr.ecr.us-east-1.amazonaws.com/django-app:latest)

# Відправка (пуш) образу в хмару
docker push <ACCOUNT_ID>[.dkr.ecr.us-east-1.amazonaws.com/django-app:latest](https://.dkr.ecr.us-east-1.amazonaws.com/django-app:latest)

3. Налаштування доступу до Kubernetes (EKS)
Щоб kubectl та helm бачили наш новий кластер.

Bash
# Оновлення конфігурації доступу (kubeconfig)
aws eks update-kubeconfig --region us-east-1 --name django-eks-cluster

# Перевірка зв'язку з кластером (список вузлів)
kubectl get nodes


4. Деплой через Helm
Розгортання застосунку за допомогою чартів.

Bash
# Встановлення (деплой) застосунку
helm install my-django ./charts/django-app

# Перевірка статусу подів
kubectl get pods

# Перевірка статусу сервісів та отримання адреси LoadBalancer
kubectl get svc

5. Очищення ресурсів (Важливо!)
Щоб не платити за ресурси після завершення роботи.

Bash
# Видалення застосунку з Kubernetes
helm uninstall my-django

# Повне знищення інфраструктури в AWS
terraform destroy -auto-approve
```
