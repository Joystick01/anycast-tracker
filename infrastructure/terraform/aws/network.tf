resource "aws_vpc" "aws_vpc" {
  for_each = var.locations
  region = each.key
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "aws_internet_gateway" {
  for_each = var.locations
  region = each.key
  vpc_id = aws_vpc.aws_vpc[each.key].id
}

resource "aws_subnet" "aws_subnet" {
  for_each = var.locations
  region = each.key
  vpc_id = aws_vpc.aws_vpc[each.key].id
  cidr_block = "10.0.0.0/24"
  ipv6_cidr_block = aws_vpc.aws_vpc[each.key].ipv6_cidr_block
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true
  enable_resource_name_dns_aaaa_record_on_launch = true
}

resource "aws_route_table" "aws_route_table" {
  for_each = var.locations
  region = each.key
  vpc_id = aws_vpc.aws_vpc[each.key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_internet_gateway[each.key].id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.aws_internet_gateway[each.key].id
  }
  
}

resource "aws_route_table_association" "aws_route_table_association" {
  for_each = var.locations
  region = each.key
  subnet_id = aws_subnet.aws_subnet[each.key].id
  route_table_id = aws_route_table.aws_route_table[each.key].id
}

resource "aws_security_group" "aws_security_group" {
  for_each = var.locations
  name = "${var.project_name}-${each.key}-security-group"
  region = each.key
  vpc_id = aws_vpc.aws_vpc[each.key].id
  
  ingress = [
    {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "Allow all inbound traffic"
    security_groups = []
    self = false
    prefix_list_ids = [  ]
    }
  ]

  egress = [
    {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "Allow all egress traffic"
    security_groups = []
    self = false
    prefix_list_ids = [  ]
    }
  ]
}
