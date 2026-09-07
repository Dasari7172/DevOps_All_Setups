sudo yum update -y
sudo yum install wget -y
# Fixed Java installation package
sudo yum install java-17-amazon-corretto -y

sudo mkdir /app && cd /app

sudo wget https://download.sonatype.com/nexus/3/nexus-3.92.2-01-linux-x86_64.tar.gz
sudo tar -xvf nexus-3.92.2-01-linux-x86_64.tar.gz
sudo mv nexus-3.92.2-01 nexus

sudo adduser nexus
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype*

# Corrected to target nexus.rc (Optional since Systemd handles the user, but good practice)
sudo sed -i 's/^#run_as_user=""/run_as_user="nexus"/' /app/nexus/bin/nexus.rc

# Removed duplicate User=nexus line
sudo tee /etc/systemd/system/nexus.service > /dev/null << EOL
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

# Removed legacy chkconfig command
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
sudo systemctl status nexus
