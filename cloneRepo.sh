#!/bin/bash

# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}jq not found. Please install it with: apt install jq"
    exit 1
fi

# Check for --all or -a flag
AUTO_CLONE=false
if [[ "$1" == "--all" || "$1" == "-a" ]]; then
    AUTO_CLONE=true
    shift
fi

# Function to check if HTTP response code is 200 (repo exists)
check_repo_exists() {
    local url="$1"
    response=$(curl --write-out "%{http_code}" --silent --output /dev/null "$url")
    if [[ "$response" -eq 200 ]]; then
        echo -e "${GREEN}Repository exists: ${url}${NC}"
        return 0
    else
        echo -e "${RED}Repository does not exist: ${url}${NC}"
        return 1
    fi
}

# Function to clone the repository
clone_repo() {
    echo -e "${WHITE}"
    git clone "$1"
    echo -e "${NC}"
}

# Prompt for GitHub username
echo -e "${WHITE}"
read -p "Enter the GitHub username (e.g., DouglasFreshHabian): " username
echo -e "${NC}"

# Validate that the username exists by checking the profile URL
profile_url="https://github.com/$username"
if ! check_repo_exists "$profile_url"; then
    exit 1
fi

# GitHub API URL to fetch the list of repositories owned by the user
api_url="https://api.github.com/users/$username/repos?type=owner&per_page=100"

echo -e "${BLUE}Fetching repositories under the username: $username...${NC}"

# Fetch the repositories using GitHub API and store the response
api_response=$(curl -s "$api_url")

# Check if the response is valid JSON and not empty
if [[ -z "$api_response" ]]; then
    echo -e "${RED}Error: Failed to fetch repositories. Please check the username and try again.${NC}"
    exit 1
fi

# Validate JSON
echo "$api_response" | jq . > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: The API response is not valid JSON.${NC}"
    echo "$api_response"
    exit 1
fi

# Extract the clone URLs
repos=$(echo "$api_response" | jq -r '.[].clone_url')

# Check if any repositories were found
if [[ -z "$repos" ]]; then
    echo -e "${YELLOW}No repositories found under: $username${NC}"
    exit 0
fi

# Loop through each repository
for repo in $repos; do
    echo -e "${BLUE}Found repository: $repo${NC}"
    if $AUTO_CLONE; then
        echo -e "${GREEN}Auto-cloning ${repo}...${NC}"
        clone_repo "$repo"
    else
        read -p "Do you want to clone this repository? (Y/N, default Y): " response
        response=${response:-Y}
        case $response in
            [Yy]* ) 
                echo -e "${GREEN}Cloning ${repo}...${NC}"
                clone_repo "$repo"
                ;;
            [Nn]* ) 
                echo -e "${YELLOW}Skipping ${repo}${NC}"
                ;;
            * ) 
                echo -e "${RED}Invalid input, skipping...${NC}"
                ;;
        esac
    fi
done

echo -e "${GREEN}All done!${NC}"
