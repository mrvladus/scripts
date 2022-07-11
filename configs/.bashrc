# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias ls='ls --color=auto -A'
alias yeet='sudo pacman -Rsnc'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias up='yay -Syu && flatpak update -y'

# Prompt format: 
# Current directory
# > 
PS1='\e[1;32m\W\e[m\n\e[1;36m>\e[m '
