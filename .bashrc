#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -r /usr/share/blesh/ble.sh ]] && source /usr/share/blesh/ble.sh

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"
export EDITOR=nvim
export VISUAL=nvim

# ---- Colors (amber theme) ----
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias tmatrix='tmatrix --background=default'

[[ -r ~/.config/shell-themes/current.sh ]] || ln -sf ~/.config/shell-themes/amber.sh ~/.config/shell-themes/current.sh
source ~/.config/shell-themes/current.sh

theme() {
  local t="$1"
  [[ -f ~/.config/shell-themes/$t.sh ]] || { echo "usage: theme amber|hacker|synthwave"; return 1; }
  sed -i "s|^include themes/.*|include themes/$t.conf|" ~/.config/kitty/kitty.conf
  sed -i "s|^palette = .*|palette = \"$t\"|" ~/.config/starship.toml
  ln -sf ~/.config/shell-themes/$t.sh ~/.config/shell-themes/current.sh
  ln -sf ~/.config/rofi/themes/$t.rasi ~/.config/rofi/colors.rasi
  cp ~/.config/quickshell/themes/$t.qml ~/.config/quickshell/Theme.qml
  source ~/.config/shell-themes/current.sh
  pkill -USR1 -x kitty   # reload kitty config
}

eval "$(starship init bash)"

dotsync() {
  cd ~/Downloads/linux_config || return
  cp ~/.bashrc .bashrc
  cp -a ~/.config/rofi/. rofi/
  cp -a ~/.config/quickshell/. quickshell/
  git status --short
}

# MUST BE AT THE END FOR SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
