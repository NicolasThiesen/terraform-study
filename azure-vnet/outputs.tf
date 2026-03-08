output "subnet_id" {
  description = "ID dd subnet criada na azure"
  value       = azurerm_subnet.subnet.id
}

output "security_group_id" {
  description = "ID da SG"
  value       = azurerm_network_security_group.sg.id

}