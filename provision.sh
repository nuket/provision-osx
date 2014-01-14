#!/bin/bash

# Launch Daemons

# Disable Apple Push Notification Service daemon
# https://apple.stackexchange.com/questions/92214/how-to-disable-apple-push-notification-service-apsd-on-os-x-10-8
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.apsd.plist

# Disable Spotlight
# http://osxdaily.com/2011/12/10/disable-or-enable-spotlight-in-mac-os-x-lion/
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist

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
