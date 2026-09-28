#!/usr/bin/env bash

# Fresh Forensics - GitHub Repository Privacy & Secret Audit
# Purpose: Search a Git repository for common credentials, private keys,
#          phone numbers, email addresses, token patterns, and sensitive filenames.

set -u

# -----------------------------
# Colors
# -----------------------------
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'

SCRIPT_NAME="$(basename "$0")"

# -----------------------------
# Helpers
# -----------------------------
banner() {
    clear
    printf "\n${CYAN}${BOLD}"
    printf "╔══════════════════════════════════════════════════════════════╗\n"
    printf "║              FRESH FORENSICS GIT AUDIT                     ║\n"
    printf "║        GitHub Privacy & Sensitive Data Scanner              ║\n"
    printf "╚══════════════════════════════════════════════════════════════╝\n"
    printf "${RESET}\n"
}

info() {
    printf "${BLUE}${BOLD}[INFO]${RESET} %s\n" "$1"
}

run_header() {
    printf "\n${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "${YELLOW}${BOLD}%s${RESET}\n" "$1"
    printf "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n\n"
}

warning() {
    printf "${YELLOW}${BOLD}[!]${RESET} %s\n" "$1"
}

success() {
    printf "${GREEN}${BOLD}[+]${RESET} %s\n" "$1"
}

error() {
    printf "${RED}${BOLD}[ERROR]${RESET} %s\n" "$1" >&2
}

pause_screen() {
    printf "\n${DIM}Press Enter to return to the menu...${RESET}"
    read -r
}

require_git_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        error "This script must be run from inside a Git repository."
        exit 1
    fi
}

history_commits() {
    git rev-list --all 2>/dev/null
}

show_menu() {
    banner

    printf "${WHITE}${BOLD}Repository:${RESET} "
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        printf "${RED}Not a Git repository${RESET}\n"
    fi

    printf "\n${WHITE}${BOLD}AUDIT OPTIONS${RESET}\n\n"

    printf "${CYAN}  1)${RESET} ${BOLD}10-Digit Numbers — Current Files${RESET}\n"
    printf "     Find possible unformatted 10-digit phone numbers in current files.\n\n"

    printf "${CYAN}  2)${RESET} ${BOLD}10-Digit Numbers — Git History${RESET}\n"
    printf "     Search every reachable commit for possible 10-digit phone numbers.\n\n"

    printf "${CYAN}  3)${RESET} ${BOLD}Credential Keywords — Current Files${RESET}\n"
    printf "     Find words such as password, secret, token, API key, and credential.\n\n"

    printf "${CYAN}  4)${RESET} ${BOLD}Credential Keywords — Git History${RESET}\n"
    printf "     Search historical commits for credential-related terms.\n\n"

    printf "${CYAN}  5)${RESET} ${BOLD}Private Keys — Git History${RESET}\n"
    printf "     Search historical commits for RSA, EC, OpenSSH, PGP, and similar keys.\n\n"

    printf "${CYAN}  6)${RESET} ${BOLD}Common API Token Patterns${RESET}\n"
    printf "     Look for common AWS, GitHub, Google, and API-key style patterns.\n\n"

    printf "${CYAN}  7)${RESET} ${BOLD}Sensitive Filenames — Git History${RESET}\n"
    printf "     Find historical files named like .env, credentials, secrets, keys, etc.\n\n"

    printf "${CYAN}  8)${RESET} ${BOLD}Email Addresses — Current Files${RESET}\n"
    printf "     Find email-address patterns currently present in the repository.\n\n"

    printf "${CYAN}  9)${RESET} ${BOLD}Gitleaks Secret Scan${RESET}\n"
    printf "     Run Gitleaks against the repository and Git history for known secret patterns.\n\n"

    printf "${CYAN}  A)${RESET} ${BOLD}Run ALL Checks${RESET}\n"
    printf "     Run the complete audit suite above.\n\n"

    printf "${CYAN}  0)${RESET} ${BOLD}Exit${RESET}\n\n"

    printf "${YELLOW}Select an option: ${RESET}"
}

check_history() {
    local count
    count="$(git rev-list --all 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$count" == "0" ]]; then
        warning "No commits were found in Git history."
        return 1
    fi
    info "Searching ${count} reachable commit(s)."
    return 0
}

scan_10_current() {
    run_header "10-DIGIT NUMBERS — CURRENT FILES"
    info "Searching current files for possible unformatted 10-digit phone numbers."
    printf "${DIM}Pattern: \\\\b[0-9]{10}\\\\b${RESET}\n\n"

    grep -RniE \
        '\b[0-9]{10}\b' \
        --exclude-dir=.git \
        . || true
}

scan_10_history() {
    run_header "10-DIGIT NUMBERS — GIT HISTORY"
    check_history || return

    info "Searching every reachable commit for possible 10-digit phone numbers."
    printf "\n"

    git grep -inE \
        '\b[0-9]{10}\b' \
        $(history_commits) 2>/dev/null || true
}

scan_credentials_current() {
    run_header "CREDENTIAL KEYWORDS — CURRENT FILES"
    info "Searching current files for credential-related terms."
    printf "${DIM}Terms: password, passwd, secret, api-key, token, credential${RESET}\n\n"

    grep -RniE \
        'password|passwd|secret|api[_-]?key|token|credential' \
        --exclude-dir=.git \
        . || true
}

scan_credentials_history() {
    run_header "CREDENTIAL KEYWORDS — GIT HISTORY"
    check_history || return

    info "Searching every reachable commit for credential-related terms."
    printf "\n"

    git grep -inE \
        'password|passwd|secret|api[_-]?key|token|credential' \
        $(history_commits) 2>/dev/null || true
}

scan_private_keys_history() {
    run_header "PRIVATE KEYS — GIT HISTORY"
    check_history || return

    info "Searching historical commits for private-key headers."
    printf "\n"

    git grep -inE \
        'BEGIN (RSA|DSA|EC|OPENSSH|PGP) PRIVATE KEY' \
        $(history_commits) 2>/dev/null || true
}

scan_api_tokens() {
    run_header "COMMON API TOKEN PATTERNS — CURRENT FILES"
    info "Searching for common AWS, GitHub, Google, and API-token patterns."
    warning "Pattern matches are not proof that a value is a valid or active credential."
    printf "\n"

    grep -RniE \
        'AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]+|AIza[0-9A-Za-z_-]{35}|sk-[A-Za-z0-9_-]+' \
        --exclude-dir=.git \
        . || true
}

scan_sensitive_filenames() {
    run_header "SENSITIVE FILENAMES — GIT HISTORY"
    info "Searching Git history for potentially sensitive filenames."
    printf "\n"

    git log --all --name-only --pretty=format: 2>/dev/null |
        sort -u |
        grep -Ei \
        '(\.env|\.pem|\.key|\.p12|\.pfx|credential|password|secret|config)' || true
}

scan_emails_current() {
    run_header "EMAIL ADDRESSES — CURRENT FILES"
    info "Searching current files for email-address patterns."
    printf "\n"

    grep -RniE \
        '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' \
        --exclude-dir=.git \
        . || true
}

scan_gitleaks() {
    run_header "GITLEAKS SECRET SCAN"
    if ! command -v gitleaks >/dev/null 2>&1; then
        error "Gitleaks is not installed or is not in PATH."
        printf "Install it, then run this option again.\n"
        return
    fi

    info "Running Gitleaks with redaction and all Git refs."
    printf "\n"

    gitleaks detect \
        --source . \
        --log-opts="--all" \
        --redact \
        --verbose
}

run_all() {
    scan_10_current
    scan_10_history
    scan_credentials_current
    scan_credentials_history
    scan_private_keys_history
    scan_api_tokens
    scan_sensitive_filenames
    scan_emails_current
    scan_gitleaks

    printf "\n${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    success "Complete audit finished."
    printf "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

# -----------------------------
# Main
# -----------------------------
require_git_repo

case "${1:-}" in
    1) scan_10_current ;;
    2) scan_10_history ;;
    3) scan_credentials_current ;;
    4) scan_credentials_history ;;
    5) scan_private_keys_history ;;
    6) scan_api_tokens ;;
    7) scan_sensitive_filenames ;;
    8) scan_emails_current ;;
    9) scan_gitleaks ;;
    a|A) run_all ;;
    -h|--help|"")
        while true; do
            show_menu
            read -r choice
            case "$choice" in
                1) scan_10_current; pause_screen ;;
                2) scan_10_history; pause_screen ;;
                3) scan_credentials_current; pause_screen ;;
                4) scan_credentials_history; pause_screen ;;
                5) scan_private_keys_history; pause_screen ;;
                6) scan_api_tokens; pause_screen ;;
                7) scan_sensitive_filenames; pause_screen ;;
                8) scan_emails_current; pause_screen ;;
                9) scan_gitleaks; pause_screen ;;
                a|A) run_all; pause_screen ;;
                0) printf "\n${GREEN}Exiting. Stay secure.${RESET}\n"; exit 0 ;;
                *) warning "Invalid option."; sleep 1 ;;
            esac
        done
        ;;
    *)
        error "Unknown option: $1"
        printf "Run ${BOLD}%s --help${RESET} to open the audit menu.\n" "$SCRIPT_NAME"
        exit 1
        ;;
esac
