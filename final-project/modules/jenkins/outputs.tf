output "jenkins_url" {
  value       = "http://${data.kubernetes_service_v1.jenkins.status[0].load_balancer[0].ingress[0].hostname}"
  description = "URL для входу в Jenkins"
}

output "jenkins_admin_password" {
  value       = "Використовуємо команду: kubectl get secret --namespace ${var.namespace} jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 --decode"
  description = "Як отримати пароль адміністратора"
}

data "kubernetes_service_v1" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = var.namespace
  }
  depends_on = [helm_release.jenkins]
}
