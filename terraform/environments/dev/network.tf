# ============================================
# Virtual Networks (one per cluster region)
# ============================================

# Virtual Network for Cluster 1
resource "azurerm_virtual_network" "cluster_1" {
  name                = "vnet-${var.aks_cluster_1.name}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.aks_cluster_1.location
  address_space       = [var.aks_cluster_1.vnet_address_space]
  tags                = var.tags
}

# Subnet for Cluster 1 - AKS nodes (no public exposure)
resource "azurerm_subnet" "cluster_1_aks" {
  name                 = "snet-${var.aks_cluster_1.name}"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.cluster_1.name
  address_prefixes     = [cidrsubnet(var.aks_cluster_1.aks_subnet_address_prefix, 1, 1)]

  delegation {
    name = "aks-delegation"

    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}

# Virtual Network for Cluster 2
resource "azurerm_virtual_network" "cluster_2" {
  name                = "vnet-${var.aks_cluster_2.name}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.aks_cluster_2.location
  address_space       = [var.aks_cluster_2.vnet_address_space]
  tags                = var.tags
}

# Subnet for Cluster 2 - AKS nodes (no public exposure)
resource "azurerm_subnet" "cluster_2_aks" {
  name                 = "snet-${var.aks_cluster_2.name}"
  resource_group_name  = azurerm_virtual_network.cluster_2.resource_group_name
  address_prefixes     = [cidrsubnet(var.aks_cluster_2.aks_subnet_address_prefix, 1, 1)]
  virtual_network_name = azurerm_virtual_network.cluster_2.name

  delegation {
    name = "aks-delegation"

    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}

# ============================================
# Jump Host / Bastion VNet
# ============================================

# Public-facing VNet for jump host (can be accessed from internet)
resource "azurerm_virtual_network" "bastion" {
  name                = "vnet-bastion"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  address_space       = ["172.16.0.0/16"]
  tags                = var.tags
}

# Azure Bastion Subnet (required for Azure Bastion)
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_virtual_network.bastion.resource_group_name
  virtual_network_name = azurerm_virtual_network.bastion.name
  address_prefixes     = ["172.16.1.0/24"]
}

# Subnet for Jump Host VM
resource "azurerm_subnet" "jump_host" {
  name                 = "snet-jumphost"
  resource_group_name  = azurerm_virtual_network.bastion.resource_group_name
  virtual_network_name = azurerm_virtual_network.bastion.name
  address_prefixes     = [cidrsubnet(var.jump_host_subnet_address_prefix, 1, 1)]
}

# ============================================
# Network Security Groups
# ============================================

# NSG for Cluster 1 AKS Subnet
resource "azurerm_network_security_group" "cluster_1" {
  name                = "nsg-${var.aks_cluster_1.name}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.aks_cluster_1.location
  tags                = var.tags

  security_rule {
    name                       = "AllowInternal"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

# NSG for Cluster 2 AKS Subnet
resource "azurerm_network_security_group" "cluster_2" {
  name                = "nsg-${var.aks_cluster_2.name}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.aks_cluster_2.location
  tags                = var.tags

  security_rule {
    name                       = "AllowInternal"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

# NSG for Jump Host Subnet
resource "azurerm_network_security_group" "jump_host" {
  name                = "nsg-jumphost"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags

  # Allow SSH from internet
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow HTTPS from internet
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# NSG Association - Cluster 1
resource "azurerm_subnet_network_security_group_association" "cluster_1" {
  subnet_id                 = azurerm_subnet.cluster_1_aks.id
  network_security_group_id = azurerm_network_security_group.cluster_1.id
}

# NSG Association - Cluster 2
resource "azurerm_subnet_network_security_group_association" "cluster_2" {
  subnet_id                 = azurerm_subnet.cluster_2_aks.id
  network_security_group_id = azurerm_network_security_group.cluster_2.id
}

# NSG Association - Jump Host
resource "azurerm_subnet_network_security_group_association" "jump_host" {
  subnet_id                 = azurerm_subnet.jump_host.id
  network_security_group_id = azurerm_network_security_group.jump_host.id
}

# NSG Association - Bastion Subnet
resource "azurerm_subnet_network_security_group_association" "bastion_subnet" {
  subnet_id                 = azurerm_subnet.bastion_subnet.id
  network_security_group_id = azurerm_network_security_group.jump_host.id
}

# ============================================
# Network Peering (for jump host to access clusters)
# ============================================

# Peering from Bastion VNet to Cluster 1 VNet
resource "azurerm_virtual_network_peering" "bastion_to_cluster_1" {
  name                         = "bastion-to-${var.aks_cluster_1.name}"
  resource_group_name          = data.azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.bastion.name
  remote_virtual_network_id    = azurerm_virtual_network.cluster_1.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

# Peering from Bastion VNet to Cluster 2 VNet
resource "azurerm_virtual_network_peering" "bastion_to_cluster_2" {
  name                         = "bastion-to-${var.aks_cluster_2.name}"
  resource_group_name          = data.azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.bastion.name
  remote_virtual_network_id    = azurerm_virtual_network.cluster_2.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

# ============================================
# VNet Peering between Cluster VNets (for cross-cluster communication)
# ============================================

# Peering from Cluster 1 VNet to Cluster 2 VNet
resource "azurerm_virtual_network_peering" "cluster_1_to_cluster_2" {
  name                         = "${var.aks_cluster_1.name}-to-${var.aks_cluster_2.name}"
  resource_group_name          = data.azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.cluster_1.name
  remote_virtual_network_id    = azurerm_virtual_network.cluster_2.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

# Peering from Cluster 2 VNet to Cluster 1 VNet
resource "azurerm_virtual_network_peering" "cluster_2_to_cluster_1" {
  name                         = "${var.aks_cluster_2.name}-to-${var.aks_cluster_1.name}"
  resource_group_name          = data.azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.cluster_2.name
  remote_virtual_network_id    = azurerm_virtual_network.cluster_1.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

# ============================================
# Private DNS Zone (for cross-cluster DNS resolution)
# ============================================

# Private DNS Zone for cluster communication
resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.hcp.${var.fleet_location}.azmk8s.io"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = var.tags
}

# Link DNS zone to Cluster 1 VNet
resource "azurerm_private_dns_zone_virtual_network_link" "cluster_1" {
  name                  = "${var.aks_cluster_1.name}-vnet-link"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = azurerm_virtual_network.cluster_1.id
  tags                  = var.tags
}

# Link DNS zone to Cluster 2 VNet
resource "azurerm_private_dns_zone_virtual_network_link" "cluster_2" {
  name                  = "${var.aks_cluster_2.name}-vnet-link"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = azurerm_virtual_network.cluster_2.id
  tags                  = var.tags
}

# Link DNS zone to Bastion VNet (for resolution from jump host)
resource "azurerm_private_dns_zone_virtual_network_link" "bastion" {
  name                  = "bastion-vnet-link"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = azurerm_virtual_network.bastion.id
  tags                  = var.tags
}

# ============================================
# Public IP for Jump Host
# ============================================

resource "azurerm_public_ip" "jump_host" {
  name                = "pip-jumphost"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Dynamic"
  tags                = var.tags
}

# ============================================
# Network Interface for Jump Host
# ============================================

resource "azurerm_network_interface" "jump_host" {
  name                = "nic-jumphost"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.jump_host.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jump_host.id
  }
}
