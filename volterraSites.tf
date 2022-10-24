locals {
  volterra_common_labels = merge(var.labels, {
    platform = "azure"
    demo     = "azure-hub-xc"
    owner    = var.resourceOwner
    prefix   = var.projectPrefix
    suffix   = var.buildSuffix
  })
  volterra_common_annotations = {
    source      = "git::https://github.com/yossi-r/azure-hub-xc"
    provisioner = "terraform"
  }
}

############################ Volterra Azure VNet Sites ############################

resource "volterra_azure_vnet_site" "hub" {
  lifecycle {
    ignore_changes = [labels]
  }
  name           = "azure-hub1-site"
  namespace      = "system"
  annotations    = local.volterra_common_annotations
  azure_region   = azurerm_resource_group.hub.location
  resource_group = format("%s-%s-xc-%s", var.projectPrefix, "hub", var.buildSuffix)
  machine_type   = "Standard_D3_v2"
  logs_streaming_disabled = true
  no_worker_nodes         = true

  azure_cred {
    name      = var.volterraCloudCredAzure
    namespace = "system"
    tenant    = var.volterraTenant
  }

  ingress_gw {
    az_nodes {
      azure_az = "1"
      //disk_size = "disk_size"

      local_subnet {
        // One of the arguments from this list "subnet_param subnet" must be set
        subnet {
          subnet_name         = "external"
          vnet_resource_group = true
        }
      }
    }
    azure_certified_hw = "azure-byol-voltmesh"
  }
  vnet {
    // One of the arguments from this list "new_vnet existing_vnet" must be set
    existing_vnet {
      resource_group = azurerm_resource_group.hub.name
      vnet_name      = module.hub-network.vnet_name
    }
  }

}

resource "volterra_cloud_site_labels" "labels" {
  name             = volterra_azure_vnet_site.hub.name
  site_type        = "azure_vnet_site"
  labels           = local.volterra_common_labels
  ignore_on_delete = true
}

resource "volterra_tf_params_action" "applyBu" {
  site_name        = volterra_azure_vnet_site.hub.name
  site_kind        = "azure_vnet_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = false

  depends_on = [volterra_azure_vnet_site.hub]
}

############################ NIC Info ############################

# Collect data for Volterra node "site local inside" NIC
data "azurerm_network_interface" "sli" {
  name                = "master-0-slo"
  resource_group_name = volterra_azure_vnet_site.hub.resource_group
  depends_on          = [volterra_tf_params_action.applyBu]
}

data "azurerm_public_ip" "cePublicIp" {
  #name                = data.azurerm_network_interface.sli.ip_configuration[0].public_ip_address_id
  name = "master-0-public-ip"
  resource_group_name = volterra_azure_vnet_site.hub.resource_group
}