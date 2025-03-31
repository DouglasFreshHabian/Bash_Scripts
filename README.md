![Header](https://github.com/DouglasFreshHabian/Bash_Scripts/blob/main/Graphics/Mr-Fresh-2-github-header-image.png?raw=true)
<h1 align="center"> 
  </h1>
<h1 align="center"> 
<a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.demolab.com?font=Merienda&size=35&duration=3500&pause=700&color=F7E707D7&center=true&vCenter=true&height=75&width=1300px&lines=I'm+a+Linux+Sysadmin💻;Internet+of+Things+Hacker📱;and+novice+security+researcher🕵️;;" alt="Typing SVG" /></a>

<h1 align="center"> 
📜 A Small Collection of Very Basic Bash Scripts 📜
</h1>

## Summary of each Bash Script

### AmdBugReport.sh
#### Script Summary:
This Bash script automates the process of gathering detailed system information for an AMD GPU setup. It collects basic configuration details, creates logs on system status, and performs in-depth analysis using commands like lshw, lspci, dmidecode, and more. It saves all collected data in a designated directory for future reference and troubleshooting.

### Lookup.sh
#### Script Summary:
This Bash script processes a log file to extract unique IP addresses, then performs geoiplookup and whois lookups for each address. It prints the results to the terminal and saves them to a file, while filtering and formatting the output for readability. It also checks for internet connectivity and handles errors, such as IP addresses with no information available. The script generates a detailed report, including any IP addresses that returned no data, and saves the results with a timestamped filename.

### PasswordGenerator.sh
#### Script Summary:
This Bash script generates multiple random passwords using OpenSSL. The user is prompted to specify the desired password length, and the script then generates and displays 10 passwords, each with the specified length, using base64-encoded random data.

### cheat.fish
#### Script Summary:
This Bash script provides shell autocompletion for the cheat command in the Fish shell. It defines auto-completion for various cheat command options like list, search, edit, and tags, enhancing the user's experience by suggesting valid arguments and options based on existing cheatsheets and available commands.

### pico_setup.sh
#### Script Summary:
This Bash script automates the setup of a Raspberry Pi development environment for programming the Raspberry Pi Pico. It installs dependencies, clones necessary Git repositories, and builds essential tools like the SDK, examples, picotool, picoprobe, and OpenOCD. It also configures the Raspberry Pi for UART usage and optionally installs Visual Studio Code with relevant extensions for development. The script handles all tasks, including dependency management and environment configuration, ensuring a smooth development setup.

### sysbenchtest.sh
#### Script Summary:
This Bash script runs a series of performance benchmarks using sysbench to test the CPU, file I/O, and memory performance of the system. It performs CPU stress tests with different thread configurations, evaluates file I/O with sequential write operations on a large file, and checks memory performance with a set memory block size. The script also cleans up the file I/O test data after completion.






<!-- 
 _____              _       _____                        _          
|  ___| __ ___  ___| |__   |  ___|__  _ __ ___ _ __  ___(_) ___ ___ 
| |_ | '__/ _ \/ __| '_ \  | |_ / _ \| '__/ _ \ '_ \/ __| |/ __/ __|
|  _|| | |  __/\__ \ | | | |  _| (_) | | |  __/ | | \__ \ | (__\__ \
|_|  |_|  \___||___/_| |_| |_|  \___/|_|  \___|_| |_|___/_|\___|___/
        dfresh@tutanota.com Fresh Forensics, LLC 2025 -->
