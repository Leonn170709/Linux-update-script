#!/bin/bash

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Flags
SILENT="no"

# Help function
show_help() {
    echo -e "${CYAN}Usage: $0 [OPTIONS]${RESET}"
    echo ""
    echo -e "${YELLOW}Options:${RESET}"
    echo "  --silent, -s     Run everything without questions (auto mode)"
    echo "  --help, -h, help Show this help menu"
    echo ""
    echo -e "${YELLOW}This script will:${RESET}"
    echo "  • Detect your Linux distro"
    echo "  • Run the correct system update"
    echo "  • Update Snap (if installed)"
    echo "  • Update Flatpak (if installed)"
    echo "  • Optionally update AUR (Arch only)"
    echo "  • Optionally reboot"
    exit 0
}

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --silent|-s)
            SILENT="yes"
            ;;
        --help|-h|help)
            show_help
            ;;
    esac
done

# Read distro info
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
else
    echo -e "${YELLOW}⚠️  Could not find /etc/os-release. Exiting.${RESET}"
    exit 1
fi

# Detect base system
BASE="unknown"

if [[ "$ID_LIKE" == *"arch"* || "$ID" == "arch" || "$ID" == "manjaro" || "$ID" == "cachyos" ]]; then
    BASE="arch"
elif [[ "$ID_LIKE" == *"debian"* || "$ID_LIKE" == *"ubuntu"* || "$ID" == "debian" || "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]; then
    BASE="debian"
elif [[ "$ID_LIKE" == *"fedora"* || "$ID" == "fedora" || "$ID" == "rhel" || "$ID" == "centos" ]]; then
    BASE="fedora"
elif [[ "$ID_LIKE" == *"suse"* || "$ID" == "opensuse"* ]]; then
    BASE="suse"
elif [[ "$ID_LIKE" == *"alpine"* || "$ID" == "alpine" ]]; then
    BASE="alpine"
elif [[ "$ID_LIKE" == *"void"* || "$ID" == "void" ]]; then
    BASE="void"
elif [[ "$ID_LIKE" == *"gentoo"* || "$ID" == "gentoo" ]]; then
    BASE="gentoo"
elif [[ "$ID_LIKE" == *"solus"* || "$ID" == "solus" ]]; then
    BASE="solus"
fi

echo -e "${CYAN}🔧 Update Script Started at: $(date)${RESET}"
echo -e "${CYAN}💡 Detected base system: ${YELLOW}${BASE}${RESET}"

# Silent mode presets
if [[ "$SILENT" == "yes" ]]; then
    keep_logs="y"
    auto_install="y"
    update_aur="y"
else
    read -p "📜 Keep logs? (y/n): " keep_logs
    read -p "⚡ Auto install without asking? (y/n): " auto_install
fi

# Log file location
if [[ $EUID -eq 0 ]]; then
    LOG_FILE="/var/log/updaterlogs/update@$(date).log"
else
    LOG_FILE="$HOME/updaterlogs/update@$(date).log"
fi

# Enable logging
exec > >(tee -a "$LOG_FILE") 2>&1
echo "📁 Log file: $LOG_FILE"

# System update based on distro
case "$BASE" in
  arch)
    echo -e "${YELLOW}📦 Pacman is now updating...${RESET}"
    [[ "$auto_install" == "y" ]] && sudo pacman -Syu --noconfirm || sudo pacman -Syu

    # AUR update
    if command -v yay &> /dev/null; then
        if [[ "$SILENT" != "yes" ]]; then
            read -p "📦 Update AUR packages with yay? (y/n): " update_aur
        fi
        if [[ "$update_aur" == "y" ]]; then
            echo -e "${YELLOW}📦 Yay is now updating AUR packages...${RESET}"
            [[ "$auto_install" == "y" ]] && yay -Syu --noconfirm || yay -Syu
        fi
    fi
    ;;

  debian)
    echo -e "${YELLOW}📦 APT is now updating...${RESET}"
    [[ "$auto_install" == "y" ]] && sudo apt update && sudo apt upgrade -y || sudo apt update && sudo apt upgrade
    ;;

  fedora)
    echo -e "${YELLOW}📦 DNF is now updating...${RESET}"
    [[ "$auto_install" == "y" ]] && sudo dnf upgrade -y || sudo dnf upgrade
    ;;

  suse)
    echo -e "${YELLOW}📦 Zypper is now updating...${RESET}"
    [[ "$auto_install" == "y" ]] && sudo zypper refresh && sudo zypper update -y || sudo zypper refresh && sudo zypper update
    ;;

  alpine)
    echo -e "${YELLOW}📦 APK is now updating...${RESET}"
    apk update && apk upgrade
    ;;

  void)
    echo -e "${YELLOW}📦 XBPS is now updating...${RESET}"
    [[ "$auto_install" == "y" ]] && sudo xbps-install -Suy || sudo xbps-install -Su
    ;;

  gentoo)
    echo -e "${YELLOW}📦 Portage (emerge) is now updating...${RESET}"
    [[ "$auto_install" == "y" ]] && sudo emerge --sync && sudo emerge -uDU --with-bdeps=y @world || sudo emerge --sync && sudo emerge -uD --ask @world
    ;;

  solus)
    echo -e "${YELLOW}📦 eopkg is now updating...${RESET}"
    [[ "$auto_install" == "y" ]] && sudo eopkg upgrade -y || sudo eopkg upgrade
    ;;

  *)
    echo -e "${YELLOW}⚠️ Unknown distribution – no update executed.${RESET}"
    ;;
esac

# Snap update
if command -v snap &> /dev/null; then
    echo -e "${YELLOW}📦 Snap is now updating...${RESET}"
    sudo snap refresh
fi

# Flatpak update
if command -v flatpak &> /dev/null; then
    echo -e "${YELLOW}📦 Flatpak is now updating...${RESET}"
    [[ "$auto_install" == "y" ]] && flatpak update -y || flatpak update
fi

# Clear screen if logs are not kept
if [[ "$keep_logs" != "y" ]]; then
    clear
fi

# Reboot prompt (disabled in silent mode)
if [[ "$SILENT" != "yes" ]]; then
    read -p "🔁 Reboot now? (y/n): " reboot_now
    [[ "$reboot_now" == "y" ]] && sudo reboot
fi

echo -e "${GREEN}✅ Packages updated successfully!${RESET}"
echo "✅ Log saved to: $LOG_FILE"
