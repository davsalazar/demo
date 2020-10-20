provider "azurerm" {
    features {}
}

variable "prefix" {
    default = "aristamd_demo"
}

resource "azurerm_resource_group" "main" {
    name        = "${var.prefix}_main"
    location    = "West US 2"
}

resource "azurerm_virtual_network" "main" {
    name                    = "${var.prefix}_network"
    address_space           = ["10.10.0.0/24"]
    location                = azurerm_resource_group.main.location
    resource_group_name     = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
    name                    = "${var.prefix}_subnet"
    resource_group_name     = azurerm_resource_group.main.name
    virtual_network_name    = azurerm_virtual_network.main.name
    address_prefixes        = ["10.10.0.0/29"]
}

resource "azurerm_public_ip" "main" {
    name                    = "${var.prefix}_public_ip"
    location                = azurerm_resource_group.main.location
    resource_group_name     = azurerm_resource_group.main.name
    allocation_method       = "Dynamic"
    idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "main" {
    name                    = "${var.prefix}_nic"
    location                = azurerm_resource_group.main.location
    resource_group_name     = azurerm_resource_group.main.name

    ip_configuration {
        name                            = "configuration"
        subnet_id                       = azurerm_subnet.main.id
        private_ip_address_allocation   = "Dynamic"
        public_ip_address_id            = azurerm_public_ip.main.id
    }
}

resource "azurerm_virtual_machine" "main" {
    name                    = "${var.prefix}_vm"
    location                = azurerm_resource_group.main.location
    resource_group_name     = azurerm_resource_group.main.name
    network_interface_ids   = [azurerm_network_interface.main.id]
    vm_size                 = "Standard_DS1_v2"

    delete_os_disk_on_termination   = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher   = "Canonical"
        offer       = "UbuntuServer"
        sku         = "18.04-LTS"
        version     = "latest"
    }
    storage_os_disk {
        name                = "disk"
        caching             = "ReadWrite"
        create_option       = "FromImage"
        managed_disk_type   = "Standard_LRS"
    }
    os_profile {
        computer_name       = "managementvm"
        admin_username      = "david"
    }
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            key_data = file("~/.ssh/id_rsa.pub")
            path = "/home/david/.ssh/authorized_keys"
        }
    }
}

output "instance_ip_addr" {
    value = azurerm_public_ip.main.ip_address
}