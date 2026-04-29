resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  version    = var.chart_version

  timeout = 600
  wait    = false

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace_v1.monitoring]
}
