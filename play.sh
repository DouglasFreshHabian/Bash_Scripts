#!/usr/bin/env bash

# ============================================================
# play.sh - Simple Video Forensics / Analysis Menu
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

# ---------- Banner ----------
clear

echo -e "${CYAN}"
echo "============================================================"
echo "                    VIDEO TOOLKIT"
echo "============================================================"
echo -e "${RESET}"

# ---------- Check argument ----------
if [[ $# -ne 1 ]]; then
    echo -e "${RED}Usage:${RESET} $0 <video_file>"
    echo
    echo "Examples:"
    echo "  $0 video.webm"
    echo "  $0 evidence.mpg"
    echo "  $0 recording.mp4"
    exit 1
fi

VIDEO="$1"

# ---------- Check file ----------
if [[ ! -f "$VIDEO" ]]; then
    echo -e "${RED}[ERROR]${RESET} File not found: $VIDEO"
    exit 1
fi

# ---------- Check dependencies ----------
for CMD in ffmpeg ffplay; do
    if ! command -v "$CMD" >/dev/null 2>&1; then
        echo -e "${RED}[ERROR]${RESET} $CMD is not installed."
        exit 1
    fi
done

# ---------- File information ----------
FILENAME=$(basename "$VIDEO")
NAME="${FILENAME%.*}"
EXTENSION="${FILENAME##*.}"

echo -e "${GREEN}Input:${RESET}     $FILENAME"
echo -e "${GREEN}Format:${RESET}    $EXTENSION"
echo

# ---------- Menu ----------
while true; do

    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
    echo -e "${WHITE}Select an operation:${RESET}"
    echo
    echo -e "  ${CYAN}1${RESET}) Play video"
    echo -e "  ${CYAN}2${RESET}) Convert video to MP4"
    echo -e "  ${CYAN}3${RESET}) Extract video frames"
    echo -e "  ${CYAN}4${RESET}) Extract audio as MP3"
    echo -e "  ${CYAN}5${RESET}) Rotate video 90 degrees"
    echo -e "  ${CYAN}6${RESET}) Show video information"
    echo -e "  ${CYAN}7${RESET}) Exit"
    echo
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"

    read -rp "Choose an option [1-7]: " CHOICE
    echo

    case "$CHOICE" in

        # ----------------------------------------------------
        # Play video
        # ----------------------------------------------------
        1)
            echo -e "${GREEN}[+] Playing:${RESET} $VIDEO"
            echo

            ffplay "$VIDEO"

            echo
            read -rp "Press ENTER to return to the menu..."
            clear
            ;;

        # ----------------------------------------------------
        # Convert to MP4
        # ----------------------------------------------------
        2)
            OUTPUT="${NAME}.mp4"

            echo -e "${GREEN}[+] Converting:${RESET}"
            echo -e "    $VIDEO ${CYAN}->${RESET} $OUTPUT"
            echo

            if [[ -e "$OUTPUT" ]]; then
                read -rp "$OUTPUT already exists. Overwrite? [y/N]: " CONFIRM

                if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
                    echo -e "${YELLOW}[!] Conversion cancelled.${RESET}"
                    sleep 1
                    continue
                fi
            fi

            ffmpeg -i "$VIDEO" \
                -vcodec mpeg4 \
                -strict -2 \
                "$OUTPUT"

            if [[ $? -eq 0 ]]; then
                echo
                echo -e "${GREEN}[+] Conversion complete:${RESET} $OUTPUT"
            else
                echo
                echo -e "${RED}[!] Conversion failed.${RESET}"
            fi

            echo
            read -rp "Press ENTER to return to the menu..."
            clear
            ;;

        # ----------------------------------------------------
        # Extract frames
        # ----------------------------------------------------
        3)
            FRAME_DIR="${NAME}_frames"

            echo -e "${GREEN}[+] Frame extraction${RESET}"
            echo
            echo "This will extract 10 frames per second."
            echo
            echo -e "Frames will be stored in:"
            echo -e "  ${CYAN}${FRAME_DIR}/${RESET}"
            echo

            if [[ -d "$FRAME_DIR" ]]; then
                echo -e "${YELLOW}[!] Directory already exists:${RESET} $FRAME_DIR"
                echo
                read -rp "Use this directory? [Y/n]: " USE_EXISTING

                if [[ "$USE_EXISTING" =~ ^[Nn]$ ]]; then
                    echo -e "${YELLOW}[!] Frame extraction cancelled.${RESET}"
                    sleep 1
                    continue
                fi
            else
                read -rp "Create this directory? [Y/n]: " CREATE_DIR

                if [[ "$CREATE_DIR" =~ ^[Nn]$ ]]; then
                    echo -e "${YELLOW}[!] Frame extraction cancelled.${RESET}"
                    sleep 1
                    continue
                fi

                mkdir -p "$FRAME_DIR"
            fi

            echo
            echo -e "${GREEN}[+] Extracting frames...${RESET}"
            echo

            ffmpeg -y \
                -i "$VIDEO" \
                -map 0:v:0 \
                -an \
                -vf fps=10 \
                "$FRAME_DIR/img%06d.bmp"

            if [[ $? -eq 0 ]]; then
                FRAME_COUNT=$(find "$FRAME_DIR" -type f -name '*.bmp' | wc -l)

                echo
                echo -e "${GREEN}[+] Frame extraction complete.${RESET}"
                echo -e "    Frames created: ${WHITE}$FRAME_COUNT${RESET}"
                echo -e "    Location: ${CYAN}$FRAME_DIR/${RESET}"
            else
                echo
                echo -e "${RED}[!] Frame extraction failed.${RESET}"
            fi

            echo
            read -rp "Press ENTER to return to the menu..."
            clear
            ;;

        # ----------------------------------------------------
        # Extract audio
        # ----------------------------------------------------
        4)
            OUTPUT="${NAME}.mp3"

            echo -e "${GREEN}[+] Extracting audio:${RESET}"
            echo -e "    $VIDEO ${CYAN}->${RESET} $OUTPUT"
            echo

            if [[ -e "$OUTPUT" ]]; then
                read -rp "$OUTPUT already exists. Overwrite? [y/N]: " CONFIRM

                if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
                    echo -e "${YELLOW}[!] Audio extraction cancelled.${RESET}"
                    sleep 1
                    continue
                fi
            fi

            ffmpeg -i "$VIDEO" \
                -vn \
                -ac 2 \
                -ar 44100 \
                -ab 320k \
                -f mp3 \
                "$OUTPUT"

            if [[ $? -eq 0 ]]; then
                echo
                echo -e "${GREEN}[+] Audio extraction complete:${RESET} $OUTPUT"
            else
                echo
                echo -e "${RED}[!] Audio extraction failed.${RESET}"
            fi

            echo
            read -rp "Press ENTER to return to the menu..."
            clear
            ;;

        # ----------------------------------------------------
        # Rotate 90 degrees
        # ----------------------------------------------------
        5)
            OUTPUT="${NAME}_rotated.mp4"

            echo -e "${GREEN}[+] Rotating video 90 degrees:${RESET}"
            echo -e "    $VIDEO ${CYAN}->${RESET} $OUTPUT"
            echo

            if [[ -e "$OUTPUT" ]]; then
                read -rp "$OUTPUT already exists. Overwrite? [y/N]: " CONFIRM

                if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
                    echo -e "${YELLOW}[!] Rotation cancelled.${RESET}"
                    sleep 1
                    continue
                fi
            fi

            ffmpeg -i "$VIDEO" \
                -vf transpose=0 \
                "$OUTPUT"

            if [[ $? -eq 0 ]]; then
                echo
                echo -e "${GREEN}[+] Rotation complete:${RESET} $OUTPUT"
            else
                echo
                echo -e "${RED}[!] Rotation failed.${RESET}"
            fi

            echo
            read -rp "Press ENTER to return to the menu..."
            clear
            ;;

        # ----------------------------------------------------
        # Video information
        # ----------------------------------------------------
        6)
            echo -e "${GREEN}[+] Video information${RESET}"
            echo

            ffprobe "$VIDEO"

            echo
            read -rp "Press ENTER to return to the menu..."
            clear
            ;;

        # ----------------------------------------------------
        # Exit
        # ----------------------------------------------------
        7)
            echo -e "${CYAN}Exiting video toolkit.${RESET}"
            exit 0
            ;;

        *)
            echo -e "${RED}[!] Invalid selection.${RESET}"
            sleep 1
            clear
            ;;

    esac

done
