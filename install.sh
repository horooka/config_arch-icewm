sudo pacman -Suy bat brightnessctl firefox fzf git icewm nvim zsh

mkdir ~/.config
for i in icewm nvim; do
  rm -rf ~/.config/$i
  cp -r $i ~/.config/
done
for i in Xresources; done
  cp $i ~/.$i
done

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
sudo mv MesloLGSNerdFont-Regular.ttf /usr/share/fonts
chsh -s /usr/bin/zsh

cp zshrc ~/.zshrc
cp xtemplate.txt ~/.config/xtemplate.txt

# Audio
#
# sudo pacman -S pipewire pipewire-pulse pipewire-alsa wireplumber sof-firmware

# Cursor-nvim
#
# paru -S --skipreview cursor-bin
# cp cursor/settings.json cursor/keybindings.json ~/.config/Cursor/User/
# mkdir -p ~/.cursor/skills
# cp -r cursor/gtkmm3 ~/.cursor/skills
rm -rf cursor

reboot
