# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "gitops-zoo" {
    name     = "gitops-zoo"
    location = "northeurope"

    tags = {
        cdsid = "pwalleni"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "northeurope"
    resource_group_name = "${azurerm_resource_group.gitops-zoo.name}"

    tags = {
        cdsid = "pwalleni"
    }
}

# Create subnet
resource "azurerm_subnet" "subnet" {
    name                 = "subnet"
    resource_group_name  = "${azurerm_resource_group.gitops-zoo.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "ubuntu-vm-0-publicip" {
    name                         = "ubuntu-vm-0-publicip"
    location                     = "northeurope"
    resource_group_name          = "${azurerm_resource_group.gitops-zoo.name}"
    allocation_method            = "Dynamic"

    tags = {
        cdsid = "pwalleni"
    }
}

# Create public IPs
resource "azurerm_public_ip" "ubuntu-vm-1-publicip" {
    name                         = "ubuntu-vm-1-publicip"
    location                     = "northeurope"
    resource_group_name          = "${azurerm_resource_group.gitops-zoo.name}"
    allocation_method            = "Dynamic"

    tags = {
        cdsid = "pwalleni"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
    name                = "nsg"
    location            = "northeurope"
    resource_group_name = "${azurerm_resource_group.gitops-zoo.name}"
    
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

    tags = {
        cdsid = "pwalleni"
    }
}

# Create network interface
resource "azurerm_network_interface" "ubuntu-vm-0-nic" {
    name                      = "ubuntu-vm-0-nic"
    location                  = "northeurope"
    resource_group_name       = "${azurerm_resource_group.gitops-zoo.name}"
    network_security_group_id = "${azurerm_network_security_group.nsg.id}"

    ip_configuration {
        name                          = "ubuntu-vm-0-nic-ipconf"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.ubuntu-vm-0-publicip.id}"
    }

    tags = {
        cdsid = "pwalleni"
    }
}

# Create network interface
resource "azurerm_network_interface" "ubuntu-vm-1-nic" {
    name                      = "ubuntu-vm-1-nic"
    location                  = "northeurope"
    resource_group_name       = "${azurerm_resource_group.gitops-zoo.name}"
    network_security_group_id = "${azurerm_network_security_group.nsg.id}"

    ip_configuration {
        name                          = "ubuntu-vm-0-nic-ipconf"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.ubuntu-vm-1-publicip.id}"
    }

    tags = {
        cdsid = "pwalleni"
    }
}

# Create storage account
resource "azurerm_storage_account" "thezoostorage" {
    name                        = "thezoostorage"
    resource_group_name         = "${azurerm_resource_group.gitops-zoo.name}"
    location                    = "northeurope"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        cdsid = "pwalleni"
    }
}

# Create virtual machine ubuntu-vm-0
resource "azurerm_virtual_machine" "ubuntu-vm-0" {
    name                  = "ubuntu-vm-0"
    location              = "northeurope"
    resource_group_name   = "${azurerm_resource_group.gitops-zoo.name}"
    network_interface_ids = ["${azurerm_network_interface.ubuntu-vm-0-nic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "ubuntu-vm-0-osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "ubuntu-vm-0"
        admin_username = "ansibleroot"
        admin_password = "@nsiblepassw0rd!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
 #       ssh_keys {
 #           path     = "/home/ansibleroot/.ssh/authorized_keys"
 #           key_data = file("~/.ssh/id_rsa.pub")
 #       }
    }
    
    tags = {
        cdsid = "pwalleni"
    }
}

# Create virtual machine ubuntu-vm-1
resource "azurerm_virtual_machine" "ubuntu-vm-1" {
    name                  = "ubuntu-vm-1"
    location              = "northeurope"
    resource_group_name   = "${azurerm_resource_group.gitops-zoo.name}"
    network_interface_ids = ["${azurerm_network_interface.ubuntu-vm-1-nic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "ubuntu-vm-1-osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "ubuntu-vm-1"
        admin_username = "ansibleroot"
        admin_password = "@nsiblepassw0rd!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
 #       ssh_keys {
 #           path     = "/home/ansibleroot/.ssh/authorized_keys"
 #           key_data = file("~/.ssh/id_rsa.pub")
 #       }
    }

    tags = {
        cdsid = "pwalleni"
    }
}