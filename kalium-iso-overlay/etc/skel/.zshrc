alias ls='ls -Fa --color=auto'
alias l='ls'
alias .='l'
alias ll='ls -lh'

alias c='cd'
alias ..='cd ..'
cf() {
   dname=$1
   cd $(find . -name "$dname" -type d -print -quit)
}

clearf() {
   clrscr='\033[2J'
   clrscrlbuf='\033[3J'
   movcrsrTL='\033[1;1H'
   printf "$clrscr $clrscrlbuf $movcrsrTL"
}

# permutations for typos
alias cl='clear'
alias lc='clear'
alias clf='clearf'
alias lcf='clearf'

alias mkd='mkdir -p'

alias r='rm'
alias rr='rm -r'
alias rf='rm -f'
alias rrf='rm -rf'

export EDITOR='nvim'
#export EDITOR='emacsclient -nw -c -a "emacs -nw"'

alias em="$EDITOR"
#alias emk="em -e '(kill-emacs)'"
#alias emd="emacs --daemon &"
#alias emkd="emk && emd"
alias ed="ed -p'>'"
alias ee='em ~/.config/nvim/init.lua'
alias eg='em ~/.config/git/config'
alias ek='em ~/.config/kitty/kitty.conf'
alias eo='em ~/.config/openbox/'
alias ep='em ~/.config/picom/picom.conf'
alias ex='em ~/.xinitrc'
alias ez='em ~/.zshrc'

alias cm='chezmoi'
alias cmia='cm init --apply'
alias cma='cm add'
alias cmae='cm add --encrypt'
alias cmap='cm apply'
alias cmc='cm cd'
alias cmd='cm diff'
alias cme='cm edit --apply'
alias cmec='cm edit-config'
alias cmf='cm forget'
alias cmr='cm re-add'

b() { 
   # bc's underrated
   if [ $# -eq 0 ]; then
      bc -ql
   else
      echo "$*" | bc -ql
   fi
}

clock() {
   if [ $# -eq 0 ]
   then
      echo "[USAGE] clock N\n[DESC] prints date for N seconds"
      return
   fi

   date
   for _ in $(seq 1 $1 | tail -n +2)
   do
      sleep 1
      date
   done
}

alias c100='clock 100'
alias c10='c100'

alias ff='fastfetch'
alias g='git'   
alias rl='source ~/.zshrc'
alias sx='startx'

alias xi='sudo xbps-install -S'
alias xiy='sudo xbps-install -Sy'
alias xl='xbps-query -m'
alias xq='xbps-query -Rs'
alias xr='sudo xbps-remove -y'
alias xu='sudo xbps-install -Su'

# case-insensitive search, pretty convenient
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
autoload -Uz compinit && compinit

bindkey -e

PROMPT=$'%~\n%% '

