############################# Provider ###########################


provider "azurerm" {
  features {}
}

provider "volterra" {
  timeout = "90s"
}

locals {
    shared-key         = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

############################ Resource Groups ############################

# Create Resource Groups
resource "azurerm_resource_group" "bu11" {
  name     = format("%s-rg-%s-%s", var.projectPrefix, var.business_units.bu11.name, var.buildSuffix)
  location = var.azureLocation

  tags = {
    Name      = format("%s-rg-%s-%s", var.resourceOwner, var.business_units.bu11.name, var.buildSuffix)
    Terraform = "true"
  }
}

resource "azurerm_resource_group" "bu12" {
  name     = format("%s-rg-%s-%s", var.projectPrefix, var.business_units.bu12.name, var.buildSuffix)
  location = var.azureLocation

  tags = {
    Name      = format("%s-rg-%s-%s", var.resourceOwner, var.business_units.bu12.name, var.buildSuffix)
    Terraform = "true"
  }
}

resource "azurerm_resource_group" "hub" {
  name     = format("%s-rg-%s-%s", var.projectPrefix, var.business_units.hub.name, var.buildSuffix)
  location = var.azureLocation

  tags = {
    Name      = format("%s-rg-%s-%s", var.resourceOwner, var.business_units.hub.name, var.buildSuffix)
    Terraform = "true"
  }
}

############################ VNets ############################

# Create VNets
module "bu11-network" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.bu11.name
  vnet_name           = format("%s-vnet-%s-%s", var.projectPrefix, var.business_units.bu11.name, var.buildSuffix)
  address_space       = var.business_units.bu11["cidr"]
  subnet_prefixes     = var.business_units.bu11["subnetPrefixes"]
  subnet_names        = var.business_units.bu11["subnetNames"]
  vnet_location       = var.azureLocation

  tags = {
    Name      = format("%s-vnet-%s-%s", var.resourceOwner, var.business_units.bu11.name, var.buildSuffix)
    Terraform = "true"
  }

 # depends_on = [azurerm_resource_group.rg]
}

module "bu12-network" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.bu12.name
  vnet_name           = format("%s-vnet-%s-%s", var.projectPrefix, var.business_units.bu12.name, var.buildSuffix)
  address_space       = var.business_units.bu12["cidr"]
  subnet_prefixes     = var.business_units.bu12["subnetPrefixes"]
  subnet_names        = var.business_units.bu12["subnetNames"]
  vnet_location       = var.azureLocation

  tags = {
    Name      = format("%s-vnet-%s-%s", var.resourceOwner, var.business_units.bu12.name, var.buildSuffix)
    Terraform = "true"
  }

 # depends_on = [azurerm_resource_group.rg]
}

module "hub-network" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.hub.name
  vnet_name           = format("%s-vnet-%s-%s", var.projectPrefix, var.business_units.hub.name, var.buildSuffix)
  address_space       = var.business_units.hub["cidr"]
  subnet_prefixes     = var.business_units.hub["subnetPrefixes"]
  subnet_names        = var.business_units.hub["subnetNames"]
  vnet_location       = var.azureLocation

  tags = {
    Name      = format("%s-vnet-%s-%s", var.resourceOwner, var.business_units.hub.name, var.buildSuffix)
    Terraform = "true"
  }

 # depends_on = [azurerm_resource_group.rg]
}


#VNET PEERING

resource "azurerm_virtual_network_peering" "hub-to-bu11" {
  name                      = "hub-to-bu11"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = module.hub-network.vnet_name
  remote_virtual_network_id = module.bu11-network.vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "bu11-to-hub" {
  name                      = "bu11-to-hub"
  resource_group_name       = azurerm_resource_group.bu11.name
  virtual_network_name      = module.bu11-network.vnet_name
  remote_virtual_network_id = module.hub-network.vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "hub-to-bu12" {
  name                      = "hub-to-bu12"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = module.hub-network.vnet_name
  remote_virtual_network_id = module.bu12-network.vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "bu12-to-hub" {
  name                      = "bu12-to-hub"
  resource_group_name       = azurerm_resource_group.bu12.name
  virtual_network_name      = module.bu12-network.vnet_name
  remote_virtual_network_id = module.hub-network.vnet_id
  allow_forwarded_traffic   = true
}
#
############################# Security Groups - Jumphost, Web Servers ############################
#
## Allow webserver access
resource "azurerm_network_security_group" "bu11-webserver" {
  name                = format("%s-bu11-nsg-webservers-%s", var.projectPrefix, var.buildSuffix)
  location            = azurerm_resource_group.bu11.location
  resource_group_name = azurerm_resource_group.bu11.name

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name      = format("%s-bu11-nsg-webservers-%s", var.resourceOwner, var.buildSuffix)
    Terraform = "true"
  }
}

resource "azurerm_network_security_group" "bu12-webserver" {
  name                = format("%s-bu12-nsg-webservers-%s", var.projectPrefix, var.buildSuffix)
  location            = azurerm_resource_group.bu12.location
  resource_group_name = azurerm_resource_group.bu12.name

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name      = format("%s-bu12-nsg-webservers-%s", var.resourceOwner, var.buildSuffix)
    Terraform = "true"
  }
}

resource "azurerm_network_security_group" "hub-webserver" {
  name                = format("%s-hub-nsg-webservers-%s", var.projectPrefix, var.buildSuffix)
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name      = format("%s-hub-nsg-webservers-%s", var.resourceOwner, var.buildSuffix)
    Terraform = "true"
  }
}

############################ Compute ############################

# Create webserver instances
module "bu11-webserver" {
  count              = var.num_servers
  source             = "./modules/webserver"
  projectPrefix      = var.projectPrefix
  buildSuffix        = var.buildSuffix
  resourceOwner      = var.resourceOwner
  azureResourceGroup = azurerm_resource_group.hub.name
  azureLocation      = azurerm_resource_group.hub.location
  ssh_key            = var.ssh_key
  subnet             = module.bu11-network.vnet_subnets[0]
  securityGroup      = azurerm_network_security_group.bu11-webserver.id
  public_address     = true
}
