#!/data/data/com.termux/files/usr/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== Android Ghost Storage Hunter v3.0 (LOUD DEBUG MODE) ===${NC}"

# Check for storage permission
if [ ! -d "/sdcard/Android" ]; then
    echo -e "${RED}[!] Storage permission not detected. Requesting now...${NC}"
    termux-setup-storage
    exit 1
fi

echo -ne "${YELLOW}[?] Approx how many GB are you hunting? (e.g. 60): ${NC}"
read GHOST_SIZE < /dev/tty

echo -e "${YELLOW}[*] Searching for individual FILES larger than 1GB...${NC}" 

manual_delete() {
    local path="$1"
    local size="$2"
    
    echo -e "--------------------------------------------------"
    echo -e "FOUND: ${RED}$path${NC}"
    echo -e "SIZE:  ${GREEN}$size${NC}"
    
    echo -ne "${YELLOW}[?] Type 'yes' to DELETE or 'n' to SKIP: ${NC}"
    read choice < /dev/tty
    
    if [[ "$choice" == "yes" ]] || [[ "$choice" == "y" ]]; then
        echo -e "${CYAN}[DEBUG] Attempting raw system delete...${NC}"
        
        # NO SILENCERS. We run pure 'rm -v' (verbose) so it tells us exactly what it does.
        if rm -v "$path"; then
            echo -e "${GREEN}[OK] Termux successfully wiped it.${NC}"
        else
            echo -e "${RED}[FATAL] Termux failed to delete the file. See the system error above.${NC}"
        fi
    else
        echo -e "${CYAN}[-] Skipped.${NC}"
    fi
}

# Deep Scan Logic
LARGE_ITEMS=$(find /sdcard/ -type f -size +1G -exec du -h {} + 2>/dev/null | sort -hr)

if [[ -z "$LARGE_ITEMS" ]]; then
    echo -e "${RED}[!] No files larger than 1GB detected.${NC}"
else
    COUNT=0
    TOTAL=$(echo "$LARGE_ITEMS" | wc -l)
    
    while IFS= read -r item; do
        read -r SIZE PATH_NAME <<< "$item"
        COUNT=$((COUNT + 1))
        echo -e "${CYAN}[*] Processing [$COUNT/$TOTAL]${NC}"
        manual_delete "$PATH_NAME" "$SIZE"
    done <<< "$LARGE_ITEMS"
fi
