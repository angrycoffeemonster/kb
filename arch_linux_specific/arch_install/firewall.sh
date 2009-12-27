#!/bin/bash

. /etc/rc.conf
. /etc/rc.d/functions

# Local Interface
LOCAL_IFACE="eth0"

# Internet Interface
INET_IFACE="eth1"
ifconfig eth1 up

# Internet modem device
INET_MODEM="ppp0"

# Ports to open for internet interface, use x:y for ranges
# SSH (TCP port 22) is opened by default.
TCPPORTS="80 443 1755 4712"
UDPPORTS="1756 1758"

# Port forwardings (DNAT)
#FORWARDINGS=(tcp 1000 192.168.0.100:1000 udp 2000 192.168.0.200:2100)
FORWARDINGS=()

start() {
  stat_busy "Starting firewall"
  
  # Setting default policies
  iptables -P INPUT DROP
  iptables -P OUTPUT ACCEPT
  iptables -P FORWARD DROP
  #iptables -P FORWARD ACCEPT
  
  # SSHGuard
  iptables -N sshguard

  # Configure IP forwarding
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o $INET_MODEM -j MASQUERADE

  #TCPMSS Fix - Needed for *many* broken PPPO{A/E} clients
  iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
  
  iptables -A FORWARD -i $LOCAL_IFACE -o $INET_MODEM -j ACCEPT
  iptables -A FORWARD -i $INET_MODEM -o $LOCAL_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT

  # LOCALHOST
  # Allow all traffic for localhost interface
  iptables -A INPUT -p all -i lo -j ACCEPT

  # LAN
  # Allow all LAN traffic
  iptables -A INPUT -p all -i $LOCAL_IFACE -j ACCEPT
  iptables -A INPUT -p all -i $INET_IFACE -j ACCEPT

  # WAN
  # SSHGuard
  iptables -A INPUT -p tcp -i $INET_MODEM --destination-port 22 -j sshguard
  iptables -A INPUT -p tcp -i $INET_MODEM --destination-port 22 -j ACCEPT

  # Inbound Internet Packet Rules: Accept Established Connections
  iptables -A INPUT -p all -i $INET_MODEM -m state --state ESTABLISHED,RELATED -j ACCEPT

  # Accept incoming connections from WAN
  for p in $TCPPORTS
  do
    iptables -A INPUT -p tcp -i $INET_MODEM --destination-port $p -j ACCEPT
  done
  for p in $UDPPORTS
  do
    iptables -A INPUT -p udp -i $INET_MODEM --destination-port $p -j ACCEPT
  done

  # Accept echo-requests
  iptables -A INPUT -p icmp --icmp-type echo-request -i $INET_MODEM -j ACCEPT

  # Forward ports
  SIZE=${#FORWARDINGS[*]}
  let "SIZE--"
  for i in `seq 0 $SIZE`
  do
    case $TYPE in
      0) # Protocol
        PROTO=${FORWARDINGS[$i]}
        ;;
      1) # Source port
        SRC=${FORWARDINGS[$i]}
        ;;
      2) # Destination host and port
        DEST=${FORWARDINGS[$i]}
        #echo "Forwarding port $SRC to host $DEST ($PROTO protocol)"
        iptables -A FORWARD -i $INET_MODEM -o $LOCAL_IFACE -p $PROTO --dport $SRC -j ACCEPT
        iptables -t nat -A PREROUTING -p $PROTO --dport $SRC -i $INET_MODEM -j DNAT --to $DEST
        ;;
    esac
  done
  
  # Configure DHCP server with dynamic DNSes from ADSL connection
  NAMESERVER=
  while read keyword value garbage
  do
    if [ "$keyword" = "nameserver" ]; then
      if [ "$NAMESERVER" = "" ]; then
        NAMESERVER="$value"
      else
        NAMESERVER="$NAMESERVER, $value"
      fi
    fi
  done < /etc/resolv.conf
  if [ "$NAMESERVER" != "" ]; then
    sed --in-place "s/domain-name-servers.*$/domain-name-servers $NAMESERVER;/" /etc/dhcpd.conf
    /etc/rc.d/dhcpd restart
  fi
  
  stat_done
}

stop() {
  stat_busy "Stopping firewall"
  
  # Flush tables and remove user-defined chains
  for table in nat mangle filter
  do
    iptables -t $table -F
    iptables -t $table -X
    iptables -t $table -Z
  done
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT
  
  stat_done
}

openall() {
  stat_busy "Configuring firewall policy: ALLOW ALL"
  
  # Flush tables and remove user-defined chains
  for table in nat mangle filter
  do
    iptables -t $table -F
    iptables -t $table -X
    iptables -t $table -Z
  done
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o $INET_MODEM -j MASQUERADE
  
  stat_done
}

case $1 in
  start|restart)
    stop
    start
    ;;
  stop)
    stop
    ;;
  openall)
    openall
    ;;
  status)
    iptables -L -t filter -v | less
    iptables -L -t nat -v | less
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|openall|status}"
    return 1
esac

