output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "ID VPC"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "IDs publicznych subnetów"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "IDs prywatnych subnetów"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "ID IGW"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "RT publiczna"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "RT prywatna"
}
