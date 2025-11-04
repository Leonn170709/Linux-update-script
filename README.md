# 🔧 Universal Linux Update Script

This Bash script automatically detects which Linux distribution you’re running  
and executes the appropriate **update command** for your system.  

It supports many popular distros such as **Arch, Debian, Ubuntu, Fedora, openSUSE, Alpine, Void, Gentoo, and Solus**.

---

## 🚀 Features

- Automatically detects your Linux distribution via `/etc/os-release`
- Runs the correct update command for your package manager (`pacman`, `apt`, `dnf`, `zypper`, `apk`, `xbps`, `emerge`, `eopkg`)
- Supports **automatic installation** (no confirmation prompts)
- Optional **log retention**
- Also updates **Flatpak** packages
- Clean, colorful output

---

## 🧩 Supported Distributions

| Base        | Examples                     | Package Manager | Command |
|--------------|------------------------------|------------------|----------|
| **Arch**     | Arch, Manjaro                | pacman           | `sudo pacman -Syu` |
| **Debian**   | Debian, Ubuntu, Linux Mint   | apt              | `sudo apt update && sudo apt upgrade` |
| **Fedora**   | Fedora, RHEL, CentOS         | dnf              | `sudo dnf upgrade` |
| **openSUSE** | openSUSE, GeckoLinux         | zypper           | `sudo zypper refresh && sudo zypper update` |
| **Alpine**   | Alpine Linux                 | apk              | `sudo apk update && sudo apk upgrade` |
| **Void**     | Void Linux                   | xbps-install     | `sudo xbps-install -Suy` |
| **Gentoo**   | Gentoo                       | emerge           | `sudo emerge --sync && sudo emerge -uDU @world` |
| **Solus**    | Solus                        | eopkg            | `sudo eopkg upgrade` |

---
# ⚡ Running the Update Script from Anywhere

If you want to use the update script directly in your terminal **from any location**,  
you can move (or copy) it into a directory that’s included in your system’s `$PATH`,  
such as `/usr/bin/` or `/usr/local/bin/`.

---

## 🪄 Make It Globally Accessible

1. Move the script to `/usr/bin/`:
   ```bash
   sudo mv update.sh /usr/bin/
2. Make sure it’s executable:
   ```bash
   sudo chmod +x /usr/bin/update.sh
4. Now you can run it from anywhere:
   ```bash
   update.sh
