#!/usr/bin/env bash

# ============================================================
# play.sh - Video Forensics / Analysis Toolkit
# ============================================================

# ---------- Colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
RESET='\033[0m'

# ---------- Paths / Configuration ----------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
YTDLP_LOCAL="${SCRIPT_DIR}/yt-dlp_linux"
YTDLP_SYSTEM="/usr/local/bin/yt-dlp"
YTDLP_URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux"

# ============================================================
# Display Helpers
# ============================================================

header() {
    clear
    echo -e "${CYAN}"
    echo "============================================================"
    echo "                    VIDEO TOOLKIT"
    echo "============================================================"
    echo -e "${RESET}"
}

pause_menu() {
    echo
    read -rp "Press ENTER to continue..."
}

# ============================================================
# Help
# ============================================================

show_help() {
    header

    echo -e "${WHITE}Usage:${RESET}"
    echo
    echo "  $0"
    echo "      Open the video toolkit menu."
    echo
    echo "  $0 <video_file>"
    echo "      Open the video toolkit for a specific video."
    echo
    echo "  $0 --yt-dlp"
    echo "  $0 -y"
    echo "      Open the yt-dlp toolkit."
    echo
    echo "  $0 --help"
    echo "  $0 -h"
    echo "      Show this help menu."
    echo

    echo -e "${WHITE}Video Toolkit:${RESET}"
    echo
    echo -e "  ${CYAN}1${RESET}) Play video"
    echo -e "  ${CYAN}2${RESET}) Convert video to MP4"
    echo -e "  ${CYAN}3${RESET}) Extract video frames"
    echo -e "  ${CYAN}4${RESET}) Extract audio as MP3"
    echo -e "  ${CYAN}5${RESET}) Rotate video 90 degrees"
    echo -e "  ${CYAN}6${RESET}) Show video information"
    echo -e "  ${CYAN}7${RESET}) yt-dlp tools"
    echo -e "  ${CYAN}8${RESET}) Exit"
    echo

    echo -e "${WHITE}yt-dlp Toolkit:${RESET}"
    echo
    echo -e "  ${CYAN}1${RESET}) List available video/audio formats"
    echo -e "  ${CYAN}2${RESET}) List available subtitles/captions"
    echo -e "  ${CYAN}3${RESET}) Download English auto-generated subtitles"
    echo -e "  ${CYAN}4${RESET}) Download latest yt-dlp Linux binary"
    echo -e "  ${CYAN}5${RESET}) Install yt-dlp to /usr/local/bin/"
    echo -e "  ${CYAN}6${RESET}) Show installed yt-dlp version"
    echo -e "  ${CYAN}7${RESET}) Return"
    echo

    echo -e "${WHITE}Dependencies:${RESET}"
    echo
    echo "  Video toolkit:"
    echo "    ffmpeg"
    echo "    ffplay"
    echo "    ffprobe"
    echo
    echo "  yt-dlp download:"
    echo "    curl or wget"
    echo

    echo -e "${WHITE}Examples:${RESET}"
    echo
    echo "  $0"
    echo "  $0 evidence.mp4"
    echo "  $0 recording.webm"
    echo "  $0 --yt-dlp"
    echo "  $0 --help"
    echo
}

# ============================================================
# Dependency Checks
# ============================================================

check_video_dependencies() {
    local cmd

    for cmd in ffmpeg ffplay ffprobe; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${RED}[ERROR]${RESET} $cmd is not installed."
            return 1
        fi
    done

    return 0
}

# ============================================================
# yt-dlp Functions
# ============================================================

find_ytdlp() {
    if [[ -x "$YTDLP_LOCAL" ]]; then
        printf '%s\n' "$YTDLP_LOCAL"
        return 0
    fi

    if [[ -x "$YTDLP_SYSTEM" ]]; then
        printf '%s\n' "$YTDLP_SYSTEM"
        return 0
    fi

    if command -v yt-dlp >/dev/null 2>&1; then
        command -v yt-dlp
        return 0
    fi

    return 1
}

download_ytdlp() {
    local temp_file

    echo -e "${GREEN}[+] Downloading latest yt-dlp Linux binary...${RESET}"
    echo
    echo -e "    Source: ${CYAN}${YTDLP_URL}${RESET}"
    echo

    temp_file="$(mktemp "${TMPDIR:-/tmp}/yt-dlp_linux.XXXXXX")" || {
        echo -e "${RED}[!] Could not create temporary file.${RESET}"
        return 1
    }

    if command -v curl >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Using curl...${RESET}"
        if ! curl -fL --progress-bar "$YTDLP_URL" -o "$temp_file"; then
            echo -e "${RED}[!] Failed to download yt-dlp.${RESET}"
            rm -f "$temp_file"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Using wget...${RESET}"
        if ! wget --show-progress "$YTDLP_URL" -O "$temp_file"; then
            echo -e "${RED}[!] Failed to download yt-dlp.${RESET}"
            rm -f "$temp_file"
            return 1
        fi
    else
        echo -e "${RED}[ERROR] Neither curl nor wget is installed.${RESET}"
        rm -f "$temp_file"
        return 1
    fi

    chmod +x "$temp_file"

    if [[ ! -x "$temp_file" ]]; then
        echo -e "${RED}[!] Downloaded file could not be made executable.${RESET}"
        rm -f "$temp_file"
        return 1
    fi

    if ! mv -f "$temp_file" "$YTDLP_LOCAL"; then
        echo -e "${RED}[!] Could not move yt-dlp into:${RESET} $YTDLP_LOCAL"
        rm -f "$temp_file"
        return 1
    fi

    echo
    echo -e "${GREEN}[+] yt-dlp downloaded successfully.${RESET}"
    echo -e "    Location: ${CYAN}${YTDLP_LOCAL}${RESET}"
    echo -e "    Version:  ${CYAN}$("$YTDLP_LOCAL" --version)${RESET}"

    return 0
}

ensure_ytdlp() {
    local ytdlp

    ytdlp="$(find_ytdlp)" || true

    if [[ -n "$ytdlp" ]]; then
        printf '%s\n' "$ytdlp"
        return 0
    fi

    echo -e "${YELLOW}[!] yt-dlp is not installed.${RESET}" >&2
    echo >&2
    read -rp "Download the latest Linux binary now? [Y/n]: " download

    if [[ "$download" =~ ^[Nn]$ ]]; then
        return 1
    fi

    if download_ytdlp >&2; then
        printf '%s\n' "$YTDLP_LOCAL"
        return 0
    fi

    return 1
}

install_ytdlp_systemwide() {
    local ytdlp

    echo -e "${GREEN}[+] Installing yt-dlp system-wide...${RESET}"
    echo -e "    Destination: ${CYAN}${YTDLP_SYSTEM}${RESET}"
    echo

    ytdlp="$(find_ytdlp)" || true

    if [[ -z "$ytdlp" ]]; then
        echo -e "${YELLOW}[!] yt-dlp is not currently installed.${RESET}"
        read -rp "Download the latest binary first? [Y/n]: " download_first

        if [[ "$download_first" =~ ^[Nn]$ ]]; then
            echo -e "${YELLOW}[!] Installation cancelled.${RESET}"
            return 1
        fi

        if ! download_ytdlp; then
            return 1
        fi

        ytdlp="$YTDLP_LOCAL"
    fi

    echo
    echo -e "${YELLOW}[!] sudo privileges are required.${RESET}"
    echo

    if sudo install -m 0755 "$ytdlp" "$YTDLP_SYSTEM"; then
        echo
        echo -e "${GREEN}[+] yt-dlp installed successfully.${RESET}"
        echo -e "    Location: ${CYAN}${YTDLP_SYSTEM}${RESET}"
        echo -e "    Version:  ${CYAN}$("$YTDLP_SYSTEM" --version)${RESET}"
        return 0
    fi

    echo -e "${RED}[!] Failed to install yt-dlp system-wide.${RESET}"
    return 1
}

# ============================================================
# yt-dlp Menu
# ============================================================

ytdlp_menu() {
    while true; do
        clear

        echo -e "${CYAN}"
        echo "============================================================"
        echo "                       yt-dlp TOOLS"
        echo "============================================================"
        echo -e "${RESET}"

        echo -e "  ${CYAN}1${RESET}) List available video/audio formats"
        echo -e "  ${CYAN}2${RESET}) List available subtitles/captions"
        echo -e "  ${CYAN}3${RESET}) Download English auto-generated subtitles"
        echo -e "  ${CYAN}4${RESET}) Download latest yt-dlp Linux binary"
        echo -e "  ${CYAN}5${RESET}) Install yt-dlp to /usr/local/bin/"
        echo -e "  ${CYAN}6${RESET}) Show installed yt-dlp version"
        echo -e "  ${CYAN}7${RESET}) Return"
        echo
        echo -e "${YELLOW}------------------------------------------------------------${RESET}"

        read -rp "Choose an option [1-7]: " choice
        echo

        case "$choice" in
            1)
                local ytdlp url
                ytdlp="$(ensure_ytdlp)" || {
                    pause_menu
                    continue
                }

                read -rp "Enter video URL: " url

                if [[ -z "$url" ]]; then
                    echo -e "${RED}[!] No URL provided.${RESET}"
                    pause_menu
                    continue
                fi

                echo
                echo -e "${GREEN}[+] Available formats:${RESET}"
                echo
                "$ytdlp" -F "$url"
                pause_menu
                ;;

            2)
                local ytdlp url
                ytdlp="$(ensure_ytdlp)" || {
                    pause_menu
                    continue
                }

                read -rp "Enter video URL: " url

                if [[ -z "$url" ]]; then
                    echo -e "${RED}[!] No URL provided.${RESET}"
                    pause_menu
                    continue
                fi

                echo
                echo -e "${GREEN}[+] Available subtitles/captions:${RESET}"
                echo
                "$ytdlp" --list-subs "$url"
                pause_menu
                ;;

            3)
                local ytdlp url
                ytdlp="$(ensure_ytdlp)" || {
                    pause_menu
                    continue
                }

                read -rp "Enter video URL: " url

                if [[ -z "$url" ]]; then
                    echo -e "${RED}[!] No URL provided.${RESET}"
                    pause_menu
                    continue
                fi

                echo
                echo -e "${GREEN}[+] Downloading English auto-generated subtitles...${RESET}"
                echo

                if "$ytdlp" \
                    --write-auto-subs \
                    --sub-langs "en" \
                    --convert-subs srt \
                    "$url"; then
                    echo
                    echo -e "${GREEN}[+] Subtitle download complete.${RESET}"
                else
                    echo
                    echo -e "${RED}[!] Subtitle download failed.${RESET}"
                fi

                pause_menu
                ;;

            4)
                download_ytdlp
                pause_menu
                ;;

            5)
                install_ytdlp_systemwide
                pause_menu
                ;;

            6)
                local ytdlp
                ytdlp="$(find_ytdlp)" || true

                if [[ -z "$ytdlp" ]]; then
                    echo -e "${YELLOW}[!] yt-dlp is not currently installed.${RESET}"
                else
                    echo -e "${GREEN}[+] yt-dlp executable:${RESET}"
                    echo -e "    ${CYAN}${ytdlp}${RESET}"
                    echo
                    echo -e "${GREEN}[+] Version:${RESET}"
                    "$ytdlp" --version
                fi

                pause_menu
                ;;

            7)
                return
                ;;

            *)
                echo -e "${RED}[!] Invalid selection.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# Video Toolkit
# ============================================================

video_toolkit() {
    local video="$1"
    local filename name extension

    if [[ ! -f "$video" ]]; then
        echo -e "${RED}[ERROR]${RESET} File not found: $video"
        return 1
    fi

    if ! check_video_dependencies; then
        return 1
    fi

    filename="$(basename "$video")"
    name="${filename%.*}"
    extension="${filename##*.}"

    while true; do
        header

        echo -e "${GREEN}Input:${RESET}     $filename"
        echo -e "${GREEN}Format:${RESET}    $extension"
        echo

        echo -e "${YELLOW}------------------------------------------------------------${RESET}"
        echo -e "${WHITE}Select an operation:${RESET}"
        echo
        echo -e "  ${CYAN}1${RESET}) Play video"
        echo -e "  ${CYAN}2${RESET}) Convert video to MP4"
        echo -e "  ${CYAN}3${RESET}) Extract video frames"
        echo -e "  ${CYAN}4${RESET}) Extract audio as MP3"
        echo -e "  ${CYAN}5${RESET}) Rotate video 90 degrees"
        echo -e "  ${CYAN}6${RESET}) Show video information"
        echo -e "  ${CYAN}7${RESET}) yt-dlp tools"
        echo -e "  ${CYAN}8${RESET}) Exit"
        echo
        echo -e "${YELLOW}------------------------------------------------------------${RESET}"

        read -rp "Choose an option [1-8]: " choice
        echo

        case "$choice" in
            1)
                echo -e "${GREEN}[+] Playing:${RESET} $video"
                echo
                ffplay "$video"
                pause_menu
                ;;

            2)
                local output="${name}.mp4"

                echo -e "${GREEN}[+] Converting:${RESET}"
                echo -e "    $video ${CYAN}->${RESET} $output"
                echo

                if [[ -e "$output" ]]; then
                    read -rp "$output already exists. Overwrite? [y/N]: " confirm
                    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                        echo -e "${YELLOW}[!] Conversion cancelled.${RESET}"
                        pause_menu
                        continue
                    fi
                fi

                if ffmpeg -i "$video" -vcodec mpeg4 "$output"; then
                    echo
                    echo -e "${GREEN}[+] Conversion complete:${RESET} $output"
                else
                    echo
                    echo -e "${RED}[!] Conversion failed.${RESET}"
                fi

                pause_menu
                ;;

            3)
                local frame_dir="${name}_frames"
                local frame_count

                echo -e "${GREEN}[+] Frame extraction${RESET}"
                echo
                echo "This will extract 10 frames per second."
                echo
                echo -e "Frames will be stored in:"
                echo -e "  ${CYAN}${frame_dir}/${RESET}"
                echo

                if [[ -d "$frame_dir" ]]; then
                    echo -e "${YELLOW}[!] Directory already exists:${RESET} $frame_dir"
                    read -rp "Use this directory? [Y/n]: " use_existing

                    if [[ "$use_existing" =~ ^[Nn]$ ]]; then
                        echo -e "${YELLOW}[!] Frame extraction cancelled.${RESET}"
                        pause_menu
                        continue
                    fi
                else
                    read -rp "Create this directory? [Y/n]: " create_dir

                    if [[ "$create_dir" =~ ^[Nn]$ ]]; then
                        echo -e "${YELLOW}[!] Frame extraction cancelled.${RESET}"
                        pause_menu
                        continue
                    fi

                    mkdir -p "$frame_dir" || {
                        echo -e "${RED}[!] Could not create directory.${RESET}"
                        pause_menu
                        continue
                    }
                fi

                echo
                echo -e "${GREEN}[+] Extracting frames...${RESET}"
                echo

                if ffmpeg -y \
                    -i "$video" \
                    -map 0:v:0 \
                    -an \
                    -vf fps=10 \
                    "$frame_dir/img%06d.bmp"; then

                    frame_count="$(find "$frame_dir" -type f -name '*.bmp' | wc -l)"

                    echo
                    echo -e "${GREEN}[+] Frame extraction complete.${RESET}"
                    echo -e "    Frames created: ${WHITE}${frame_count}${RESET}"
                    echo -e "    Location: ${CYAN}${frame_dir}/${RESET}"
                else
                    echo
                    echo -e "${RED}[!] Frame extraction failed.${RESET}"
                fi

                pause_menu
                ;;

            4)
                local output="${name}.mp3"

                echo -e "${GREEN}[+] Extracting audio:${RESET}"
                echo -e "    $video ${CYAN}->${RESET} $output"
                echo

                if [[ -e "$output" ]]; then
                    read -rp "$output already exists. Overwrite? [y/N]: " confirm
                    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                        echo -e "${YELLOW}[!] Audio extraction cancelled.${RESET}"
                        pause_menu
                        continue
                    fi
                fi

                if ffmpeg -i "$video" \
                    -vn \
                    -ac 2 \
                    -ar 44100 \
                    -b:a 320k \
                    -f mp3 \
                    "$output"; then
                    echo
                    echo -e "${GREEN}[+] Audio extraction complete:${RESET} $output"
                else
                    echo
                    echo -e "${RED}[!] Audio extraction failed.${RESET}"
                fi

                pause_menu
                ;;

            5)
                local output="${name}_rotated.mp4"

                echo -e "${GREEN}[+] Rotating video 90 degrees:${RESET}"
                echo -e "    $video ${CYAN}->${RESET} $output"
                echo

                if [[ -e "$output" ]]; then
                    read -rp "$output already exists. Overwrite? [y/N]: " confirm
                    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                        echo -e "${YELLOW}[!] Rotation cancelled.${RESET}"
                        pause_menu
                        continue
                    fi
                fi

                if ffmpeg -i "$video" -vf transpose=0 "$output"; then
                    echo
                    echo -e "${GREEN}[+] Rotation complete:${RESET} $output"
                else
                    echo
                    echo -e "${RED}[!] Rotation failed.${RESET}"
                fi

                pause_menu
                ;;

            6)
                echo -e "${GREEN}[+] Video information${RESET}"
                echo
                ffprobe "$video"
                pause_menu
                ;;

            7)
                ytdlp_menu
                ;;

            8)
                echo -e "${CYAN}Exiting video toolkit.${RESET}"
                return 0
                ;;

            *)
                echo -e "${RED}[!] Invalid selection.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# Program Entry Point
# ============================================================

case "${1:-}" in
    -h|--help|help)
        show_help
        ;;

    -y|--yt-dlp)
        ytdlp_menu
        ;;

    "")
        # No argument now behaves like --help.
        show_help
        ;;

    -*)
        echo -e "${RED}[ERROR]${RESET} Unknown option: $1"
        echo
        echo "Run:"
        echo "  $0 --help"
        exit 1
        ;;

    *)
        if [[ $# -ne 1 ]]; then
            echo -e "${RED}[ERROR]${RESET} Too many arguments."
            echo
            echo "Run:"
            echo "  $0 --help"
            exit 1
        fi

        video_toolkit "$1"
        ;;
esac
