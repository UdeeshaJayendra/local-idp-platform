resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = "monitoring"
  create_namespace = false
  version          = "25.24.0"

  values = [
    yamlencode({
      alertmanager = {
        enabled = false
      }
      pushgateway = {
        enabled = false
      }
      prometheus-node-exporter = {
        enabled = true
      }
      prometheus-pushgateway = {
        enabled = false
      }
      kube-state-metrics = {
        enabled = true
      }
      server = {
        resources = {
          requests = { cpu = "50m", memory = "256Mi" }
          limits   = { cpu = "200m", memory = "512Mi" }
        }
        persistentVolume = {
          enabled = false
        }
        retention = "6h"
      }
    })
  ]

  depends_on = [kubernetes_namespace.namespaces]
}

resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = "monitoring"
  create_namespace = false
  version          = "8.5.1"

  values = [
    yamlencode({
      adminPassword = "admin"
      persistence = {
        enabled = false
      }
      resources = {
        requests = { cpu = "50m", memory = "128Mi" }
        limits   = { cpu = "150m", memory = "256Mi" }
      }
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Prometheus"
              type      = "prometheus"
              url       = "http://prometheus-server.monitoring.svc.cluster.local"
              access    = "proxy"
              isDefault = true
            }
          ]
        }
      }
      service = {
        type = "ClusterIP"
      }
    })
  ]

  depends_on = [helm_release.prometheus]
}
