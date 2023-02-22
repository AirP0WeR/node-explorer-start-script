#!/bin/bash
if wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz; then #22.02.2023
    echo command Download completed successfully
else 
    echo command Download error
    exit
fi

#Create User
sudo groupadd -f node_exporter
sudo useradd -g node_exporter --no-create-home --shell /bin/false node_exporter
sudo mkdir /etc/node_exporter
sudo chown node_exporter:node_exporter /etc/node_exporter

#Unpack Node Exporter Binary
tar -xvf node_exporter-1.5.0.linux-amd64.tar.gz

#Install Node Exporter
sudo cp node_exporter-1.5.0.linux-amd64/node_exporter /usr/bin/
sudo chown node_exporter:node_exporter /usr/bin/node_exporter

#Make a new .service file
echo \
'[Unit]
Description=Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/bin/node_exporter \
  --web.listen-address=:9100

[Install]
WantedBy=multi-user.target' \
> node_exporter.service

#Setup Node Exporter Service
sudo cp node_exporter.service /usr/lib/systemd/system/
sudo chmod 664 /usr/lib/systemd/system/node_exporter.service

#Reload systemd and Start Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl status node_exporter

#Configure node_exporter to start at boot
sudo systemctl enable node_exporter.service

#Verify Node Exporter is Running
#http://<node_exporter-ip>:9100/metrics

#Clean Up
rm -rf node_exporter-1.5.0.linux-amd64.tar.gz node_exporter-1.5.0.linux-amd64 node_exporter.service
