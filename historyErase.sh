#!/bin/bash


# =========================================================
# History Eraser and Faker Script
# Now includes optional random cronjob setup
# =========================================================

# Color definitions
RED='\033[1;31m'
GREENB='\033[1;32m'
GREEN='\033[0;32m'
YELLOWB='\033[1;33m'
YELLOW='\033[0;33m'
BLUEB='\033[1;34m'
BLUE='\033[0;34m'
CYANB='\033[1;36m'
CYAN='\033[0;36m'
PURPLEB='\033[1;35m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
RESET='\033[0m'


# Auto mode flag
AUTO_MODE=false

# Check for --auto argument
if [[ "$1" == "--auto" ]]; then
    AUTO_MODE=true
fi

# Get full absolute path of this script
SCRIPT_PATH=$(readlink -f "$0")

# Define the output file (temporary, will update based on shell detection)
HISTORY_FILE=""


# List of fake commands
FAKE_COMMANDS=(
    "echo 'Hello, World!'"
    "ls -la /tmp/"
    "sudo apt-get install -y <package_name>"
    "sudo apt-get remove -y <package_name>"
    "sudo dpkg -r <package_name>"
    "sudo dpkg -P <package_name>"
    "cat /proc/cpuinfo"
    "echo 'This is a test command.'"
    "df -h"
    "sudo reboot"
    "exit 0"
    "sudo rm -rf /var/log/*"
    "sudo mount -o loop /dev/sda1 /mnt/test"
    "sudo dd if=/dev/zero of=/dev/sda bs=1M"
    "sudo systemctl disable --now network-manager.service"
    "sudo journalctl --vacuum-time=1d"
    "sudo usermod -aG sudo root"
    "sudo mkdir /etc/backup"
    "sudo chmod 777 /etc/backup"
    "sudo touch /etc/backup/secret.txt"
    "sudo cp /dev/urandom /etc/backup/secret.txt"
    "sudo mv /etc/backup/secret.txt /etc/backup/hidden.txt"
    "sudo rm -rf /home/*/.bash_history"
    "sudo find / -name '*.log' -exec rm -rf {} \;"
    "sudo apt-get purge -y --auto-remove mysql*"
    "sudo apt-get autoremove --purge -y"
    "sudo apt-get remove --purge --assume-yes apache2"
    "sudo apt-get install --reinstall libc6"
    "sudo apt-get update --fix-missing"
    "sudo systemctl stop apache2"
    "sudo systemctl start nginx"
    "sudo service --status-all"
    "sudo lsof -i"
    "sudo netstat -tuln"
    "sudo pkill -f nginx"
    "sudo userdel -r testuser"
    "sudo rm -rf /tmp/*"
    "sudo rm -rf /var/tmp/*"
    "sudo touch /tmp/.lockfile"
    "sudo chmod +x /tmp/.lockfile"
    "sudo echo 'Testing permissions' > /tmp/testfile"
    "sudo mv /tmp/testfile /tmp/newdir/"
    "sudo touch /home/user/.bash_profile"
    "sudo chown root:root /home/user/.bash_profile"
    "sudo chmod 000 /home/user/.bash_profile"
    "sudo ln -s /bin/ls /usr/bin/ls"
    "sudo ln -s /bin/bash /usr/bin/bash"
    "sudo chmod +x /usr/bin/bash"
    "sudo apt-get dist-upgrade -y"
    "sudo apt-get upgrade -y"
    "sudo apt-get install -y build-essential"
    "sudo dpkg-reconfigure -a"
    "sudo shutdown -r now"
    "sudo reboot"
    "sudo systemctl restart ssh"
    "sudo systemctl status apache2"
    "sudo systemctl status sshd"
    "sudo ip link set eth0 up"
    "sudo ip addr show"
    "sudo ip route show"
    "sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT"
    "sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT"
    "sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT"
    "sudo iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT"
    "sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT"
    "sudo iptables -F"
    "sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.0.2:8080"
    "sudo ifconfig eth0 down"
    "sudo ifconfig eth0 up"
    "sudo service mysql stop"
    "sudo service postgresql restart"
    "sudo mysql -e 'DROP DATABASE testdb;'"
    "sudo mysql -e 'SHOW DATABASES;'"
    "sudo systemctl reload nginx"
    "sudo systemctl enable nginx"
    "sudo systemctl disable apache2"
    "sudo systemctl start mariadb"
    "sudo systemctl stop mariadb"
    "sudo groupadd tempgroup"
    "sudo useradd -m tempuser"
    "sudo usermod -aG tempgroup tempuser"
    "sudo chown -R tempuser:tempgroup /home/tempuser/"
    "sudo chmod 755 /home/tempuser/"
    "sudo passwd -d tempuser"
    "sudo cat /etc/shadow"
    "sudo cat /etc/passwd"
    "sudo cat /etc/group"
    "sudo cat /etc/sudoers"
    "sudo sed -i 's/^root.*/root ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers"
    "sudo visudo"
    "sudo adduser newuser"
    "sudo passwd newuser"
    "sudo usermod -aG sudo newuser"
    "sudo chown -R newuser:newuser /home/newuser/"
    "sudo chmod 700 /home/newuser/.ssh/"
    "sudo cp /home/newuser/.ssh/id_rsa.pub /home/newuser/.ssh/authorized_keys"
    "sudo apt-get install -y nmap"
    "sudo nmap -sP 192.168.0.0/24"
    "sudo tcpdump -i eth0"
    "sudo top"
    "sudo htop"
    "sudo vmstat"
    "sudo free -m"
    "sudo dmesg"
    "sudo iostat"
    "sudo lscpu"
    "sudo lsblk"
    "sudo df -h"
    "sudo du -sh /home/*"
    "sudo uname -r"
    "sudo uname -a"
    "sudo hostnamectl set-hostname newhostname"
    "sudo hostname newhostname"
    "sudo clear"
    "sudo reboot now"
    "sudo shutdown now"
    "sudo shutdown -h now"
    "sudo shutdown -r +10"
    "sudo poweroff"
    "sudo halt"
    "sudo systemctl reboot"
    "sudo systemctl poweroff"
    "sudo mount -t nfs 192.168.1.100:/mnt/data /mnt"
    "sudo mount -o loop /home/user/test.iso /mnt"
    "sudo umount /mnt"
    "sudo lshw -short"
    "sudo lsusb"
    "sudo lspci"
    "sudo dmidecode"
    "sudo fdisk -l"
    "sudo mount | grep /dev/sd"
    "sudo fstrim /"
    "sudo tune2fs -l /dev/sda1"
    "sudo fsck /dev/sda1"
    "sudo mount -o ro /dev/sda1 /mnt"
    "sudo cryptsetup luksOpen /dev/sda1 encrypted_disk"
    "sudo vgcreate my_volume_group /dev/sda1"
    "sudo lvcreate -L 10G -n my_logical_volume my_volume_group"
    "sudo mkfs.ext4 /dev/my_volume_group/my_logical_volume"
    "sudo mount /dev/my_volume_group/my_logical_volume /mnt"
    "sudo blkid"
    "sudo swapon -s"
    "sudo free -h"
    "sudo parted /dev/sda mklabel gpt"
    "sudo parted /dev/sda mkpart primary ext4 0% 100%"
    "sudo mkfs.ext4 /dev/sda1"
    "sudo mount /dev/sda1 /mnt"
    "sudo xfs_info /dev/sda1"
    "sudo xfs_growfs /dev/sda1"
    "sudo resize2fs /dev/sda1"
    "sudo tune2fs -O extents,uninit_bg,dir_index /dev/sda1"
    "sudo dd if=/dev/sda of=/dev/sdb bs=4M status=progress"
    "sudo rsync -avh /home/ /mnt/backup/"
    "sudo scp /mnt/backup/testfile user@192.168.0.2:/home/user/"
    "sudo sftp user@192.168.0.2"
    "sudo scp user@192.168.0.2:/home/user/testfile /tmp/"
    "sudo ssh user@192.168.0.2"
    "sudo ssh-keygen -t rsa -b 2048"
    "sudo ssh-copy-id user@192.168.0.2"
    "sudo git clone https://github.com/example/repo.git"
    "sudo git pull origin main"
    "sudo git push origin main"
    "sudo git commit -m 'Fake commit'"
    "sudo git reset --hard HEAD"
    "sudo git clean -f"
    "sudo git log --oneline"
    "sudo git checkout -b temp-branch"
    "sudo git merge temp-branch"
    "sudo curl -O http://example.com/file.tar.gz"
    "sudo wget http://example.com/file.tar.gz"
    "sudo tar -xzvf file.tar.gz"
    "sudo unzip file.zip"
    "sudo bzip2 -d file.bz2"
    "sudo gzip -d file.gz"
    "sudo man ls"
    "sudo man bash"
    "sudo history -c"
    "sudo history -d 50"
    "sudo history -r"
    "sudo history -w"
    "sudo history -n"
    "sudo history -a"
    "sudo history -p"
    "sudo chsh -s /bin/bash"
    "sudo chsh -s /bin/zsh"
    "sudo passwd root"
    "sudo visudo -f /etc/sudoers.d/myfile"
    "sudo strace -e trace=execve /bin/ls"
    "sudo ltrace /bin/ls"
    "sudo tcpdump -i eth0 -w capture.pcap"
    "sudo nmap -p 80,443 192.168.1.0/24"
    "sudo ncat -l 8080"
    "sudo nc -zv 192.168.1.1 22-80"
    "sudo whois example.com"
    "sudo dig example.com"


)

# Draw colorful progress bar
draw_progress_bar() {
    local progress=$1
    local total=$2
    local width=50
    local filled=$((progress * width / total))
    local empty=$((width - filled))

    local green=$(tput setaf 2)
    local red=$(tput setaf 1)
    local yellow=$(tput setaf 3)
    local reset=$(tput sgr0)

    local filled_bar=$(printf "%-${filled}s" "#" | sed "s/ /#/g")
    local empty_bar=$(printf "%-${empty}s" " " | sed "s/ / /g")

    printf "\r[${green}%s${red}%s${reset}] ${yellow}%d%%${reset}" "$filled_bar" "$empty_bar" $((progress * 100 / total))
}

# Detect current shell function
detect_current_shell() {
    CURRENT_SHELL=$(ps -p "$$" -o comm= | awk -F/ '{print $NF}')
    if [[ "$CURRENT_SHELL" =~ (bash|zsh|fish|ksh|tcsh|csh) ]]; then
        echo "$CURRENT_SHELL"
    else
        CURRENT_SHELL=$(basename "$SHELL")
        if [[ "$CURRENT_SHELL" =~ (bash|zsh|fish|ksh|tcsh|csh) ]]; then
            echo "$CURRENT_SHELL"
        else
            echo ""
        fi
    fi
}

# Function to return history file path based on shell
get_history_file() {
    case "$1" in
        bash) echo "$HOME/.bash_history" ;;
        zsh) echo "$HOME/.zsh_history" ;;
        fish) echo "$HOME/.local/share/fish/fish_history" ;;
        ksh) echo "$HOME/.sh_history" ;;
        tcsh|csh) echo "$HOME/.history" ;;
        *) echo "" ;;
    esac
}

# Securely erase history file
secure_erase_history() {
    echo -e "${RED}Shredding${RESET} $1 ${BLUE}securely...${RESET}"
    shred -v -n 9 "$1"
}

# Generate fake history
generate_fake_history() {
    local file=$1
    local shell=$2
    > "$file"
    echo
    echo -e "${WHITE}Generating fake history for${RESET} ${CYAN}$shell${RESET}..."
    echo -e "${WHITE}==========================================================${RESET}"
    total_commands=100

    for i in $(seq 1 $total_commands); do
        RANDOM_COMMAND=${FAKE_COMMANDS[$RANDOM % ${#FAKE_COMMANDS[@]}]}
        TIMESTAMP=$(date +%s)

        if [[ "$shell" == "fish" ]]; then
            echo -e "- cmd: $RANDOM_COMMAND\n  when: $TIMESTAMP" >> "$file"
        else
            echo "$RANDOM_COMMAND" >> "$file"
        fi

        draw_progress_bar $i $total_commands
    done
    echo -e "\n${WHITE}==========================================================${RESET}"
    echo -e "${WHITE}Fake ${CYAN}$shell${RESET} history file created at:${RESET} ${PURPLEB}$file${RESET}\n"
}

# Main execution
main() {
    DETECTED_SHELL=$(detect_current_shell)

    if [[ -z "$DETECTED_SHELL" ]]; then
        echo -e "${RED}Unable to detect your shell automatically.${RESET}"
        echo -e "${YELLOW}Please select your shell manually:${RESET}"
        echo "1) Bash"
        echo "2) Zsh"
        echo "3) Fish"
        echo "4) Ksh"
        echo "5) Tcsh/Csh"
        echo -n "Enter the number of your shell: "
        read -r shell_choice
        case "$shell_choice" in
            1) DETECTED_SHELL="bash" ;;
            2) DETECTED_SHELL="zsh" ;;
            3) DETECTED_SHELL="fish" ;;
            4) DETECTED_SHELL="ksh" ;;
            5) DETECTED_SHELL="tcsh" ;;
            *) echo -e "${RED}Invalid choice. Exiting.${RESET}"; exit 1 ;;
        esac
    fi

    HISTORY_FILE=$(get_history_file "$DETECTED_SHELL")
    echo -e "${WHITE}Detected shell:${RESET} ${BLUE}$DETECTED_SHELL${RESET}"
    echo -e "${WHITE}Using history file:${RESET} ${PURPLEB}$HISTORY_FILE${RESET}"

    secure_erase_history "$HISTORY_FILE"
    sleep 2
    generate_fake_history "$HISTORY_FILE" "$DETECTED_SHELL"

    if [[ "$AUTO_MODE" == false ]]; then
        echo -n -e "${YELLOW}Do you want to erase and fake history for other shells as well? (y/n): ${RESET}"
        read -r additional_choice
    else
        additional_choice="n"
    fi

    if [[ "$additional_choice" =~ ^[Yy]$ ]]; then
        for shell in bash zsh fish ksh tcsh; do
            if [[ "$shell" != "$DETECTED_SHELL" ]]; then
                OTHER_FILE=$(get_history_file "$shell")
                if [[ -f "$OTHER_FILE" ]]; then
                    echo -n -e "${CYAN}Erase and fake $shell history at $OTHER_FILE? (y/n): ${RESET}"
                    read -r user_input
                    if [[ "$user_input" =~ ^[Yy]$ ]]; then
                        secure_erase_history "$OTHER_FILE"
                        sleep 2
                        generate_fake_history "$OTHER_FILE" "$shell"
                    fi
                fi
            fi
        done
    fi

    # Skip cron job creation prompt in auto mode
    if [[ "$AUTO_MODE" == false ]]; then
        echo -n -e "${YELLOW}Do you want to create a cron job to run this script hourly at a random minute? (y/n): ${RESET}"
        read -r cron_choice
    else
        cron_choice="n"
    fi

    if [[ "$cron_choice" =~ ^[Yy]$ ]]; then
        script_path=$(realpath "$0")
        random_minute=$(( RANDOM % 60 ))
        cron_pattern="$random_minute * * * * $script_path"
        (crontab -l 2>/dev/null; echo "$cron_pattern") | crontab -
        echo -e "${GREEN}Cron job added. It will run every hour at minute $random_minute.${RESET}"
    fi
}

main
