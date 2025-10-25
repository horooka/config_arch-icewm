# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export DEBUGINFOD_URLS="https://debuginfod.archlinux.org"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git)

source $ZSH/oh-my-zsh.sh

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

cmk() {
    if [[ -z $1 ]]; then
        echo "usage:"
        echo "cmk br - rebuild and run build exe"
        echo "cmk b - rebuild build dir"
        echo "cmk r - run built exe"
    else
        case $1 in
            br)
                cmake --build build &&
                ./build/${PWD##*/}
                ;;
            b)
                cmake --build build
                ;;
            r)
                ./build/${PWD##*/}
                ;;
        esac
    fi
}

cpf() {
    if [[ -z "$2" ]]; then
        wl-copy < "$1"
    else
        case $1 in
        -h | --help)
        echo "usage:"
        echo "cpf [file_path] - copy file content to clipboard"
        echo "cpf -p [file_path] - paste clipboard content as file"
        echo "cpf -pa [file_path] - append clipboard content to file"
        ;;
        -p)
        wl-paste > "$2"
        ;;
        -pa)
        wl-paste >> "$2"
        ;;
        esac
    fi
}

dctl() {
    if [ -z "$1" ]; then
        echo "Usage: dctl [COMMAND]"
        echo ""
        echo Commands:
        echo "    db [username] - build image from dockerfile with tag by current directory"
        echo "    dr [username] - run container from image which taged by current directory with exposed 8000:8000 port"
        echo "    drr [username] - dockerfile rerun (z db dr)"
        echo "    b - build from docker compose"
        echo "    u - compose up"
        echo "    d - compose down"
        echo "    rr - rerun (d b u)"
        echo "    s - stop all the containers"
        echo "    z - stop and delete all the containers"
        echo "    l - docker compose logs"
    fi

    case "$1" in
        db)
            docker buildx build -t $2/${PWD##*/} .
            ;;
        dr)
            docker run -d --name ${PWD##*/} -p 8000:8000 $2/${PWD##*/}
            ;;
        drr)
            docker stop $(docker ps -q); docker rm $(docker ps -a -q); docker buildx build -t $2/${PWD##*/} .; docker run -d --name ${PWD##*/} -p 8000:8000 horooga/${PWD##*/}
            ;;
        b)
            docker compose build
            ;;
        u)
            docker compose up -d
            ;;
        d)
            docker compose down
            ;;
        rr)
            docker compose down; docker compose build; docker compose up -d
            ;;
        s)
            docker stop $(docker ps -a -q)
            ;;
        z)
            docker stop $(docker ps -a -q); docker rm $(docker ps -a -q)
            ;;
        l)
            docker compose logs
            ;; 
    esac
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

