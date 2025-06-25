
# Terraform AWS VPC Endpoint Module

This Terraform module creates one or more **AWS VPC endpoints** (Interface or Gateway) dynamically, based on the configuration you provide.

---

## 🚀 Features

- Supports **Interface** and **Gateway** endpoint types
- Creates **multiple endpoints dynamically** using `for_each`
- Per-endpoint customization (subnets, security groups, DNS, timeouts)
- Automatically detects endpoint service names using `aws_vpc_endpoint_service` data source
- Applies custom tags including a derived `Name` tag
- Optional DNS options and subnet configuration blocks
- Safe to use with `create = false` toggle

---

## 📦 Usage Example

```hcl
module "vpc_endpoints" {
  source = "path_to_this_module" # e.g. ../modules/vpc-endpoint

  create       = true
  vpc_id       = "vpc-0abcd1234567890"
  subnet_ids   = ["subnet-01abc", "subnet-02xyz"]
  security_group_ids = ["sg-0123abcd"]

  endpoints = {
    s3 = {
      service_name    = "com.amazonaws.us-east-1.s3"
      service_type    = "Gateway"
      route_table_ids = ["rtb-123456"]
      tags = {
        Name = "s3-gateway"
      }
    }

    ec2messages = {
      service_name        = "com.amazonaws.us-east-1.ec2messages"
      service_type        = "Interface"
      private_dns_enabled = true
      subnet_ids          = ["subnet-01abc", "subnet-02xyz"]
      security_group_ids  = ["sg-0456efgh"]
      tags = {
        Name = "ec2messages-endpoint"
      }
    }
  }

  tags = {
    Environment = "dev"
    Owner       = "team-networking"
  }

  timeouts = {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}
```

---

## 🧾 Inputs

| Name                | Type                                | Description                                                  | Default     |
|---------------------|-------------------------------------|--------------------------------------------------------------|-------------|
| `create`            | `bool`                              | Whether to create the VPC endpoints                          | `true`      |
| `vpc_id`            | `string`                            | VPC ID in which to create endpoints                          | —           |
| `subnet_ids`        | `list(string)`                      | Default subnet IDs for Interface endpoints                   | `[]`        |
| `security_group_ids`| `list(string)`                      | Default security group IDs for Interface endpoints           | `[]`        |
| `tags`              | `map(string)`                       | Tags to apply to all endpoints                               | `{}`        |
| `timeouts`          | `object`                            | Timeouts for create/update/delete                            | `{}`        |
| `endpoints`         | `map(object)`                       | Map of VPC endpoint configs (see below for structure)        | `{}`        |

### Endpoint Object Structure

Each key in the `endpoints` map can include the following fields:

```hcl
{
  create                          = optional(bool)
  service                         = optional(string)
  service_name                    = optional(string)
  service_endpoint                = optional(string)
  service_region                  = optional(string)
  service_type                    = optional(string, "Interface")
  auto_accept                     = optional(bool)
  subnet_ids                      = optional(list(string))
  route_table_ids                 = optional(list(string))
  security_group_ids              = optional(list(string))
  policy                          = optional(string)
  private_dns_enabled             = optional(bool)
  ip_address_type                 = optional(string)
  dns_options = optional({
    dns_record_ip_type                             = optional(string)
    private_dns_only_for_inbound_resolver_endpoint = optional(bool)
  })
  subnet_configurations = optional([
    {
      subnet_id = string
      ipv4      = optional(string)
      ipv6      = optional(string)
    }
  ])
  tags = optional(map(string))
}
```

---

## 📤 Outputs

| Name                     | Description                                     |
|--------------------------|-------------------------------------------------|
| `vpc_endpoint_ids`       | Map of endpoint names to their IDs             |
| `vpc_endpoint_dns_names` | Map of endpoint names to their DNS information |

---

## 🛡️ Requirements

- Terraform `>= 0.13`
- AWS provider `>= 3.0`

---

## 🧠 Notes

- Use `service_name` directly if you know it (e.g., `com.amazonaws.us-east-1.s3`)
- Otherwise, you can use `service` and the module will look up the `service_name` using `aws_vpc_endpoint_service`.
- Tags are merged from `var.tags`, endpoint-specific tags, and a generated `Name` based on the endpoint key.

---

## 🧑‍💻 Maintainers

This module was built and maintained by your DevOps/Platform team.

Feel free to contribute or raise issues for improvements!
