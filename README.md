# Provisioning Monitoring with Terraform, Prometheus, Grafana, CloudWatch, and SNS

This project is focused on provisioning a static website with Terraform and setting up monitoring for EC2 instances using Prometheus and Grafana. It also integrates AWS CloudWatch to monitor EC2 CPU consumption and triggers email alerts via SNS when the CPU usage goes above 50%.

## Overview

The project includes the following components:

- **Terraform**: To provision AWS resources including EC2, CloudWatch, and SNS.
- **Prometheus**: To monitor metrics of EC2 instances and services.
- **Grafana**: To visualize the metrics collected by Prometheus.
- **CloudWatch**: To monitor EC2 instance CPU consumption.
- **SNS (Simple Notification Service)**: To send email alerts when EC2 CPU consumption exceeds 50%.

## Architecture

- Terraform provisions:
  - EC2 instance (static website).
  - CloudWatch monitoring for the EC2 instance.
  - SNS for email alerts.
- Prometheus scrapes metrics from EC2 instances.
- Grafana dashboards display the collected data.
- CloudWatch triggers an SNS email alert when CPU consumption exceeds 50%.

## Prerequisites

Before running this project, make sure you have the following:

- **AWS Account** with appropriate IAM permissions to create resources like EC2, CloudWatch, and SNS.
- **Terraform** installed on your local machine.
- **Prometheus** and **Grafana** instances set up and configured.
- **AWS CLI** configured with access keys.

## Setup Instructions

Clone the Repository

```bash
git clone https://github.com/your-username/provisioning-monitoring-terraform.git](https://github.com/ankitjindal9404/Monitoring-with-Terraform.git)
cd Monitoring-with-Terraform
