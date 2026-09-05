resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno"
  chart            = "kyverno"
  namespace        = "kyverno"
  create_namespace = true
  version          = "3.2.6"

  values = [
    yamlencode({
      replicaCount = 1
      resources = {
        requests = { cpu = "50m", memory = "128Mi" }
        limits   = { cpu = "200m", memory = "256Mi" }
      }
      backgroundController = {
        replicas = 1
      }
      cleanupController = {
        replicas = 1
      }
      reportsController = {
        replicas = 1
      }
      admissionController = {
        replicas = 1
      }
    })
  ]
}
