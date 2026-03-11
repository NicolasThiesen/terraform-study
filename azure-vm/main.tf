resource "azurerm_resource_group" "resource_group" {
  name     = "rg-vm"
  location = "West Europe"
  tags     = local.common_tags
}


resource "azurerm_public_ip" "vm_ip" {
  name                = "public-ip-terraform"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Static"

  tags = local.common_tags
}

resource "azurerm_network_interface" "ni" {
  name                = "nic-interface"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = azurerm_public_ip.vm_ip.name
    subnet_id                     = data.terraform_remote_state.vnet.outputs.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_ip.id
  }
  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "nisga" {
  network_interface_id      = azurerm_network_interface.ni.id
  network_security_group_id = data.terraform_remote_state.vnet.outputs.security_group_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-terraform"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_DC4s_v3"
  admin_username      = "terraform"
  network_interface_ids = [
    azurerm_network_interface.ni.id,
  ]

  admin_ssh_key {
    username   = "terraform"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(file("./script.sh"))

  provisioner "local-exec" {
    command = "echo ${self.public_ip_address} >> public_it.txt"
  }

  connection {
    type = "ssh"
    user = "terraform"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip_address
  }

  provisioner "remote-exec" {
    inline = [ "echo 'Ola-Mundo' > /tmp/teste.txt" ]
  }

  provisioner "file" {
    source = "main.tf"
    destination = "/tmp/main.tf"
  }
  
  tags = local.common_tags
}