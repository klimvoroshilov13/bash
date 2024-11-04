#!/bin/sh

# Server WireGuard
server_ip="ip_address"
server_port="port"

# Function to calculate the port based on current date and time
calculate_port() {
    _calculate_port_day=$(date +%d)
    _calculate_port_hour=$(date +%H)
    _calculate_port_minute=$(date +%M)
    echo $((45001 + _calculate_port_day * _calculate_port_hour + _calculate_port_minute))
}

get_last_handshake_time() {
    
    # Capture the time of the 'ndmc' command and extract the last-handshake time
    time=$(ndmc -c "show interface Wireguard0" | grep "last-handshake" | grep -o '[0-9]\+')

    # Return the time
    echo "$time"
}

# Get last handshake time
last_handshake=$(get_last_handshake_time)

# Check if the last handshake number is greater than 125
if [ "$last_handshake" -gt 125 ] && [ "$last_handshake" -lt 300 ]; then
    
    # Get interface Wireguard0
    interface=$(ndmc -c "show interface Wireguard0")
    
    # Calculate the port
    port=$(calculate_port)

    # Run nping with the calculated source port
    nping --udp --count 10 --data-length 16 --source-port "$port" --dest-port $server_port $server_ip > /dev/null 2>&1

    # Run ndmc to set the Wireguard listen port
    ndmc -c "interface Wireguard0 wireguard listen-port $port" > /dev/null 2>&1

    # Log
    echo "$(date +"%Y-%m-%d %H:%M:%S") $interface" >> /opt/var/log/wg-interface.log
    echo "$(date +"%Y-%m-%d %H:%M:%S") Last handshake: $last_handshake New port: $port" >> /opt/var/log/wg.log
else
    # Exit the script if the interface does not exist
    exit 1
fi
