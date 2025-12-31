# Monitoring Module - CloudWatch + Prometheus/Grafana

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ECS CPU Utilization"
          region = "ap-southeast-1"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "backend"],
            ["...", "frontend"],
            ["...", "ai"]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ECS Memory Utilization"
          region = "ap-southeast-1"
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "backend"],
            ["...", "frontend"],
            ["...", "ai"]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB Request Count"
          region = "ap-southeast-1"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
          stat   = "Sum"
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB Response Time"
          region = "ap-southeast-1"
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]
          ]
          stat   = "Average"
          period = 60
        }
      }
    ]
  })
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
}

# CPU High Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = 3
  alarm_name          = "${var.project_name}-${var.environment}-${["backend", "frontend", "ai"][count.index]}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High CPU on ${["backend", "frontend", "ai"][count.index]}"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = ["backend", "frontend", "ai"][count.index]
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

# Memory High Alarm
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = 3
  alarm_name          = "${var.project_name}-${var.environment}-${["backend", "frontend", "ai"][count.index]}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "High memory on ${["backend", "frontend", "ai"][count.index]}"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = ["backend", "frontend", "ai"][count.index]
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# 5xx Error Alarm
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "High 5xx error rate"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# Outputs
output "dashboard_url" {
  value = "https://ap-southeast-1.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-1#dashboards:name=${var.project_name}-${var.environment}"
}

output "alerts_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
