# Request a Spot fleet

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

resource "aws_iam_role" "ec2-spot-role" {
  name = "Spot-fleet-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "spotfleet.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "spot-fleet-policy" {
  name = "Spot-fleet-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeImages",
                "ec2:DescribeSubnets",
                "ec2:RequestSpotInstances",
                "ec2:TerminateInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:CreateTags"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": [
                        "ec2.amazonaws.com",
                        "ec2.amazonaws.com.cn"
                    ]
                }
            },
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
} 
EOF
}

resource "aws_iam_role_policy_attachment" "spot-fleet-policy-attachment" {
  role       = "${aws_iam_role.ec2-spot-role.name}"
  policy_arn = "${aws_iam_policy.spot-fleet-policy.arn}"
}

resource "aws_spot_fleet_request" "spot-fleet-request" {
  iam_fleet_role                  = "${aws_iam_role.ec2-spot-role.arn}"
  spot_price                      = "2"
  allocation_strategy             = "diversified"
  target_capacity                 = 1
  instance_interruption_behaviour = "stop"

  launch_specification {
    instance_type = "${var.instance_type1}"
    ami           = "${var.ami_id}"
    key_name      = "${var.key}"

    tags = {
      spot-instance = "true"
    }
  }

  launch_specification {
    instance_type = "${var.instance_type2}"
    ami           = "${var.ami_id}"
    key_name      = "${var.key}"

    tags = {
      spot-instance = "true"
    }
  }

  launch_specification {
    instance_type = "${var.instance_type3}"
    ami           = "${var.ami_id}"
    key_name      = "${var.key}"

    tags = {
      spot-instance = "true"
    }
  }

  launch_specification {
    instance_type = "${var.instance_type4}"
    ami           = "${var.ami_id}"
    key_name      = "${var.key}"

    tags = {
      spot-instance = "true"
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "Spot-Instance-Snapshot-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "Spot-Instance-Snapshot-Policy"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "logs:CreateLogStream",
                "ec2:DescribeInstances",
                "ec2:CreateTags",
                "ec2:CreateSnapshot",
                "ec2:DescribeSnapshots",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_main_policy_attachment" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "${data.archive_file.lambda_code.output_path}"
  function_name    = "Spot-Instance-Snapshot"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "index.handler"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda_code.output_path}"))}"
  runtime          = "nodejs8.10"
  timeout          = "120"
}

resource "aws_cloudwatch_event_rule" "Spot_Instance_Stop_Event" {
  name        = "Spot_Instance_Stop_Event"
  description = "Triggers Spot-Instance-Snapshot lambda if spot instance gets stopped"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "stopped"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda_trigger" {
  rule      = "${aws_cloudwatch_event_rule.Spot_Instance_Stop_Event.name}"
  target_id = "${aws_lambda_function.lambda_function.function_name}"
  arn       = "${aws_lambda_function.lambda_function.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.Spot_Instance_Stop_Event.arn}"
}
