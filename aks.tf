resource "azurerm_kubernetes_cluster" "aksBu12Prod" {
  name                = format("%s-aksBu12Prod-%s", var.projectPrefix, var.buildSuffix)
  location            = azurerm_resource_group.bu12.location
  resource_group_name = azurerm_resource_group.bu12.name
  dns_prefix          = "kubecluster"
  default_node_pool {
    name             = "default"
    node_count       = "3"
    vm_size          = "Standard_DS3_v2"
    vnet_subnet_id   = module.bu12-network.vnet_subnets[0]
  }
  identity {
    type = "SystemAssigned"
  }
}
// config
resource "local_file" "kube_config" {
  content  = azurerm_kubernetes_cluster.aksBu12Prod.kube_config_raw
  filename = "./aks-cluster-config"
}
resource "local_file" "kube_client_cert" {
  content  = azurerm_kubernetes_cluster.aksBu12Prod.kube_config.0.client_certificate
  filename = "./aks-client-cert"
}