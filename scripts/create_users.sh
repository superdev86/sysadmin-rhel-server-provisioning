#!/bin/bash
set -euo pipefail

# This script bulk creates users and adds them to their assigned groups based 
# on the csv file /data/users.csv

LOGFILE="$(dirname "0")/../logs/create_users_$(date +%m%d%Y_%H%M%S).log"
sudo mkdir -p logs

# Send all stdout/stderr to both the terminal and the log file
exec > >(sudo tee -a "$LOGFILE") 2>&1

echo "=== create_users.sh run started: ==="

tail -n +2 "$(dirname "0")/../data/users.csv" | while IFS=, read username fullname group password_expiry_days; do
	sudo useradd "$username" -G "$group"
	sudo chage -M "$password_expiry_days" "$username"
	echo "Created user: $username"
done

echo "=== created_users.sh run completed: $(date) ==="
