#!/bin/sh

# Variables
IP="192.168.1.112"
USER="Admin"
PASS="180180Ujlh"

# Commands
ipmitool -I lanplus -U $USER -P $PASS -H $IP raw 0x30 0x45 0x01 0x01
sleep 1
ipmitool -I lanplus -U $USER -P $PASS -H $IP raw 0x30 0x70 0x66 0x01 0x0 0x21
sleep 1
ipmitool -I lanplus -U $USER -P $PASS -H $IP raw 0x30 0x70 0x66 0x01 0x1 0x32