output "vpc_endpoint_ids" {
  value = { for k, v in aws_vpc_endpoint.this : k => v.id }
}

output "vpc_endpoint_dns_entries" {
  value = { for k, v in aws_vpc_endpoint.this : k => v.dns_entry }
}
