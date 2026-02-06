# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export DEBUGINFOD_URLS="https://debuginfod.archlinux.org"
ZSH_THEME="powerlevel10k/powerlevel10k"
source $ZSH/oh-my-zsh.sh
plugins=(git)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

br() {
    if [[ -z $1 ]]; then
        echo "usage: br [brightness as promiles] - change brightness"
    else
        brightnessctl s $[ 100 * $1]
    fi
}

calc() {
    read -r expr
    echo "$expr" | bc
}

grp() {
    local sel=$(
    rg --line-number --no-heading --color=never "$1" \
    | fzf \
        --height 50% --border \
        --delimiter ':' \
        --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
        --preview-window 'right:60%' \
    ) || return

    local file=${sel%%:*}
    local rest=${sel#*:}
    local line=${rest%%:*}

    nvim +"$line" "$file"
}

opn() {
    local path=""

    if [[ -z $1 ]]; then
        path=$(/usr/bin/fzf --preview="/usr/bin/bat {} --color=always")
        if [[ $path ]]; then
            nvim $path
        fi
    else
        case $1 in
        m)
            /usr/bin/nvim $PWD/src/main.*
            ;;
        esac
    fi
}
