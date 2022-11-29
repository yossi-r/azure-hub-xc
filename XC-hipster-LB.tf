resource "volterra_origin_pool" "aks_hipster_pool" {
  name                   = format("%s-akshipster-%s", var.projectPrefix, var.buildSuffix)
  namespace              = var.namespace
  description            = format("Origin pool pointing to frontend k8s service running on AKS")
  loadbalancer_algorithm = "ROUND ROBIN"
  origin_servers {
    k8s_service {
      inside_network  = false
      outside_network = true
      vk8s_networks   = false
      service_name    = "frontend.${var.namespace}"
      site_locator {
        site {
          name      = volterra_azure_vnet_site.hub.name
          namespace = "system"
          tenant    = var.volterraTenant
        }
      }
    }
  }
  port               = 80
  no_tls             = true
  endpoint_selection = "LOCAL_PREFERRED"
}

resource "volterra_http_loadbalancer" "aks_hipster_lb" {
  name                            = format("akshipsterlb-%s", var.buildSuffix)
  namespace                       = var.namespace
  description                     = "HTTPS loadbalancer object foraks_hipster_lb origin server"
  domains                         = [format("%s.%s", var.hipster_app_domain, var.dnsdelegatedzone)]
  advertise_on_public_default_vip = true
  default_route_pools {
    pool {
      name      = volterra_origin_pool.aks_hipster_pool.name
      namespace = var.namespace
    }
  }
  https_auto_cert {
    http_redirect = true
    no_mtls       = true
  }
  app_firewall {
    name = volterra_app_firewall.waap-tf.name
    namespace = volterra_app_firewall.waap-tf.namespace
  }
  disable_waf                     = false
  disable_rate_limit              = true
  round_robin                     = true
  service_policies_from_namespace = true
  no_challenge                    = true
}