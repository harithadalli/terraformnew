provider "azurerm" {
    features {}
    subscription_id = "36792000-4b8f-4e6c-9811-bacd51254af5"

}
resource "azurerm_resource_group" "sandboxrg" {
    name = "sandboxrg"
    location = "Central India"
}
resource "azurerm_virtual_network" "azvnet" {
    name = "azvnet"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.sandboxrg.location
    resource_group_name = azurerm_resource_group.sandboxrg.name
}
resource "azurerm_subnet" "az_subnet" {
    name = "az_subnet"
    resource_group_name = azurerm_resource_group.sandboxrg.name
    virtual_network_name = azurerm_virtual_network.azvnet.name
    address_prefixes = ["10.0.1.0/24"]
}
resource "azurerm_public_ip" "public_ip" {
    name = "public_ip"
    location = azurerm_resource_group.sandboxrg.location
    resource_group_name = azurerm_resource_group.sandboxrg.name
    allocation_method = "Static"
    sku                 = "Standard"
}
resource "azurerm_network_interface" "az_nic" {
    name = "az_nic"
    location = azurerm_resource_group.sandboxrg.location
    resource_group_name = azurerm_resource_group.sandboxrg.name

    ip_configuration {
        name = "internaml"
        subnet_id = azurerm_subnet.az_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.public_ip.id
    }
}
# linux virtual machine
resource "azurerm_linux_virtual_machine" "azvm" {
    name = "az-linux-vm"
    resource_group_name = azurerm_resource_group.sandboxrg.name
    location = azurerm_resource_group.sandboxrg.location
    size = "Standard_B1s"
    admin_username = "azureuser"

    network_interface_ids = [

        azurerm_network_interface.az_nic.id
    ]
    disable_password_authentication = false 

    admin_password = "jeevan12345@"
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku = "20_04-lts"
        version = "latest"
    }
}
