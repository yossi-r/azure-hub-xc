############################ Volterra Origin Pool (backend) ############################
//Definition of the WAAP Policy
resource "volterra_app_firewall" "waap-tf" {
  name      = format("%s-policy-%s", var.projectPrefix, var.buildSuffix)
  namespace = var.namespace

  // One of the arguments from this list "allow_all_response_codes allowed_response_codes" must be set
  allow_all_response_codes = true
  // One of the arguments from this list "default_anonymization custom_anonymization disable_anonymization" must be set
  default_anonymization = true
  // One of the arguments from this list "use_default_blocking_page blocking_page" must be set
  use_default_blocking_page = true
  // One of the arguments from this list "default_bot_setting bot_protection_setting" must be set
  default_bot_setting = true
  // One of the arguments from this list "default_detection_settings detection_settings" must be set
  default_detection_settings = true
  // One of the arguments from this list "use_loadbalancer_setting blocking monitoring" must be set
  use_loadbalancer_setting = true
  // Blocking mode - optional - if not set, policy is in MONITORING
  blocking = true
}

resource "volterra_origin_pool" "bu11pool" {
  name                   = format("%s-bu11pool-%s", var.projectPrefix, var.buildSuffix)
 //Name of the namespace where the origin pool must be deployed
  namespace              = var.namespace
 
   origin_servers {

    private_ip {
      ip = module.bu11-webserver.*.privateIp[0]

      //From which interface of the node onsite the IP of the service is reachable. Value are inside_network / outside_network or both.
      outside_network = true
     
     //Site definition
      site_locator {
        site {
          name      = volterra_azure_vnet_site.hub.name
          namespace = "system"
          tenant    = var.volterraTenant
        }
      }
    }

    labels = {
    }
  } 

  port = "80"
  no_tls = true
  endpoint_selection     = "LOCALPREFERED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}
############################ Volterra HTTP LB ############################

resource "volterra_http_loadbalancer" "bu11app-internal" {
  name                            = format("%s-bu11app-%s", var.projectPrefix, var.buildSuffix)
  namespace                       = var.namespace
  no_challenge                    = true
  domains                         = [format("%sapp.%s", "bu11", var.domain_name)]
  random                          = true
  disable_rate_limit              = true
  service_policies_from_namespace = true
  disable_waf                     = true

  advertise_custom {
    advertise_where {
      port = 80
      site {
        network = "SITE_NETWORK_OUTSIDE"
        site {
          name      = volterra_azure_vnet_site.hub.name
          namespace = "system"
          tenant    = var.volterraTenant
        }
      }
    }
  }

  default_route_pools {
    pool {
      name = volterra_origin_pool.bu11pool.name
    }
  }

  http {
    dns_volterra_managed = false
  }
}


resource "volterra_http_loadbalancer" "bu11app-External" {
  //Mandatory "Metadata"
  name      = format("bu11appexternal-%s", var.buildSuffix)
  namespace = var.namespace
  //End of mandatory "Metadata" 
  //Mandatory "Basic configuration" with Auto-Cert 
  domains = [format("%sapp.%s.%s", "bu11", var.domain_name, var.dnsdelegatedzone)]
  https_auto_cert {
    add_hsts = true
    http_redirect = true
    no_mtls = true
    enable_path_normalize = true
    tls_config {
        default_security = true
      }
  }
  default_route_pools {
    pool {
      name = volterra_origin_pool.bu11pool.name
    }
  }
  //Mandatory "VIP configuration"
  advertise_on_public_default_vip = true
  //End of mandatory "VIP configuration"
  //Mandatory "Security configuration"
  no_service_policies = true
  no_challenge = true
  disable_rate_limit = true
  //WAAP Policy reference, created earlier in this plan - refer to the same name
  app_firewall {
    name = volterra_app_firewall.waap-tf.name
    namespace = volterra_app_firewall.waap-tf.namespace
  }
  multi_lb_app = true
  user_id_client_ip = true
  //End of mandatory "Security configuration"
  //Mandatory "Load Balancing Control"
  source_ip_stickiness = true
  //End of mandatory "Load Balancing Control"
  
}