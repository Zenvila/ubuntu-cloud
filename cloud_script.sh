#Here  the below scripts is just a sample scirpts that you can use  to create the user and autoatically    assigned partation GB    & passwrod as well


#!/bin/bash# Log file
LOGFILE="/home/colab/log_$(date +%Y-%m-%d_%H-%M-%S).log"touch "$LOGFILE"# Users and their specified storage in GB
declare -A users
users=(
    ["user1"]=50    
    ["user2"]=50
    ["user3"]=50
    ["user4"]=50
    ["user5"]=30
    ["user6"]=30
    ["user7"]=60
    ["user8"]=60
    ["user9"]=60
    ["user10"]=60
    ["user11"]=100
    ["user12"]=100
)# Storage base directory
STORAGE_DIR="/home/storage"# Ensure the storage directory exists
if [[ ! -d "$STORAGE_DIR" ]]; then
    echo "Creating storage directory at $STORAGE_DIR"
    sudo mkdir -p "$STORAGE_DIR"
    sudo chmod 755 "$STORAGE_DIR"
fi# Check if quota is enabled on the filesystem
if ! sudo quota -v &>/dev/null; then
    echo "Error: Quota is not enabled on the filesystem. Exiting." | tee -a "$LOGFILE"
    exit 1
fi# Loop to create users and set their directories, disk quotas, and permissions
for user in "${!users[@]}"; do
    USER_HOME="$STORAGE_DIR/$user"
    
    # Check if user already exists
    if id "$user" &>/dev/null; then
        echo "User $user already exists. Skipping..." | tee -a "$LOGFILE"
        continue
    fi    # Create user with home directory and shell
    sudo useradd -m -d "$USER_HOME" -s /bin/bash "$user"
    if [[ $? -ne 0 ]]; then
        echo "Error creating user $user" | tee -a "$LOGFILE"
        continue
    fi    # Set directory permissions
    sudo chmod 750 "$USER_HOME"
    sudo chown $user:colab "$USER_HOME"    # Set password to '0' securely
    # echo "0" | sudo passwd --stdin "$user" &>/dev/null
    echo "$user:0" | sudo chpasswd    if [[ $? -ne 0 ]]; then
        echo "Failed to set password for $user" | tee -a "$LOGFILE"
    fi    # Set disk quota
    sudo setquota -u "$user" 0 "$((users[$user] * 1024 * 1024))" 0 0 "$STORAGE_DIR"
    if [[ $? -ne 0 ]]; then
        echo "Failed to set quota for $user" | tee -a "$LOGFILE"
    fi    # Log success
    echo "User $user created with ${users[$user]} GB quota and restricted permissions." | tee -a "$LOGFILE"
doneecho "User creation process completed. Check $LOGFILE for details."
