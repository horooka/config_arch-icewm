sudo pacman -Suy
sudo pacman -S bat brightnessctl fastfetch firefox fzf git icewm nvim neovide zsh

for i in fastfetch icewm nvim; do
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

#Audio
#sudo pacman -S pipewire pipewire-pulse pipewire-alsa wireplumber sof-firmware
