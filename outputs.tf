#output "azureJumphostPublicIps" {
#  description = "Jumphost Public IPs"
#  value       = values(module.jumphost)[*]["publicIp"]
#}

#output "vnetIds" {
#  description = "VNet IDs"
#  value       = values(module.network)[*]["vnet_id"]
#}

output "bu11-webserver-private-ip" {
  description = "bu11-webserver-private-ip"
  value       = module.bu11-webserver.*.privateIp
}
output "bu11-webserver-public-ip" {
  description = "bu11-webserver-public-ip"
  value       = module.bu11-webserver.*.publicIp
}
output "hub-ce-private-ip" {
  description = "hub-ce-private-ip"
  value       = data.azurerm_network_interface.sli.private_ip_address
}

output "hub-ce-public-ip" {
  description = "hub-ce-public-ip"
  value       = data.azurerm_public_ip.cePublicIp.ip_address
}