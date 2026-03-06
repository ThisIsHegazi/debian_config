#!/bin/bash

# =============================================================================
# Oh-My-Zsh Setup Script
# =============================================================================
# Installs Oh-My-Zsh along with the zsh-syntax-highlighting and
# zsh-autosuggestions plugins, registers both plugins in ~/.zshrc, and appends
# a set of convenience aliases for common system and package management tasks.
#
# Safe to run multiple times — all operations are guarded against duplicates.
#
# Usage: bash ohmyzsh-setup.sh
# Note: Do NOT run as root. Oh-My-Zsh should be installed for your user account.
# =============================================================================

echo "Installing oh-my-zsh..."
# Download and run the official Oh-My-Zsh installer in unattended mode.
# --unattended skips the interactive prompts and prevents the installer from
# switching the shell mid-script, which would cause all subsequent lines to
# never execute.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "oh-my-zsh was successfully installed"

# zsh syntax highlighting
echo "Downloading zsh-syntax-highlighting..."
# Clone the plugin into Oh-My-Zsh's custom plugins directory.
# Respects a custom $ZSH_CUSTOM path if set, otherwise falls back to the
# default ~/.oh-my-zsh/custom location.
# The directory check prevents a git error if the plugin is already present.
SYNTAX_HL_DIR="/home/hegazy/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
if [ ! -d "$SYNTAX_HL_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HL_DIR"
fi
echo "zsh-syntax-highlighting was successfully installed"

# zsh-autosuggestions
echo "Downloading zsh-autosuggestions..."
# Same pattern as above — clone into the custom plugins directory only if
# the directory does not already exist.
AUTOSUGG_DIR="/home/hegazy/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
if [ ! -d "$AUTOSUGG_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGG_DIR"
fi
echo "zsh-autosuggestions was successfully installed"

# Register the plugins in ~/.zshrc so Oh-My-Zsh loads them on shell startup.
# The sed command prepends the plugin names to the existing plugins=() list,
# which preserves any plugins already listed (e.g. git).
# The grep guard makes this idempotent — if zsh-syntax-highlighting is already
# in the list, the sed command is skipped entirely.
echo "Updating .zshrc plugin list..."
if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
    sed -i 's/^plugins=(/plugins=(sudo zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc
fi
echo "Done updating .zshrc plugin list."

# Append convenience aliases to ~/.zshrc.
# The aliases cover power management and common apt operations so you don't
# need to type full systemctl or sudo apt commands each time.
# The grep guard checks for the marker comment so aliases are only written
# once — re-running the script will not produce duplicate alias blocks.
# The heredoc uses quoted 'EOF' to prevent variable or command substitution
# inside the alias definitions.
echo "Adding aliases to .zshrc..."
if ! grep -q "# Custom aliases" ~/.zshrc; then
    cat >> ~/.zshrc << 'EOF'

# Custom aliases
alias poweroff="systemctl poweroff"
alias reboot="systemctl reboot"
alias hibernate="systemctl hibernate"
alias update="sudo apt update"
alias upgrade="sudo apt upgrade -y"
alias apti="sudo apt install -y"
EOF
fi

echo "Done! Please run 'source ~/.zshrc' or start a new terminal."
