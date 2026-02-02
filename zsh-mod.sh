#!/bin/bash

# ==============================================================================
# PROJECT: ZSH-MOD
# DESCRIPTION: A lightweight, automated setup for a beautiful ZSH environment.
#              Installs Starship, Nerd Fonts, and Fastfetch without the bloat.
# AUTHOR:      @PiyushBhardwaj
# ==============================================================================

show_banner() {
    # Define Colors
    local B='\033[1;34m'   # Blue
    local W='\033[1;37m'   # White (Bright)
    local G='\033[1;32m'   # Green (for subtitle)
    local P='\033[0;35m'   # Purple (for credits)
    local NC='\033[0m'     # No Color (reset)

    # Use printf for compatibility across all shells
    printf "\n"
    
    # Line 1: ZSH (Blue) + MOD (White)
    printf "${B}███████╗███████╗██╗  ██╗   ${W}███╗   ███╗ ██████╗ ██████╗ ${NC}\n"
    # Line 2
    printf "${B}╚══███╔╝██╔════╝██║  ██║   ${W}████╗ ████║██╔═══██╗██╔══██╗${NC}\n"
    # Line 3
    printf "${B}  ███╔╝ ███████╗███████║   ${W}██╔████╔██║██║   ██║██║  ██║${NC}\n"
    # Line 4
    printf "${B} ███╔╝  ╚════██║██╔══██║   ${W}██║╚██╔╝██║██║   ██║██║  ██║${NC}\n"
    # Line 5
    printf "${B}███████╗███████║██║  ██║   ${W}██║ ╚═╝ ██║╚██████╔╝██████╔╝${NC}\n"
    # Line 6
    printf "${B}╚══════╝╚══════╝╚═╝  ╚═╝   ${W}╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ${NC}\n"

    printf "\n"
    printf "${G}         >> Ultimate Terminal Setup <<          ${NC}\n"
    printf "${P}      Credits: Starship • Fastfetch • CTT       ${NC}\n"
    printf "\n"
    printf "                                     by @PiyushBhardwaj\n"
    printf "github.com/bhardwaj-23"
    printf "\n"
}

# Run the function
show_banner

# Colors for output messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  printf "${RED}Please run this script as root (sudo).${NC}\n"
  exit 1
fi

# ==========================================
# 1. User Configuration
# ==========================================
printf "${BLUE}--- User Configuration ---${NC}\n"
read -p "Enter the username to configure ZSH for (e.g., Joe, Piyush): " TARGET_USER < /dev/tty

# Verify user exists
if ! id "$TARGET_USER" &>/dev/null; then
    printf "${RED}User '$TARGET_USER' does not exist! Exiting.${NC}\n"
    exit 1
fi

TARGET_HOME=$(eval echo "~$TARGET_USER")
printf "${GREEN}Configuring shell for user: $TARGET_USER at $TARGET_HOME${NC}\n"

# Install dependencies if missing
apt update
apt install -y curl wget unzip git

# ==========================================
# 2. Backups
# ==========================================
printf "${BLUE}--- Backing up Configuration Files ---${NC}\n"
BACKUP_DIR="$TARGET_HOME/Documents/Shell_Backups_$(date +%F_%H-%M)"
mkdir -p "$BACKUP_DIR"

# Backup User files
[ -f "$TARGET_HOME/.bashrc" ] && cp "$TARGET_HOME/.bashrc" "$BACKUP_DIR/bashrc.bak"
[ -f "$TARGET_HOME/.zshrc" ] && cp "$TARGET_HOME/.zshrc" "$BACKUP_DIR/zshrc.bak"

# Backup Root files (as requested)
[ -f "/root/.bashrc" ] && cp "/root/.bashrc" "$BACKUP_DIR/root_bashrc.bak"
[ -f "/root/.zshrc" ] && cp "/root/.zshrc" "$BACKUP_DIR/root_zshrc.bak"

printf "${GREEN}Backups saved to: $BACKUP_DIR${NC}\n"

# ==========================================
# 3. Install Starship
# ==========================================
printf "${BLUE}--- Installing Starship ---${NC}\n"
if ! command -v starship &> /dev/null; then
    # Added -4 to curl for IPv4 network stability
    curl -4 -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "Starship is already installed."
fi

# Configure User .bashrc
if ! grep -q "starship init bash" "$TARGET_HOME/.bashrc"; then
    echo 'eval "$(starship init bash)"' >> "$TARGET_HOME/.bashrc"
fi

# Configure User .zshrc
if ! grep -q "starship init zsh" "$TARGET_HOME/.zshrc"; then
    echo 'eval "$(starship init zsh)"' >> "$TARGET_HOME/.zshrc"
    echo 'export TERM=xterm-256color' >> "$TARGET_HOME/.zshrc"
fi

# Apply Chris Titus Tech Starship Config
mkdir -p "$TARGET_HOME/.config"
echo "Downloading Starship Config (Credit: ChrisTitusTech)..."
# Added -4 for IPv4 stability
curl -4 -o "$TARGET_HOME/.config/starship.toml" https://raw.githubusercontent.com/ChrisTitusTech/mybash/main/starship.toml

# ==========================================
# 4. Install Meslo Nerd Fonts
# ==========================================
printf "${BLUE}--- Installing Meslo Nerd Font ---${NC}\n"
FONT_DIR="/usr/local/share/fonts/meslo"
TEMP_DIR=$(mktemp -d)

if [ ! -d "$FONT_DIR" ]; then
    mkdir -p "$FONT_DIR"
    cd "$TEMP_DIR"
    echo "Downloading Fonts..."
    wget -4 -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip
    unzip -q Meslo.zip
    mv *.ttf "$FONT_DIR"
    fc-cache -fv
    printf "${GREEN}Fonts installed.${NC}\n"
else
    echo "Meslo fonts folder already exists. Skipping download."
fi

# ==========================================
# 5. Install Fastfetch (Dynamic + Apt Fallback)
# ==========================================
printf "${BLUE}--- Installing Fastfetch ---${NC}\n"
cd "$TEMP_DIR"

printf "${BLUE}Fetching latest Fastfetch version info...${NC}\n"

# 1. Try to get the URL
FASTFETCH_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
| grep "browser_download_url" \
| grep "linux-amd64.deb" \
| cut -d '"' -f 4)

# 2. logical Flow Control
if [ -n "$FASTFETCH_URL" ]; then
    # --- OPTION A: GitHub API Success ---
    printf "${GREEN}Latest version found: $FASTFETCH_URL${NC}\n"
    printf "${BLUE}Downloading .deb package...${NC}\n"
    
    wget -4 -q --show-progress -O fastfetch.deb "$FASTFETCH_URL"

    if [ -f "fastfetch.deb" ]; then
        apt install -y ./fastfetch.deb
    else
        printf "${RED}Download failed. Trying apt fallback...${NC}\n"
        apt install -y fastfetch
    fi

else
    # --- OPTION B: GitHub API Failed ---
    printf "${RED}Could not fetch release info from GitHub.${NC}\n"
    printf "${BLUE}Falling back to apt package manager...${NC}\n"
    
    apt install -y fastfetch
fi

# Add Fastfetch logic to .zshrc (Run only on first instance)
ZSHRC="$TARGET_HOME/.zshrc"
FASTFETCH_BLOCK='
# Run fastfetch only if this is the only zsh instance running
if [[ $(pgrep -u "$USER" -x zsh -c) -eq 1 ]]; then
    fastfetch
fi
'

if ! grep -q "pgrep -u" "$ZSHRC"; then
    echo "$FASTFETCH_BLOCK" >> "$ZSHRC"
fi

# ==========================================
# 6. Final Permissions Fix & Cleanup
# ==========================================
# Ensure the user owns their home folder files (since we ran as root)
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config"
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.zshrc"
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc"
chown -R "$TARGET_USER:$TARGET_USER" "$BACKUP_DIR"

# Fix potential root ownership of Documents if it didn't exist before
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/Documents" 2>/dev/null

# Remove temp files
rm -rf "$TEMP_DIR"

printf "${GREEN}==========================================${NC}\n"
printf "${GREEN}Setup Complete!${NC}\n"
printf "${BLUE}Please Follow These Final Manual Steps:${NC}\n"
echo "1. Open your terminal preferences."
echo "2. Change the font to 'MesloLGS Nerd Font'."
echo "3. Restart your terminal."
printf "${GREEN}==========================================${NC}\n"