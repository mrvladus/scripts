#!/bin/bash
flatpaks='org.mozilla.firefox org.qbittorrent.qBittorrent org.gnome.Boxes org.gnome.Calculator org.gabmus.gfeeds io.github.celluloid_player.Celluloid org.onlyoffice.desktopeditors org.gnome.gThumb app.drey.Dialect org.kde.krita org.gimp.GIMP com.mattjakeman.ExtensionManager org.inkscape.Inkscape org.godotengine.Godot org.gnome.FileRoller org.gnome.Evince org.telegram.desktop org.gnome.TextEditor com.github.johnfactotum.Foliate'

flatpak install $flatpaks -y