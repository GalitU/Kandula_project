#! /bin/bash

#!/usr/bin/env bash
set -e
#set -x

tee ~/start_web_server.sh > /dev/null <<EOF
#! /bin/bash
#!/usr/bin/env bash
set -e
apt update
apt install nginx  -y
#apt install awscli -y

echo "<body style=\"background-color: white;\"><font color=\"blue\"><center><br><br><br><br><br><br><br><br><h1>Welcome to Consul HomeWork at '$HOSTNAME'<br><br></h1></center></font></body>" | sudo tee /var/www/html/index.html

systemctl enable nginx
systemctl start nginx
systemctl status nginx
EOF

chmod +x ~/start_web_server.sh
sh ~/start_web_server.sh

# For ubuntu/images/hvm-ssd/ubuntu-hirsute-21.04-amd64-server-20220118
# Without dnsmasq

### set consul version
CONSUL_VERSION="1.8.5"

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
apt-get -qq update &>/dev/null

sudo apt-get -y install unzip

## Configure systemd-resolve for 21.04
mkdir /etc/systemd/resolved.conf.d

cat << EODMCF >/etc/systemd/resolved.conf.d/consul.conf
[Resolve]
DNS=127.0.0.1:8600
DNSSEC=false
Domains=~consul
EODMCF

systemctl restart systemd-resolved
systemctl is-active systemd-resolved

#### # Enable forward lookup of the 'consul' domain:

cat << EOF >/etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF

iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600

systemctl restart systemd-resolved
systemctl is-active systemd-resolved

echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
mv consul /usr/local/bin/consul

# Setup Consul
mkdir -p /opt/consul
mkdir -p /etc/consul.d
mkdir -p /run/consul
tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "data_dir": "/opt/consul",
  "datacenter": "GALIT_DC_HW",
  "encrypt": "uDBV4e+LbFW3019YKPxIrg==",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=Task tag_value=Consul"],
  "enable_script_checks": true,
  "server": false
}
EOF

tee /etc/consul.d/web.json > /dev/null <<EOF
{
  "service": {
    "name": "webserver",
    "tags": [
      "webserver"
    ],
    "port": 80,
    "check": {
      "args": [
        "curl",
        "localhost"
      ],
      "interval": "10s"
    }
  }
}
EOF


# Create user & grant ownership of folders
useradd consul
chown -R consul:consul /opt/consul /etc/consul.d /run/consul

# Configure consul service
tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
PIDFile=/run/consul/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent -pid-file=/run/consul/consul.pid -config-dir=/etc/consul.d
ExecStartPre=+/bin/mkdir -p /run/consul
ExecStartPre=+/bin/chown consul:consul /run/consul
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service

exit 0
