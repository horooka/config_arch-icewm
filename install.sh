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


# OpenVINO gen.nvim,
# local model can be used for short code inplace modification (function review)
#
# cd /tmp && python -m venv ov && source ov/bin/activate && \
# pip install openvino openvino-genai huggingface_hub && \
# hf download OpenVINO/Qwen2.5-Coder-3B-Instruct-int4-ov --local-dir qwen_ov && \
# chmod +x ov-chat.py && \
# sudo mkdir -p /opt/ov /usr/bin && sudo mv qwen_ov ov-chat.py /opt/ov && sudo mv /opt/ov/ov-chat.py /usr/bin/ov-chat
rm ov-chat.py

reboot
