#!/bin/sh
apt-get update
apt-get upgrade -y 
sed -i -e 's/#net.ipv4.ip_forward.*/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i -e 's/#net.ipv6.conf.all.forwarding.*/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
sysctl -p
apt-get update
apt-get install wireguard qrencode basez -y
mkdir -m 0700 /etc/wireguard/
umask 077 
wg genkey | tee /etc/wireguard/server_privatekey | wg pubkey > /etc/wireguard/server_publickey
wg genkey | tee /etc/wireguard/client_privatekey | wg pubkey > /etc/wireguard/client_publickey
wg genpsk > /etc/wireguard/presharedkey

cat > /etc/wireguard/wg0.conf << EOF
[Interface]
Address = 192.168.6.1/24
ListenPort = 51820
PrivateKey = $(cat /etc/wireguard/server_privatekey)
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
[Peer]
PublicKey =  $(cat /etc/wireguard/client_publickey)
PresharedKey =  $(cat /etc/wireguard/presharedkey)
AllowedIps = 192.168.6.101/32
EOF

cat > /etc/wireguard/wg0_client.conf << EOF
[Interface]
PrivateKey = $(cat /etc/wireguard/client_privatekey)
Address = 192.168.6.101/32
DNS = 1.1.1.1
[Peer]
PublicKey =  $(cat /etc/wireguard/server_publickey)
PresharedKey = $(cat /etc/wireguard/presharedkey)
EndPoint = $(curl ifconfig.me):51820
AllowedIps = 0.0.0.0/0, ::/0
PersistentKeepAlive = 25
EOF
wg-quick up wg0
systemctl enable wg-quick@wg0
echo -e "HTTP/1.1 200 OK\r\n$(date)\r\nContent-Type: text/html; charset=utf-8\r\n\r\n" "<p><img src=\"data:image/png;base64,`qrencode -o - < /etc/wireguard/wg0_client.conf | basez`\"></p>" | nc -l 4711 &