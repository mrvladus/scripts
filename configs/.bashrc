# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# PROMPT FORMAT
PS1='\W\n> '

# ALIASES
# ARCHLINUX
if command -v pacman &> /dev/null; then
	alias up='yay && flatpak update -y'
	alias yeet='sudo pacman -Rsnc'
	alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
fi
# DEBIAN
if command -v apt &> /dev/null; then
	alias up='sudo nala upgrade -y && flatpak update -y'
	alias yeet='sudo nala purge'
fi

alias ls='ls --color=auto'

# PATH
export PATH="$HOME/.local/bin:$PATH"

