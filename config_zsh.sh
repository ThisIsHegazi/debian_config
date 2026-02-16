#!/usr/bin/bash

#!/usr/bin/bash
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "oh-my-zsh was successfully installed"

#zsh syntax highlighting
echo "Downloading zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "zsh-syntax-highlighting was successfully installed"


#zsh-autosuggestions
echo "Downloading zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
echo "zsh-autosuggestions was successfully installed"

# zshrc plugins
echo "Updating .zshrc plugin list..."
sed -i 's/^plugins=(/plugins=(sudo zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc

echo "Done! Please run 'source ~/.zshrc' or start a new terminal."

# adding aliases
cat >> ~/.zshrc << EOF

alias poweroff="systemctl poweroff"
alias reboot="systemctl reboot"
alias hibernate="systemctl hibernate"
alias update="sudo apt update"
alias upgrade="sudo apt upgrade -y"
alias apti="sudo apt install -y"
EOF