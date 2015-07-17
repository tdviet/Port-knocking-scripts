#!/bin/bash

# Viet Tran
# June 2015

# Experiment of port knocking using iptables
# Change the chain of port at first command as you wish

# Usage: execute  "port-knocking-server.sh" to activate port knocking
# and "port-knocking-server.sh disable" to deactivate
# You can execute "iptables -S" to check if rules are added/removed

# Current version do not check status of port knocking
# so ignore error message like "Chain already exists" or "Bad rules"
# Ref. https://www.debian-administration.org/article/268/Multiple-port_knocking_Netfilter/IPtables_only_implementation

# Please define a chain of 4 ports
PORTS=(1234 2345 3456 4567)

# Timeout: must login within the interval
# otherwise knock again after timeout

TIMEOUT=60

if [ "$1" == "disable" ]; then
    ACTION="-D"
else
    ACTION="-A"
fi

iptables -N INTO-PHASE2
iptables $ACTION INTO-PHASE2 -m recent --name PHASE1 --remove
iptables $ACTION INTO-PHASE2 -m recent --name PHASE2 --set
# Do not log phase 2, avoid logging during port scan
# iptables $ACTION INTO-PHASE2 -j LOG --log-prefix "INTO PHASE2: "

iptables -N INTO-PHASE3
iptables $ACTION INTO-PHASE3 -m recent --name PHASE2 --remove
iptables $ACTION INTO-PHASE3 -m recent --name PHASE3 --set
iptables $ACTION INTO-PHASE3 -j LOG --log-prefix "INTO PHASE3: "

iptables -N INTO-PHASE4
iptables $ACTION INTO-PHASE4 -m recent --name PHASE3 --remove
iptables $ACTION INTO-PHASE4 -m recent --name PHASE4 --set
iptables $ACTION INTO-PHASE4 -j LOG --log-prefix "INTO PHASE4: "

#/sbin/iptables $ACTION INPUT -m recent --update --name PHASE1

iptables $ACTION INPUT -p tcp --dport ${PORTS[0]} -m recent --set --name PHASE1
iptables $ACTION INPUT -p tcp --dport  ${PORTS[1]} -m recent --rcheck --name PHASE1 -j INTO-PHASE2
iptables $ACTION INPUT -p tcp --dport  ${PORTS[2]} -m recent --rcheck --name PHASE2 -j INTO-PHASE3
iptables $ACTION INPUT -p tcp --dport  ${PORTS[3]} -m recent --rcheck --name PHASE3 -j INTO-PHASE4

iptables $ACTION INPUT -p tcp --dport 22 -m recent --rcheck --seconds $TIMEOUT --name PHASE4 -j ACCEPT



