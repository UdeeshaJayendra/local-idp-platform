provider "helm" {
  kubernetes {
    host                   = kind_cluster.idp_dev.endpoint
    client_certificate     = kind_cluster.idp_dev.client_certificate
    client_key             = kind_cluster.idp_dev.client_key
    cluster_ca_certificate = kind_cluster.idp_dev.cluster_ca_certificate
  }
}
