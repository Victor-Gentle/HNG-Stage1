#!/bin/bash

# Check if the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Check if the input file is provided
if [[ -z "$1" ]]; then
  echo "Usage: $0 <user_file>" >&2
  exit 1
fi

USER_FILE="$1"

# Check if the input file exists
if [[ ! -f "$USER_FILE" ]]; then
  echo "The file $USER_FILE does not exist." >&2
  exit 1
fi

LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure the log directory exists
mkdir -p /var/log
mkdir -p /var/secure

# Create or clear the log and password files
> "$LOG_FILE"
> "$PASSWORD_FILE"

# Set secure permissions for the password file
chmod 600 "$PASSWORD_FILE"

# Function to generate a random password
generate_password() {
  < /dev/urandom tr -dc A-Za-z0-9 | head -c12
}

# Function to log messages
log_message() {
  local message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') : $message" >> "$LOG_FILE"
}

# Read the input file and process each line
while IFS=';' read -r username groups; do
  # Remove any leading/trailing whitespace
  username=$(echo "$username" | xargs)
  groups=$(echo "$groups" | xargs)

  if [[ -z "$username" ]]; then
    continue
  fi

  # Create a personal group for the user
  if ! getent group "$username" > /dev/null; then
    groupadd "$username"
    log_message "Created group: $username"
  fi

  # Create the user with the personal group
  if ! id "$username" &>/dev/null; then
    password=$(generate_password)
    useradd -m -g "$username" -s /bin/bash "$username"
    echo "$username:$password" | chpasswd
    echo "$username,$password" >> "$PASSWORD_FILE"
    log_message "Created user: $username with home directory and password"
  else
    log_message "User $username already exists"
  fi

  # Assign the user to additional groups
  IFS=',' read -r -a group_array <<< "$groups"
  for group in "${group_array[@]}"; do
    group=$(echo "$group" | xargs)
    if [[ -n "$group" ]]; then
      if ! getent group "$group" > /dev/null; then
        groupadd "$group"
        log_message "Created group: $group"
      fi
      usermod -aG "$group" "$username"
      log_message "Added user $username to group $group"
    fi
  done

done < "$USER_FILE"

log_message "User creation script completed successfully"

echo "User creation script completed. Check the log file at $LOG_FILE and passwords at $PASSWORD_FILE."

