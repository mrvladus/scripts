# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# PROMPT FORMAT
PS1='\W\n> '

# ALIASES
alias ls='ls --color=auto'
alias up='yay && flatpak update'
alias yeet='sudo pacman -Rsnc'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# PATH
export PATH="$HOME/.local/bin:$PATH"

