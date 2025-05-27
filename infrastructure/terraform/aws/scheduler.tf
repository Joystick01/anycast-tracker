resource "aws_iam_policy" "scheduler_batch_policy" {
  name = "scheduler_batch_policy"

    policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "batch:SubmitJob",
                "batch:DescribeJobs",
                "batch:TerminateJob"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "events:PutTargets",
                "events:PutRule",
                "events:DescribeRule"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        }
       ]
      }
    )
}

resource "aws_iam_role" "scheduler-batch-role" {
  name = "scheduler-batch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler_batch_policy_attachment" {
  role       = aws_iam_role.scheduler-batch-role.name
  policy_arn = aws_iam_policy.scheduler_batch_policy.arn
}


resource "aws_scheduler_schedule" "batch_schedule" {
  for_each = var.locations
  region = each.key

  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = "rate(1 hour)"
    target {
    arn = "arn:aws:scheduler:::aws-sdk:batch:submitJob"
    role_arn = aws_iam_role.scheduler-batch-role.arn
  
    input = jsonencode({
        "JobName": "${each.value}-batch-job",
        "JobDefinition": "${aws_batch_job_definition.aws_batch_job_definition[each.key].arn}",
        "JobQueue": "${aws_batch_job_queue.aws_batch_job_queue[each.key].arn}",
    })
  }
}