provider "azurerm" {
    features {}
}

variable "prefix" {
    default = "aristamd_demo"
}

data "azurerm_resource_group" "main" {
    name        = "${var.prefix}_main"
}

data "azurerm_subnet" "main" {
    name = "${var.prefix}_subnet"
}

resource "azurerm_network_interface" "main" {
    name                    = "${var.prefix}_nic"
    location                = azurerm_resource_group.main.location
    resource_group_name     = azurerm_resource_group.main.name

    ip_configuration {
        name                            = "configuration"
        subnet_id                       = azurerm_subnet.main.id
        private_ip_address_allocation   = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "main" {
    name                    = "${var.prefix}_vm"
    location                = azurerm_resource_group.main.location
    resource_group_name     = azurerm_resource_group.main.name
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