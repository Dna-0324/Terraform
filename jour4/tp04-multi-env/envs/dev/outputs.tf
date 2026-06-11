# envs/dev/outputs.tf
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID du VPC dev"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr
  description = "CIDR du VPC dev"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Subnets publics du VPC dev"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Subnets privés du VPC dev"
}

output "nat_gateway_public_ip" {
  value       = module.vpc.nat_gateway_public_ip
  description = "IP publique du NAT Gateway dev"
}

output "bastion_security_group_id" {
  value       = module.vpc.bastion_security_group_id
  description = "SG bastion dev"
}
