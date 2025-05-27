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
    networkConfiguration  = {
       assignPublicIp = "ENABLED"
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
     runtimePlatform  = {
      cpuArchitecture = "X86_64"
      operatingSystemFamily = "LINUX"
    },
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-create-group": "true",
#        "awslogs-group"         = aws_cloudwatch_log_group.aws_cloudwatch_log_group[each.key].name
        "awslogs-group"         = aws_cloudwatch_log_group.aws_cloudwatch_log_group.name
#        "awslogs-region"        = each.key
        "awslogs-region"        = aws_cloudwatch_log_group.aws_cloudwatch_log_group.region
        "awslogs-stream-prefix" = "${each.key}-batch"
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

resource "aws_cloudwatch_log_group" "aws_cloudwatch_log_group" {
#  for_each = var.locations
  name = "${var.project_name}-log-group"
#  region = each.key
  retention_in_days = 3
}