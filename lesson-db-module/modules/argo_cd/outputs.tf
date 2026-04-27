output "argocd_url" {
  value       = "http://${data.kubernetes_service_v1.argocd_server.status[0].load_balancer[0].ingress[0].hostname}"
  description = "URL для входу в Argo CD"
}

output "argocd_initial_admin_password" {
  value       = "Використовуємо команду: kubectl get secret -n ${var.namespace} argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  description = "Як отримати початковий пароль адміністратора"
}

data "kubernetes_service_v1" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.namespace
  }
  depends_on = [helm_release.argocd]
}
