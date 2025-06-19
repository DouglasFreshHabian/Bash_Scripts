![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Size](https://img.shields.io/github/repo-size/DouglasFreshHabian/Bash_Scripts)
![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen.svg)
![Shell Script](https://img.shields.io/badge/Bash-Bash_Scripts-yellow.svg)
![Using Linux](https://img.shields.io/badge/Using-Linux-purple.svg)
![Status: Stable](https://img.shields.io/badge/Status-Stable-brightgreen.svg)
![Kali Linux](https://img.shields.io/badge/Tested-Kali%20Linux-153f86?logo=kalilinux&logoColor=blue&colorA=white)

![Header](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/Graphics/Mr-Fresh-2-github-header-image.png?raw=true)
<h1 align="center"> 
  </h1>
<h1 align="center"> 
<a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.demolab.com?font=Fira+Code&pause=1000&color=F77D00&width=435&lines=Im+a+Linux+Sysadmin+%F0%9F%92%BB;Internet+of+Things+Hacker+%F0%9F%93%B1;%26+Novice+Security+Researcher+%F0%9F%95%B5%EF%B8%8F" alt="Typing SVG" /></a>
<h1 align="center"> 
📜 A Small Collection of Very Basic Bash Scripts 📜
</h1>

## Summary of each Bash Script:

### 🐛 [AmdBugReport.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/AmdBugReport.sh)
#### Script Summary:
This Bash script automates the process of gathering detailed system information for an AMD GPU setup. It collects basic configuration details, creates logs on system status, and performs in-depth analysis using commands like `lshw`, `lspci`, `dmidecode`, and more. It saves all collected data in a designated directory for future reference and troubleshooting.

### 🔭 [Lookup.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/Lookup.sh)
#### Script Summary:
This Bash script processes a log file to extract unique IP addresses, then performs geoiplookup and whois lookups for each address. It prints the results to the terminal and saves them to a file, while filtering and formatting the output for readability. It also checks for internet connectivity and handles errors, such as IP addresses with no information available. The script generates a detailed report, including any IP addresses that returned no data, and saves the results with a timestamped filename.

### 🔑 [passwordGenerator.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/passwordGenerator.sh)
#### Script Summary:
This Bash script generates multiple random passwords using OpenSSL. The user is prompted to specify the desired password length, and the script then generates and displays 10 passwords, each with the specified length, using base64-encoded random data.

### 🐠 [cheat.fish](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/cheat.fish)
#### Script Summary:
This Bash script provides shell autocompletion for the `cheat` command in the Fish shell. It defines auto-completion for various cheat command options like list, search, edit, and tags, enhancing the user's experience by suggesting valid arguments and options based on existing cheatsheets and available commands.

### ⛏ [pico_setup.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/pico_setup.sh)
#### Script Summary:
This Bash script automates the setup of a Raspberry Pi development environment for programming the Raspberry Pi Pico. It installs dependencies, clones necessary Git repositories, and builds essential tools like the SDK, examples, picotool, picoprobe, and OpenOCD. It also configures the Raspberry Pi for UART usage and optionally installs Visual Studio Code with relevant extensions for development. The script handles all tasks, including dependency management and environment configuration, ensuring a smooth development setup.

### ⚙️ [sysbenchtest.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/sysbenchtest.sh)
#### Script Summary:
This Bash script runs a series of performance benchmarks using sysbench to test the CPU, file I/O, and memory performance of the system. It performs CPU stress tests with different thread configurations, evaluates file I/O with sequential write operations on a large file, and checks memory performance with a set memory block size. The script also cleans up the file I/O test data after completion.

### 🚶‍[firmwalker.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/firmwalker.sh)
#### Script Summary:
A simple bash  script for searching the extracted or mounted firmware file system.

It will search through the extracted or mounted firmware file system for things of interest such as:

* etc/shadow and etc/passwd
* list out the etc/ssl directory
* search for SSL related files such as .pem, .crt, etc.
* search for configuration files
* look for script files
* search for other .bin files
* look for keywords such as admin, password, remote, etc.
* search for common web servers used on IoT devices
* search for common binaries such as ssh, tftp, dropbear, etc.
* search for URLs, email addresses and IP addresses
* Experimental support for making calls to the Shodan API using the Shodan CLI

### 📛 [hostname.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/hostname.sh)
#### Script Summary:
A Bash script that offers many different ways to change the hostname of a linux machine including:

* randomnly using a built in random name generator
* manually by providing a hostname
* using included wordlists

### 🏴 [banner.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/banner.sh)
#### Script Summary:
Randomly produce a different colored banner each time you run it. Replace the banner and enjoy. Great for use inside of other scripts.

### 🌐 [encrypt.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/encrypt.sh)
#### Script Summary:
A simple bash script that can both encrypt and decrypt a file using gpg.

### 🤵 [freshcrypt.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/freshscrypt.sh)
#### Script Summary:
A simple bash script based off of `encrypt.sh` that encrypts or decrypts a file on the command line using gpg with added details including ascii art.

### 🔥 [freshpassword.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/freshpassword.sh)
#### Script Summary:
A simple bash script based off of `passwordGenerator.sh` that allows you to set not only the number of characters in each password but also the number of passwords
generated. As with all `fresh` scripts, it includes custom ascii art...

### 🚀 [freshsh33t.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/freshsh33t.sh)
#### Script Summary:
This is a Bash script designed to manage personal cheat sheets in the cheat command-line utility. It allows users to copy, remove, verify the path, or view an ASCII banner for their cheat sheets. The script includes fun features like color-coded output and lolcat-generated messages.

### 💣 [freshmac.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/freshmac.sh)
#### Script Summary:
A Simple Bash Script that lists interfaces, brings down the interface of choosing, changes its mac address, removes any blocks and brings the interface back up.

### ⚕ [networkHealthCheck.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/networkHealthCheck.sh)
#### Script Summary:
The script performs a network health check by testing connectivity, DNS resolution, and bandwidth usage, while displaying the results with colored output and a random ASCII banner.

### 🌀 [cloneRepo](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/cloneRepo.sh)
#### Script Summary:
This script allows you to interactively browse and selectively clone public repositories from any GitHub user by leveraging the GitHub REST API and jq.

## 📡 [udevMagic](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/udevMagic.sh)
#### Script Summary:
A script to easily rename external network adapters by creating and managing Udev rules based on MAC addresses.

## 🧹 [historyCleaner.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/historyCleaner.sh)
#### Script Summary:
A unified, powerful script to securely erase your shell history and replace it with realistic fake entries.
Supports Bash, Zsh, Fish, Ksh, and Tcsh automatically. Includes randomized cronjob support for ongoing protection!

## 🛠 [installTools.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/installTools.sh)
#### Script Summary:
A simple Bash script with colorization that attempts to install every single tool inside of the `TOOLS` array. Add tools to the array
or remove tools from the array.

## 🔌 [io-ng.sh](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/io-ng.sh)
#### Script Summary:
A simple Bash script that monitors USB device connections in real-time, displaying color-coded vendor and product IDs.

>**💡Remember:**
> Make each script executable with `chmod +x`

## Interested In More Bash? Check out my Bash Equalizer called [BashBeats](https://github.com/DouglasFreshHabian/BashBeats.git)
[![asciicast](https://asciinema.org/a/717434.svg)](https://asciinema.org/a/717434)

<!-- Someone has been coming into my github repo and even viewed my recovery codes. I have been seeing small changes being made on my pages, since I have the originals. Please stop. If you catch you, you will be in trouble. Nobody is above the law -->

<!-- 
 _____              _       _____                        _          
|  ___| __ ___  ___| |__   |  ___|__  _ __ ___ _ __  ___(_) ___ ___ 
| |_ | '__/ _ \/ __| '_ \  | |_ / _ \| '__/ _ \ '_ \/ __| |/ __/ __|
|  _|| | |  __/\__ \ | | | |  _| (_) | | |  __/ | | \__ \ | (__\__ \
|_|  |_|  \___||___/_| |_| |_|  \___/|_|  \___|_| |_|___/_|\___|___/
        dfresh@tutanota.com Fresh Forensics, LLC 2025 -->
