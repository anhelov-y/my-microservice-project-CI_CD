resource "kubernetes_namespace_v1" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace_v1.jenkins.metadata[0].name
  timeout    = 600
  wait       = false

  values = [
    file("${path.module}/values.yaml")
  ]

  # Вимикаємо persistence щоб уникнути проблем з PVC на t3.small нодах
  set {
    name  = "persistence.enabled"
    value = "false"
  }

  set {
    name  = "controller.serviceType"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.envVars[0].name"
    value = "ECR_REPOSITORY_URL"
  }

  set {
    name  = "controller.envVars[0].value"
    value = var.ecr_repository_url
  }
}
