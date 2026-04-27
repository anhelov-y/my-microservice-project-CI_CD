resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name
  timeout = 600
  wait = false

  values = [
    file("${path.module}/values.yaml")
  ]

   set = [
    {
      name  = "controller.envVars[0].name"
      value = "ECR_REPOSITORY_URL"
    },
    {
      name  = "controller.envVars[0].value"
      value = var.ecr_repository_url
    }
  ]
}
