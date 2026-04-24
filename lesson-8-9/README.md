# Lesson 8-9: CI/CD with Jenkins + Helm + Terraform + Argo CD

## Architecture
Developer → Git Push → Jenkins → Kaniko Build → ECR → Update values.yaml → ArgoCD Sync → EKS

## Deploy Infrastructure

```bash
terraform init
terraform apply
aws eks update-kubeconfig --region eu-central-1 --name django-cluster
```

## Важливо: Налаштування після розгортання

### 1. Зробити StorageClass default (необхідно для Jenkins PVC)
```bash
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

### 2. Встановити EBS CSI Driver (необхідно для створення volumes)
```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.28"
```

### 3. Зареєструвати OIDC Provider (необхідно для IAM ролей)
```bash
# Отримати OIDC URL
aws eks describe-cluster --name django-cluster --region eu-central-1 \
  --query "cluster.identity.oidc.issuer" --output text

# Зареєструвати провайдер
aws iam create-open-id-connect-provider \
  --url https://oidc.eks.eu-central-1.amazonaws.com/id/<OIDC_ID> \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 9e99a48a9960b14926bb7f3b02e22da2b0ab7280
```

### 4. Створити IAM роль для EBS CSI Driver
```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
OIDC=oidc.eks.eu-central-1.amazonaws.com/id/<OIDC_ID>

cat <<TRUST > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${OIDC}"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "${OIDC}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      }
    }
  }]
}
TRUST

aws iam create-role --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::${ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_DriverRole

kubectl rollout restart deployment ebs-csi-controller -n kube-system
```

## Access Jenkins

```bash
# Отримати URL
kubectl get svc jenkins -n jenkins

# Отримати пароль
kubectl exec -n jenkins jenkins-0 -- cat /var/jenkins_home/secrets/initialAdminPassword
```

## Jenkins Pipeline

New Item → Pipeline → "django-app-pipeline"
Pipeline script from SCM → Git
Repository URL: <your-repo>
Branch: */lesson-8-9
Script Path: Jenkinsfile
Save → Build Now


## Access ArgoCD

```bash
# Отримати URL
kubectl get svc argocd-server -n argocd

# Отримати пароль
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

## Verify ArgoCD Sync

```bash
kubectl get application -n argocd
kubectl get pods -n default
```

## Cleanup

```bash
terraform destroy
```
