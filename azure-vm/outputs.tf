output "vm_ip" {
  description = "VM Ip"
  value       = azurerm_linux_virtual_machine.vm.public_ip_addresses
}