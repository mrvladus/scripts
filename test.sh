#!/bin/bash
[ ! -f /bin/dialog ] && sudo pacman -Sy dialog --noconfirm
dialog --msgbox "This is a message" 10 25
clear