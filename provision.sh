#!/bin/bash

# Utility functions

# Launch Daemons

# Disable Apple Push Notification Service daemon
# https://apple.stackexchange.com/questions/92214/how-to-disable-apple-push-notification-service-apsd-on-os-x-10-8
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.apsd.plist

# Disable CalendarAgent
launchctl unload -w /System/Library/LaunchAgents/com.apple.CalendarAgent.plist

# Disable NetBIOS daemon (netbiosd)
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.netbiosd.plist

# Disable Location Services (locationd)
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.locationd.plist

# Disable Notification Center
# https://apple.stackexchange.com/questions/106149/how-do-i-permanently-disable-notification-center-in-mavericks
sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist

# Disable QuickLook
# https://superuser.com/questions/617658/quicklooksatellite-mac-os-high-cpu-use
sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.quicklook.*

# Disable Spotlight
# http://osxdaily.com/2011/12/10/disable-or-enable-spotlight-in-mac-os-x-lion/
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist

# Disabling Maverick's Unicast ARP Cache Validation Script (thanks, MMV!)
bash <(curl -Ls http://git.io/6YzLCw)

# Disable Bonjour Script (thanks MMV!)
bash <(curl -Ls http://git.io/q9j5Zw)

# Launch Agents

DISABLE_DIR=/System/Library/LaunchAgentsDisabled
sudo mkdir ${DISABLE_DIR}

# Disable Game Center daemon (gamed)
sudo mv /System/Library/LaunchAgents/com.apple.gamed.plist ${DISABLE_DIR}

# Disable Airplay Mirroring
# http://www.ehcho.com/guide/disable-airplay-mirroring/
sudo mv /System/Library/LaunchAgents/com.apple.AirPlayUIAgent.plist ${DISABLE_DIR}

# Install Applications

# Check for existence, download, and run installer(8) on these apps.

# If VirtualBox's vboxautostart.plist file is available, copy it to 
# the /Library/LaunchDaemons folder and enable it.
#
# Set up the /etc/vbox/autostart.cfg file to just allow all users
# on the OS X host to start virtual machines. (No security here.)
#
# Don't start the autostart just yet though.

VBOX_AUTOSTART_SOURCE=/Applications/VirtualBox.app/Contents/MacOS/org.virtualbox.vboxautostart.plist
VBOX_AUTOSTART_TARGET=/Library/LaunchDaemons/org.virtualbox.vboxautostart.plist

VBOX_AUTOSTARTDB_FOLDER=/Users/vboxautostartdb

if [ -f "${VBOX_AUTOSTART_SOURCE}" ]; then
    echo "Setting up VirtualBox Autostart."

    echo "Create /etc/vbox folder."
    sudo mkdir -p /etc/vbox

    echo "Copy autostart.cfg to /etc/vbox."
    sudo cp autostart.cfg /etc/vbox

    # Appears this is unnecessary on OS X.
    # 
    # echo "Create /Users/vboxautostartdb folder."
    # sudo mkdir -p "${VBOX_AUTOSTARTDB_FOLDER}"
    # sudo chown -Rv root:staff "${VBOX_AUTOSTARTDB_FOLDER}"
    # sudo chmod 1770 "${VBOX_AUTOSTARTDB_FOLDER}"

    echo "Copy ${VBOX_AUTOSTART_SOURCE} to ${VBOX_AUTOSTART_TARGET}."
    sudo cp "${VBOX_AUTOSTART_SOURCE}" "${VBOX_AUTOSTART_TARGET}"
    sudo defaults write "${VBOX_AUTOSTART_TARGET}" Disabled -bool false
    sudo plutil -convert xml1 "${VBOX_AUTOSTART_TARGET}"
    sudo chmod 755 "${VBOX_AUTOSTART_TARGET}"

    # Appears this is unnecessary on OS X, and you'll get an error if you try.
    # 
    # echo "To enable autostarts for a particular user, make sure to run"
    # echo "VBoxManage setproperty autostartdbpath ${VBOX_AUTOSTARTDB_FOLDER}"
    # echo "as that user."
    echo
    echo "To manually start the service, all the autostartable VMs, use the following command:"
    echo "launchctl load /Library/LaunchDaemons/org.virtualbox.vboxautostart.plist"
fi
