#!/bin/bash

# Farben
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

echo -e "${CYAN}🔧 Update Script Started${RESET}"

# Lese Distributionsinformationen
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
else
    echo -e "${YELLOW}⚠️  Konnte /etc/os-release nicht finden. Beende Script.${RESET}"
    exit 1
fi

# Erkenne Basis-System
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

echo -e "${CYAN}💡 Detected base system: ${YELLOW}${BASE}${RESET}"

# Frage: Logs behalten?
read -p "📜 Keep logs? (y/n): " keep_logs

# Frage: Automatisch installieren?
read -p "⚡ Auto install without asking? (y/n): " auto_install

# Führe das passende Update aus
case "$BASE" in
  arch)
    echo -e "${YELLOW}📦 Pacman is now updating...${RESET}"
    if [[ "$auto_install" == "y" ]]; then
        sudo pacman -Syu --noconfirm
    else
        sudo pacman -Syu
    fi
    ;;
  debian)
    echo -e "${YELLOW}📦 APT is now updating...${RESET}"
    if [[ "$auto_install" == "y" ]]; then
        sudo apt update && sudo apt upgrade -y
    else
        sudo apt update && sudo apt upgrade
    fi
    ;;
  fedora)
    echo -e "${YELLOW}📦 DNF is now updating...${RESET}"
    if [[ "$auto_install" == "y" ]]; then
        sudo dnf upgrade -y
    else
        sudo dnf upgrade
    fi
    ;;
  suse)
    echo -e "${YELLOW}📦 Zypper is now updating...${RESET}"
    if [[ "$auto_install" == "y" ]]; then
        sudo zypper refresh && sudo zypper update -y
    else
        sudo zypper refresh && sudo zypper update
    fi
    ;;
  alpine)
    echo -e "${YELLOW}📦 APK is now updating...${RESET}"
    if [[ "$auto_install" == "y" ]]; then
        sudo apk update && sudo apk upgrade
    else
        apk update && apk upgrade
    fi
    ;;
  void)
    echo -e "${YELLOW}📦 XBPS is now updating...${RESET}"
    if [[ "$auto_install" == "y" ]]; then
        sudo xbps-install -Suy
    else
        sudo xbps-install -Su
    fi
    ;;
  gentoo)
    echo -e "${YELLOW}📦 Portage (emerge) is now updating...${RESET}"
    if [[ "$auto_install" == "y" ]]; then
        sudo emerge --sync && sudo emerge -uDU --with-bdeps=y @world
    else
        sudo emerge --sync && sudo emerge -uD --ask @world
    fi
    ;;
  solus)
    echo -e "${YELLOW}📦 eopkg is now updating...${RESET}"
    if [[ "$auto_install" == "y" ]]; then
        sudo eopkg upgrade -y
    else
        sudo eopkg upgrade
    fi
    ;;
  *)
    echo -e "${YELLOW}⚠️  Unbekannte Distribution – kein automatischer Update-Befehl ausgeführt.${RESET}"
    ;;
esac

# Flatpak Update
echo -e "${YELLOW}📦 Flatpak is now updating...${RESET}"
if [[ "$auto_install" == "y" ]]; then
    flatpak update -y
else
    flatpak update
fi

# Bildschirm ggf. leeren
if [[ "$keep_logs" != "y" ]]; then
    clear
fi

# Erfolgsmeldung
echo -e "${GREEN}✅ Packages updated successfully!${RESET}"
