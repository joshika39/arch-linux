#!/bin/bash

if [ "$EUID" -ne 0 ]
    then echo "must run as root"
        exit
fi

if [[ ! -d /etc/pacman.d/hooks/nvidia.hook ]]
then
    mkdir /etc/pacman.d/hooks
    touch /etc/pacman.d/hooks/nvidia.hook
fi

printf "[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
# Change the linux part above and in the Exec line if a different kernel is used
 
[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'\n"| sudo tee -a /etc/pacman.d/hooks/nvidia.hook > /dev/null

echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf

printf "Section \"OutputClass\"
Identifier \"intel\"
MatchDriver \"i915\"
Driver \"modesetting\"
EndSection
 
Section \"OutputClass\"
Identifier \"nvidia\"
MatchDriver \"nvidia-drm\"
Driver \"nvidia\"
Option \"AllowEmptyInitialConfiguration\"
ModulePath \"/usr/lib/nvidia/xorg\"
ModulePath \"/usr/lib/xorg/modules\"
EndSection" >> /etc/X11/xorg.conf.d/20-nvidia.conf



