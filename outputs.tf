output "server_ipv4" {
  description = "IPv4 address of the server"
  value       = upcloud_server.my_server.network_interface[0].ip_address
}
