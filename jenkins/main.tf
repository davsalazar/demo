provider "azurerm" {
    features {}
}

variable "prefix" {
    default = "aristamd_demo"
}

data "azurerm_resource_group" "main" {
    name        = "${var.prefix}_main"
}

data "azurerm_virtual_network" "main" {
    name                = "${var.prefix}_network"
    resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_subnet" "main" {
    name                    = "${var.prefix}_subnet"
    resource_group_name     = data.azurerm_resource_group.main.name
    virtual_network_name    = data.azurerm_virtual_network.main.name
}

resource "azurerm_public_ip" "main" {
    name                    = "${var.prefix}_public_ip_jenkins"
    location                = data.azurerm_resource_group.main.location
    resource_group_name     = data.azurerm_resource_group.main.name
    allocation_method       = "Dynamic"
    idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "main" {
    name                    = "${var.prefix}_nic_jenkins"
    location                = data.azurerm_resource_group.main.location
    resource_group_name     = data.azurerm_resource_group.main.name

    ip_configuration {
        name                            = "configuration"
        subnet_id                       = data.azurerm_subnet.main.id
        private_ip_address_allocation   = "Static"
        public_ip_address_id            = azurerm_public_ip.main.id
        private_ip_address              = "10.10.0.5"
    }
}

resource "azurerm_virtual_machine" "main" {
    name                    = "${var.prefix}_vm_jenkins"
    location                = data.azurerm_resource_group.main.location
    resource_group_name     = data.azurerm_resource_group.main.name
    network_interface_ids   = [azurerm_network_interface.main.id]
    vm_size                 = "Standard_A1"

    delete_os_disk_on_termination   = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher   = "Canonical"
        offer       = "UbuntuServer"
        sku         = "18.04-LTS"
        version     = "latest"
    }
    storage_os_disk {
        name                = "disk_jenkins"
        caching             = "ReadWrite"
        create_option       = "FromImage"
        managed_disk_type   = "Standard_LRS"
    }
    os_profile {
        computer_name       = "puppet-agent"
        admin_username      = "david"
        custom_data         = file("config.sh")
    }
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            key_data = file("~/.ssh/id_rsa.pub")
            path = "/home/david/.ssh/authorized_keys"
        }
    }
}

# data "azurerm_public_ip" "current" {
#     name                = azurerm_public_ip.main.name
#     resource_group_name = data.azurerm_resource_group.main.name
# }

# output "instance_ip_addr" {
#     value = data.azurerm_public_ip.current.ip_address
# }