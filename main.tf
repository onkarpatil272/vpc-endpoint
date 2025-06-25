################################################################################
# Endpoint(s)
################################################################################

locals {
  endpoints = { for k, v in var.endpoints : k => v if var.create && try(v.create, true) }
  security_group_ids = var.security_group_ids
}

data "aws_vpc_endpoint_service" "this" {
  for_each = local.endpoints

  service         = try(each.value.service, null)
  service_name    = try(each.value.service_name, null)
  service_regions = try(coalescelist(compact([each.value.service_region])), null)

  filter {
    name   = "service-type"
    values = [try(each.value.service_type, "Interface")]
  }
}

resource "aws_vpc_endpoint" "this" {
  for_each = local.endpoints

  vpc_id            = var.vpc_id
  service_name      = try(each.value.service_endpoint, data.aws_vpc_endpoint_service.this[each.key].service_name)
  service_region    = try(each.value.service_region, null)
  vpc_endpoint_type = try(each.value.service_type, "Interface")
  auto_accept       = try(each.value.auto_accept, null)

  security_group_ids  = try(each.value.service_type, "Interface") == "Interface" ? length(distinct(concat(local.security_group_ids, lookup(each.value, "security_group_ids", [])))) > 0 ? distinct(concat(local.security_group_ids, lookup(each.value, "security_group_ids", []))) : null : null
  subnet_ids          = try(each.value.service_type, "Interface") == "Interface" ? distinct(concat(var.subnet_ids, lookup(each.value, "subnet_ids", []))) : null
  route_table_ids     = try(each.value.service_type, "Interface") == "Gateway" ? lookup(each.value, "route_table_ids", null) : null
  policy              = try(each.value.policy, null)
  private_dns_enabled = try(each.value.service_type, "Interface") == "Interface" ? try(each.value.private_dns_enabled, null) : null
  ip_address_type     = try(each.value.ip_address_type, null)

  dynamic "dns_options" {
    for_each = try([each.value.dns_options], [])

    content {
      dns_record_ip_type                             = try(dns_options.value.dns_options.dns_record_ip_type, null)
      private_dns_only_for_inbound_resolver_endpoint = try(dns_options.value.private_dns_only_for_inbound_resolver_endpoint, null)
    }
  }

  dynamic "subnet_configuration" {
    for_each = try(each.value.subnet_configurations, [])

    content {
      ipv4      = try(subnet_configuration.value.ipv4, null)
      ipv6      = try(subnet_configuration.value.ipv6, null)
      subnet_id = try(subnet_configuration.value.subnet_id, null)
    }
  }

  tags = merge(
    var.tags,
    { "Name" = replace(each.key, ".", "-") },
    try(each.value.tags, {}),
  )

  timeouts {
    create = try(var.timeouts.create, "10m")
    update = try(var.timeouts.update, "10m")
    delete = try(var.timeouts.delete, "10m")
  }
}

