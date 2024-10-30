#!/bin/sh

# Variables
IP="192.168.1.112"
USER=""
PASS=""

# Commands
ipmitool -I lanplus -U $USER -P $PASS -H $IP raw 0x30 0x45 0x01 0x02