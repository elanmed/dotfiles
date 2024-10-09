export ZSH=$HOME/.zsh

export PATH=$HOME/.local/bin:$HOME/.deno/bin:/usr/local/sbin:$PATH
export EDITOR="nvim"

# https://superuser.com/a/71593
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
export LESS=" -R "

# https://dev.to/hbenvenutti/using-zsh-without-omz-4gch
export HISTFILE=$ZSH/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# https://superuser.com/a/613754
export XDG_TEMPLATES_DIR="$HOME"
export XDG_PUBLICSHARE_DIR="$HOME"
export XDG_DOCUMENTS_DIR="$HOME"
export XDG_MUSIC_DIR="$HOME"
export XDG_PICTURES_DIR="$HOME"
export XDG_VIDEOS_DIR="$HOME"
export XDG_SCREENCASTS_DIR="$HOME"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

export BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        source "$BASE16_SHELL/profile_helper.sh"
