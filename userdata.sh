#!/bin/bash

sudo yum update -y

# Install Apache Web Server (for static website)
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Create a simple static HTML page
echo "<html><body><h1>Hello, World from Apache Web Server!</h1></body></html>" | sudo tee /var/www/html/index.html

# Install Prometheus
sudo yum install -y wget
wget https://github.com/prometheus/prometheus/releases/download/v2.33.0/prometheus-2.33.0.linux-amd64.tar.gz
tar -xvzf prometheus-2.33.0.linux-amd64.tar.gz
sudo mv prometheus-2.33.0.linux-amd64/prometheus /usr/local/bin
sudo mv prometheus-2.33.0.linux-amd64/promtool /usr/local/bin
sudo mkdir /etc/prometheus
sudo mv prometheus-2.33.0.linux-amd64/prometheus.yml /etc/prometheus/
sudo mkdir /var/lib/prometheus
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool /etc/prometheus/prometheus.yml /var/lib/prometheus

# Edit prometheus.yml to ensure Prometheus scrapes system metrics
echo -e "\n- job_name: 'node'\n  static_configs:\n    - targets: ['localhost:9100']" | sudo tee -a /etc/prometheus/prometheus.yml

# Create systemd service for Prometheus
echo "[Unit]
Description=Prometheus Monitoring System
Documentation=https://prometheus.io/docs/introduction/overview/

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/prometheus.service

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

sudo systemctl start prometheus
sudo systemctl enable prometheus

# Install Grafana
sudo yum install -y https://dl.grafana.com/oss/release/grafana-8.3.3-1.x86_64.rpm
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Install Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar -xvzf node_exporter-1.3.1.linux-amd64.tar.gz
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create systemd service for Node Exporter
echo "[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/node_exporter.service

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Start Node Exporter service
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Restart Prometheus to ensure it picks up the Node Exporter target
sudo systemctl restart prometheus

# ============= CloudWatch Agent Installation =============
# Install CloudWatch Agent
sudo yum install -y amazon-cloudwatch-agent

# Create CloudWatch Agent config
cat <<'EOF' | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/config.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_iowait"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

sudo systemctl enable amazon-cloudwatch-agent
