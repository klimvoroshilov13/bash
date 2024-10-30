#!/bin/sh

# Server WireGuard
server_ip="127.0.0.1"
server_port="51820"

# Function to calculate the port based on current date and time
calculate_port() {
    _calculate_port_day=$(date +%d)
    _calculate_port_hour=$(date +%H)
    _calculate_port_minute=$(date +%M)
    echo $((45001 + _calculate_port_day * _calculate_port_hour + _calculate_port_minute))
}

get_last_handshake_number() {
    # Capture the output of the 'ndmc' command and extract the last-handshake information
    output=$(ndmc -c "show interface Wireguard0" | grep "last-handshake")

    # Extract the number from the output using grep
    number=$(echo "$output" | grep -o '[0-9]\+')

    # Return the number
    echo "$number"
}


# Get last handshake number
last_handshake=$(get_last_handshake_number)

# Check if the last handshake number is greater than 0
if [ "$last_handshake" -gt 125 ] && [ "$last_handshake" -lt 300 ]; then
    # Calculate the port
    port=$(calculate_port)

    # Run nping with the calculated source port
    nping --udp --count 10 --data-length 16 --source-port "$port" --dest-port $server_port $server_ip > /dev/null 2>&1

    # Run ndmc to set the Wireguard listen port
    ndmc -c "interface Wireguard0 wireguard listen-port $port" > /dev/null 2>&1

    # Log
    echo "$(date +"%Y-%m-%d %H:%M:%S") Last handshake: $last_handshake New port: $port" >> /opt/var/log/wg.log
else
    # Exit the script if the interface does not exist
    exit 1
fi
