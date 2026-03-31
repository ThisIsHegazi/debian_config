#!/bin/bash

set -euo pipefail

# =============================================================================
# Oh-My-Zsh Setup Script for Manjaro/Arch
# =============================================================================

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root. Run it as the user who should own the shell config."
    exit 1
fi

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
ZSHRC_FILE="${ZDOTDIR:-$HOME}/.zshrc"
SYNTAX_HL_DIR="$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
AUTOSUGG_DIR="$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"

if [ ! -d "$ZSH_DIR" ]; then
    echo "Installing oh-my-zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "oh-my-zsh is already installed at $ZSH_DIR"
fi

mkdir -p "$ZSH_CUSTOM_DIR/plugins"

echo "Installing zsh-syntax-highlighting..."
if [ ! -d "$SYNTAX_HL_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HL_DIR"
else
    echo "zsh-syntax-highlighting is already installed."
fi

echo "Installing zsh-autosuggestions..."
if [ ! -d "$AUTOSUGG_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGG_DIR"
else
    echo "zsh-autosuggestions is already installed."
fi

touch "$ZSHRC_FILE"

ensure_plugin() {
    local plugin="$1"

    if grep '^plugins=(' "$ZSHRC_FILE" | tr '()' '  ' | tr ' ' '\n' | grep -qx "$plugin"; then
        return 0
    fi

    if grep -q '^plugins=(' "$ZSHRC_FILE"; then
        sed -i "/^plugins=(/ s/)/ ${plugin})/" "$ZSHRC_FILE"
    else
        printf '\nplugins=(git %s)\n' "$plugin" >> "$ZSHRC_FILE"
    fi
}

echo "Updating .zshrc plugin list..."
ensure_plugin "sudo"
ensure_plugin "zsh-autosuggestions"
ensure_plugin "zsh-syntax-highlighting"
echo "Done updating .zshrc plugin list."

echo "Adding aliases to .zshrc..."
if ! grep -q "# Custom aliases (manjaro_config)" "$ZSHRC_FILE"; then
    cat >>"$ZSHRC_FILE" <<'EOF'

# Custom aliases (manjaro_config)
alias poweroff="systemctl poweroff"
alias reboot="systemctl reboot"
alias hibernate="systemctl hibernate"
alias update="sudo pacman -Sy"
alias upgrade="sudo pacman -Syu"
alias paci="sudo pacman -S --needed"
EOF
fi

echo "Done! Please run 'source ~/.zshrc' or start a new terminal."
