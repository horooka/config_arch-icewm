sudo pacman -Suy
sudo pacman -S bat brightnessctl fastfetch firefox fzf git icewm nvim zsh

for i in fastfetch icewm nvim; do
  rm -rf ~/.config/$i
  cp -r $i ~/.config/
done

for i in Xresources; done
  cp $i ~/.$i
done

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
sudo mv MesloLGS\ NF\ Bold.ttf /usr/share/fonts

chsh -s /usr/bin/zsh

cp zshrc ~/.zshrc

#Audio
#sudo pacman -S pipewire pipewire-pulse pipewire-alsa wireplumber sof-firmware

#Rustup and rust-analyzer for nvim lsp
#sudo pacman -S rustup cargo && rustup default stable && rustup component add rust-analyzer

#Rust_clipboard (exes compiled for wayland and have default settings)
#sudo chmod 0777 clipboard-gui clipboard-daemon; sudo mv clipboard-gui clipboard-daemon /usr/bin/; mv clipboard-daemon.service ~/.config/systemd/user/; systemctl --user enable --now clipboard-daemon.service
