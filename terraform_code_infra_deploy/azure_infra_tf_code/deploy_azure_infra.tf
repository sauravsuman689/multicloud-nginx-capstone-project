#Create a Virtual Network (VNet)
resource "azurerm_virtual_network" "saurav_azure_vnet" {
  name                = "saurav_azure_vnet"
  location            = "East US"
  resource_group_name = azurerm_resource_group.saurav_azure_rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    project = "capstone"
  }
}

#Create Public and Private Subnets in the VNet
resource "azurerm_subnet" "saurav_public_subnet" {
  name                 = "saurav_public_subnet"
  resource_group_name  = azurerm_resource_group.saurav_azure_rg.name
  virtual_network_name = azurerm_virtual_network.saurav_azure_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "saurav_private_subnet" {
  name                 = "saurav_private_subnet"
  resource_group_name  = azurerm_resource_group.saurav_azure_rg.name
  virtual_network_name = azurerm_virtual_network.saurav_azure_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#Create a Network Security Group (NSG)
resource "azurerm_network_security_group" "saurav_azure_nsg" {
  name                = "saurav_azure_nsg"
  location            = "East US"
  resource_group_name = azurerm_resource_group.saurav_azure_rg.name

  security_rule {
    name                       = "AllowSSH"
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
    name                       = "AllowHTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Create a Resource Group
resource "azurerm_resource_group" "saurav_azure_rg" {
  name     = "saurav_azure_rg"
  location = "East US"
}

#Associate NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "saurav_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.saurav_public_subnet.id
  network_security_group_id = azurerm_network_security_group.saurav_azure_nsg.id
}

#Create Public IP
resource "azurerm_public_ip" "saurav_public_ip" {
  name                = "saurav_public_ip"
  resource_group_name = azurerm_resource_group.saurav_azure_rg.name
  location            = azurerm_resource_group.saurav_azure_rg.location
  allocation_method   = "Static"

}

#Create public route table
resource "azurerm_route_table" "saurav_azure_public_route_table" {
  name                = "saurav_azure_public-route-table"
  location            = azurerm_resource_group.saurav_azure_rg.location
  resource_group_name = azurerm_resource_group.saurav_azure_rg.name

  route {
    name           = "public_route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    project = "capstone"
  }
}

#Create public route table association
resource "azurerm_subnet_route_table_association" "saurav_azure_public-routetable-association" {
  subnet_id      = azurerm_subnet.saurav_public_subnet.id
  route_table_id = azurerm_route_table.saurav_azure_public_route_table.id
}


#Create Virtual Machines (VMs)
resource "azurerm_linux_virtual_machine" "azure_app_machine" {
  name                = "AzureAppMachine"
  resource_group_name = azurerm_resource_group.saurav_azure_rg.name
  location            = "East US"
  size                = "Standard_B2ms"
  admin_username = "azureadmin"
  network_interface_ids = [
    azurerm_network_interface.saurav_azure_vm_nic.id
  ]
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

  admin_ssh_key {
    username   = "azureadmin"
    public_key = file("/Users/sauravsuman/.ssh/saurav_mac_key.pub")
  }

  tags = {
    project = "capstone"
  }
}

#Create Network Interface for VM
resource "azurerm_network_interface" "saurav_azure_vm_nic" {
  name                = "saurav_azure_vm_nic"
  location            = azurerm_resource_group.saurav_azure_rg.location
  resource_group_name = azurerm_resource_group.saurav_azure_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.saurav_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.saurav_public_ip.id
  }
}
