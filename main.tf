provider "azurerm" {
  features {}
}

# resource "azurerm_resource_group" "main" {
#   name     = "${var.prefix}-resources"
#   location = var.location
# }

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "external" {
  name                         = "external"
  location                     = var.location
  resource_group_name          = var.rg
  allocation_method            = "Dynamic"
  domain_name_label            = var.rg 
}

# resource "azurerm_network_interface" "main" {
#   name                = "${var.prefix}-nic"
#   resource_group_name = var.rg
#   location            = var.location

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.internal.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.external.id
#   }
# }
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = var.rg

  tags = {
    environment = "Production"
  }
}
resource "azurerm_network_security_rule" "inbound" {
    name                       = "denyInternetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "80-90"
    resource_group_name         = var.rg
    network_security_group_name = azurerm_network_security_group.main.name
 }
resource "azurerm_network_security_rule" "outbound" {
    name                       = "allowVmOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "VirtualNetwork"
    source_port_range          = "80-90"
    resource_group_name         = var.rg
    network_security_group_name = azurerm_network_security_group.main.name
 }

  

resource "azurerm_lb" "loadbalancer" {
  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = var.rg

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.external.id
  }
}

resource "azurerm_lb_backend_address_pool" "loadbalancer" {
  # resource_group_name = var.rg
  loadbalancer_id = azurerm_lb.loadbalancer.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "loadbalancer" {
  resource_group_name            = var.rg
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.loadbalancer.id
  protocol                       = "Tcp"
  frontend_port_start            = 220
  frontend_port_end              = 229
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}
  

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = var.rg
  location                        = var.location
  # size                            = "Standard_D2s_v3"
  sku                             = "Standard_F2"
  instances                       = var.n_instances
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  source_image_id                 = var.image_id

  network_interface {
    name                          = "main"
    primary                       = true

    ip_configuration {
      name                        = "internal"
      primary                     = true
      subnet_id                   = azurerm_subnet.internal.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.loadbalancer.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.loadbalancer.id]
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}