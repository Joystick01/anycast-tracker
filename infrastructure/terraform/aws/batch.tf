resource "aws_vpc" "aws_vpc" {
  for_each = var.locations
  region = each.key
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "aws_subnet" {
  for_each = var.locations
  region = each.key
  vpc_id = aws_vpc.aws_vpc[each.key].id
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  cidr_block = "10.0.0.0/24"
  ipv6_cidr_block = aws_vpc.aws_vpc[each.key].ipv6_cidr_block
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

resource "aws_iam_role" "iam_role_batch_execution" {
  name = "${var.project_name}-iam-role-batch-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_batch_execution" {
  role = aws_iam_role.iam_role_batch_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_batch_compute_environment" "aws_batch_compute_environment" {
  for_each = var.locations
  name = "${var.project_name}-${each.key}-compute-environment"
  region = each.key
  type = "MANAGED"

  compute_resources {
    type = "FARGATE_SPOT"
    max_vcpus = 1
    subnets = [aws_subnet.aws_subnet[each.key].id]
    security_group_ids = [aws_security_group.aws_security_group[each.key].id]

  }

}

resource "aws_batch_job_queue" "aws_batch_job_queue" {
  for_each = var.locations
  name = "${var.project_name}-${each.key}-job-queue"
  region = each.key
  priority = 1
  state = "ENABLED"

  compute_environment_order {
    order = 1
    compute_environment = aws_batch_compute_environment.aws_batch_compute_environment[each.key].arn
  }
  
}

resource "aws_batch_job_definition" "aws_batch_job_definition" {
  for_each = var.locations
  name = "${var.project_name}-${each.key}-job-definition"
  region = each.key
  type = "container"

  container_properties = jsonencode({
    VCPU=""
    environment = [
      {
        name  = "AWS_ACCESS_KEY_ID"
        value = aws_iam_access_key.iam_access_key_dynamodb.id
      },
      {
        name  = "AWS_SECRET_ACCESS_KEY"
        value = aws_iam_access_key.iam_access_key_dynamodb.secret
      },
      {
        name  = "AWS_DEFAULT_REGION"
        value = each.key
      },
      {
        name  = "DYNAMODB_TABLE_V4"
        value = aws_dynamodb_table.aws_dynamodb_table_v4.name
      },
      {
        name  = "DYNAMODB_TABLE_V6"
        value = aws_dynamodb_table.aws_dynamodb_table_v6.name
      }
    ],
    executionRoleArn = aws_iam_role.iam_role_batch_execution.arn,
    image = "ghcr.io/joystick01/anycast-tracker:main",
    network_configuration = {
      assign_public_ip = "ENABLED"
    }
    resourceRequirements = [
      {
        type = "VCPU"
        value = "0.25"
      },
      {
        type = "MEMORY"
        value = "512"
      }
    ],
    runtime_platform = {
      cpuArchitecture = "ARM64"
      operatingSystemFamily = "LINUX"
    },
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/anycast-tracker"
        "awslogs-region"        = each.key
        "awslogs-stream-prefix" = "ecs"
      }
    }
  })

  platform_capabilities = [ "FARGATE" ]


  retry_strategy {
    attempts = 1

  }

  timeout {
    attempt_duration_seconds = 600
  }
  
}