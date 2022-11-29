data "local_file" "kubeconfig" {
  depends_on = [local_file.kube_config]
  filename   = "./aks-cluster-config"
}

locals {
  kubeconfig_b64 = data.local_file.kubeconfig.content_base64
  #hipster_manifest_content = templatefile(format("%s/manifest/hipster.tpl", path.module), {
  #  frontend_domain_url = var.app_domain != "" ? format("https://%s", var.app_domain) : "http://frontend"
  #})
}

resource "volterra_discovery" "aksBu12ProdSD" {
  name        = format("aksbu12prodsd-%s", var.buildSuffix)
  description = "Discovery object to discover all services in AKS cluster"
  namespace   = "system"
  depends_on  = [azurerm_kubernetes_cluster.aksBu12Prod]

  where {
    site {
      ref {
        name      = volterra_azure_vnet_site.hub.name
        namespace = "system"
      }
    }
  }
  discovery_k8s {
    access_info {
      kubeconfig_url {
        secret_encoding_type = "EncodingNone"
        clear_secret_info {
          url = format("string:///%s", local.kubeconfig_b64)
        }
      }
      reachable = false
      isolated  = true
    }
    publish_info {
      disable = true
    }
  }
}