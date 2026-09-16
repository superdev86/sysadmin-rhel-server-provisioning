#!/bin/bash
set -euo pipefail

# This script bulk creates users and adds them to their assigned groups based 
# on the csv file /data/users.csv

SCRIPT_DIR="$(dirname "0")"
LOGFILE="$SCRIPT_DIR/../logs/create_users_$(date +%m%d%Y_%H%M%S).log"
CREDFILE="$SCRIPT_DIR/../secrets/credentials_$(date +%m%d%Y_%H%M%S).csv"

# Create directories if not already
# Create credentials file and change group to admin for all admins to access
sudo mkdir -p "$SCRIPT_DIR/../logs" "$SCRIPT_DIR/../secrets"
touch "$CREDFILE"
sudo chgrp admin "$CREDFILE"
sudo chmod 660 "$CREDFILE"

# Send all stdout/stderr to both the terminal and the log file
exec > >(sudo tee -a "$LOGFILE") 2>&1

echo "=== create_users.sh run started: ==="

# Creates the header of the credentials file
echo "username,temp_password" > "$CREDFILE"

tail -n +2 "$(dirname "0")/../data/users.csv" | while IFS=, read username fullname group password_expiry_days; do
	temp_password="Temp${username}2026!"

	sudo useradd "$username" -G "$group"
	echo "$username:$temp_password" | sudo chpasswd
	sudo chage -M "$password_expiry_days" -d 0 "$username"
	
	# Append the user and temp password to credentials file
	echo "$username,$temp_password" >> "$CREDFILE" 
	
	echo "Created user: $username" 

done

echo "=== created_users.sh run completed: $(date) ==="
