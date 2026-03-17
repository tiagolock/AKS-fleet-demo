# ============================================
# Jump Host VM (Linux)
# ============================================

resource "azurerm_ssh_public_key" "ssh_key" {
  name                = "jump-host-ssh-key"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  public_key          = file("~/.ssh/id_rsa.pub")
}

resource "azurerm_linux_virtual_machine" "jump_host" {
  name                  = "vm-jumphost"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = var.location
  size                  = var.jump_host_vm_size
  admin_username        = var.jump_host_username
  network_interface_ids = [azurerm_network_interface.jump_host.id]
  tags                  = var.tags

  admin_ssh_key {
    username   = var.jump_host_username
    public_key = azurerm_ssh_public_key.ssh_key.public_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# ============================================
# Azure Bastion (optional - for secure browser-based access)
# ============================================

resource "azurerm_bastion_host" "main" {
  name                = "bastion-${var.fleet_name}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.jump_host.id
  }
}
