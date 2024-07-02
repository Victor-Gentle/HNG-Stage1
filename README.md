# Linux User Creation Bash Script
As part of the HNG Internship program, we were tasked with creating a bash script named create_users.sh to automate the creation of new users and groups on a Linux system.
[Learn more about HNG](#learn-more-about-hng-internship)
## Overview
This script, create_users.sh, automates the creation of users and their associated groups, sets up their home directories, generates random passwords, and logs all actions. The script reads from a specified text file containing usernames and group names.

## Prerequisites
- The script must be run with root privileges.
- Ensure the input file with usernames and groups is formatted correctly and exists.

## Input File Format
Each line in the input file should be formatted as follows:
```bash
username;group1,group2,...
```
Example:
```bash
light;sudo,dev,www-data
idimma;sudo
mayowa;dev,www-data
```
## Script Steps
### Check Root Privileges:
- The script starts by checking if it is being run as the root user.
- This is necessary because creating users and modifying system files requires root privileges.
- This ensures that the script has the necessary permissions to perform its tasks.
### Validate Input File:
- The script checks if the input file is provided as an argument and whether it exists.
### Setup Logging and Password Files:
The script sets up the log file and the password file. It ensures the directories exist and sets appropriate permissions for the password file
- `mkdir -p`: Ensures the directories exist.
- `> "$LOG_FILE"` and `> "$PASSWORD_FILE"`: Create or clear the log and password files.
- `chmod 600 "$PASSWORD_FILE"`: Ensures that only the owner can read the password file, enhancing security.
### Generate Passwords:
- The script defines a function to generate random passwords for the new users.
### Log Messages:
- The script defines a function to log messages with timestamps.
- This provides a way to track actions performed by the script, useful for auditing and debugging.
### Process Each Line:
The script reads and processes each line from the input file, creating users and groups, setting up home directories, generating passwords, and logging actions.
- **`IFS=';' read -r username groups`**: Reads the username and groups from each line.
- **`username=$(echo "$username" | xargs)`** and **`groups=$(echo "$groups" | xargs)`**: Removes leading/trailing whitespace.
- **`getent group "$username"`**: Checks if the user's personal group exists; creates it if it doesn't.
- **`id "$username"`**: Checks if the user already exists.
- **`password=$(generate_password)`**: Generates a random password for the user.
- **`useradd -m -g "$username" -s /bin/bash "$username"`**: Creates the user with the specified home directory and personal group.
- **`echo "$username:$password" | chpasswd`**: Sets the user's password.
- **`IFS=',' read -r -a group_array <<< "$groups"`**: Splits the groups into an array.
- **`groupadd "$group"`**: Creates additional groups if they don't exist.
- **`usermod -aG "$group" "$username"`**: Adds the user to the additional groups.
### Final Message
- The script logs a completion message and prints a final status to the console.
- Notifies the user of the script's completion and provides locations for the log and password files.

## Usage
Save the script as create_users.sh and make it executable:
```bash
chmod +x create_users.sh
```
Run the script with the user file as an argument:

```bash
sudo ./create_users.sh <name-of-text-file>
```
## Logs and Password Storage
- Log File: /var/log/user_management.log contains logs of all actions performed.
- Password File: /var/secure/user_passwords.txt stores the generated passwords securely.

## Example User File
Create a file named user_list.txt with the following content:
```bash
light;sudo,dev,www-data
idimma;sudo
mayowa;dev,www-data
```

## Run the script

```bash
sudo ./create_users.sh user_list.txt
```

This script ensures that users and groups are created as specified, with appropriate permissions and logging.

## Learn More About HNG Internship
The HNG Internship is a remote internship program designed to find and develop the most talented software developers. It offers a stimulating environment for interns to improve their skills and showcase their abilities through real-world tasks.
- [Learn more about the HNG Internship program](https://hng.tech/internship)
- [Explore hiring opportunities through HNG](https://hng.tech/hire)
- [Check out HNG Premium services](https://hng.tech/premium)

