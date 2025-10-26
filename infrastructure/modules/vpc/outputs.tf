output "vpc_id" {
  value       = aws_vpc.this.id
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

output "nat_gateway_ids" {
  value       = [for n in aws_nat_gateway.nat : n.id]
  description = "IDs NAT gateway (puste jeśli wyłączone)"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "RT publiczna"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "RT prywatna"
}
