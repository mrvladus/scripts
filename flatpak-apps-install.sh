#!/bin/bash
flatpaks='io.github.shiftey.Desktop org.gnome.Logs com.usebottles.bottles org.gnome.eog org.gnome.FileRoller org.mozilla.firefox org.godotengine.Godot org.qbittorrent.qBittorrent org.telegram.desktop org.onlyoffice.desktopeditors org.gnome.Calculator org.gnome.Boxes org.gnome.Evince io.mpv.Mpv com.mattjakeman.ExtensionManager com.github.gi_lom.dialect'
flatpak install $flatpaks -y