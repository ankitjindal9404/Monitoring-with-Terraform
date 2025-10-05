resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP/HTTPS"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data = base64encode(file("userdata.sh"))

  tags = {
    Name = "WebServer"
  }
}

resource "aws_sns_topic" "web_alerts" {
  name = "web-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.web_alerts.arn
  protocol  = "email"
  endpoint  = var.mail_id
}

resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60" #in seconds
  statistic           = "Average"
  threshold           = "50"  # Trigger alarm if CPU utilization > 50%
  alarm_description   = "Triggered when CPU utilization is greater than 50%"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.web_server.id
  }

  alarm_actions = [
    aws_sns_topic.web_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.web_alerts.arn
  ]

  treat_missing_data = "notBreaching"
}
