# The following are the minimum set of resources that need to exist 
#    before a VM can be be created:
# * Resource group
# * Virtual network
# * Subnet
# * Network security group
# * Network interface

# Configure the Microsoft Azure Provider.
provider "azurerm" {
  version = "~>1.31"
}

variable "location" {
    type = string
    default = "centralus"
}

variable "resource_prefix" {
    type = string
    default = "Fischer-"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "Fischer-TFResourceGroup"
  location = "centralus"
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "Fischer-TFVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "centralus"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "Fischer-TFSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.1.0/24"
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "${var.resource_prefix}TFPublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "myTFNSG"
  location            = "centralus"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "myNIC"
  location                  = "centralus"
  resource_group_name       = azurerm_resource_group.rg.name
  network_security_group_id = azurerm_network_security_group.nsg.id

  ip_configuration {
    name                          = "FischerNICConfg"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "Fischer-TF-VM"
  location              = "centralus"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myTFVM"
    admin_username = "snkfischer"
    admin_password = "Junkpass123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

