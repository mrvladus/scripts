#!/usr/bin/bash

# Build proprietary HPLIP-PLUGIN package needed for some printers including LaserJet 1018/1020

# Install deps
sudo dnf install -y git rpmdevtools crudini

# Clone repo
git clone https://gitlab.com/greysector/rpms/hplip-plugin
cd hplip-plugin

# Setup builddirs
rpmdev-setuptree

# Copy files
cp hplip-plugin.spec ~/rpmbuild/SPECS/
cp *.gpg *.patch ~/rpmbuild/SOURCES/

# Get version
VERSION=$(cat hplip-plugin.spec | grep Version | cut -d' ' -f2-)

# Download sources
curl https://developers.hp.com/sites/default/files/hplip-$VERSION-plugin.run --output ~/rpmbuild/SOURCES/hplip-$VERSION-plugin.run
curl https://developers.hp.com/sites/default/files/hplip-$VERSION-plugin.run.asc --output ~/rpmbuild/SOURCES/hplip-$VERSION-plugin.run.asc

# Start build
rpmbuild -bb ~/rpmbuild/SPECS/hplip-plugin.spec

# Open directory with rpm
xdg-open ~/rpmbuild/RPMS/x86_64/

