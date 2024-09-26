#!/bin/bash

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install wget and tar if they aren't already installed
echo "Installing wget and tar..."
sudo apt install -y wget tar

# Create a directory for Prometheus
echo "Creating Prometheus directory..."
mkdir -p /etc/prometheus /var/lib/prometheus

# Download and install Prometheus
PROMETHEUS_VERSION="2.47.0"
echo "Downloading Prometheus $PROMETHEUS_VERSION..."
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

echo "Extracting Prometheus..."
tar -xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROMETHEUS_VERSION}.linux-amd64

echo "Copying Prometheus binaries and configuration..."
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo cp prometheus.yml /etc/prometheus

# Create Prometheus user and set ownership
echo "Creating Prometheus user and setting permissions..."
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Create Prometheus systemd service
echo "Creating Prometheus systemd service..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/ \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries \\
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd and start Prometheus
echo "Reloading systemd and starting Prometheus..."
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Install Node Exporter
NODE_EXPORTER_VERSION="1.6.1"
echo "Downloading Node Exporter $NODE_EXPORTER_VERSION..."
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

echo "Extracting Node Exporter..."
tar -xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cd node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64

echo "Copying Node Exporter binary..."
sudo cp node_exporter /usr/local/bin/

# Create Node Exporter user
echo "Creating Node Exporter user..."
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create Node Exporter systemd service
echo "Creating Node Exporter systemd service..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
    --collector.logind

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd and start Node Exporter
echo "Reloading systemd and starting Node Exporter..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Print Prometheus and Node Exporter status
echo "Installation complete. Checking status of Prometheus and Node Exporter..."
sudo systemctl status prometheus --no-pager
sudo systemctl status node_exporter --no-pager

echo "Prometheus is running on port 9090."
echo "Node Exporter is running on port 9100."

#install grafana
sudo apt-get install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get -y install grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server