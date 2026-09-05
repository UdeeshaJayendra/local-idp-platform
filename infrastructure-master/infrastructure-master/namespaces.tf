provider "kubernetes" {
  host                   = kind_cluster.idp_dev.endpoint
  client_certificate     = kind_cluster.idp_dev.client_certificate
  client_key              = kind_cluster.idp_dev.client_key
  cluster_ca_certificate  = kind_cluster.idp_dev.cluster_ca_certificate
}

resource "kubernetes_namespace" "namespaces" {
  for_each = toset(["dev", "staging", "production", "monitoring", "argocd"])

  metadata {
    name = each.value
  }
}
