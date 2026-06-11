# -----------------------------------------------------------------------------
# Outputs TP03 - noura
# -----------------------------------------------------------------------------
output "bastion_public_ip" {
  description = "IP publique (EIP) du bastion noura"
  value       = aws_eip.bastion.public_ip
}

output "bastion_ssh_command" {
  description = "Commande SSH pour se connecter au bastion"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_eip.bastion.public_ip}"
}

output "web_private_ips" {
  description = "IPs privees des instances web noura"
  value       = { for k, v in aws_instance.web : k => v.private_ip }
}

output "web_ssh_via_bastion" {
  description = "Commandes SSH vers les web via le bastion"
  value = {
    for k, v in aws_instance.web :
    k => "ssh -J ec2-user@${aws_eip.bastion.public_ip} ec2-user@${v.private_ip}"
  }
}

output "web_curl_commands" {
  description = "Commandes curl pour tester nginx depuis le bastion"
  value       = { for k, v in aws_instance.web : k => "curl http://${v.private_ip}" }
}
