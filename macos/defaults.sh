#!/bin/bash

echo "Applying macOS UI & system preferences..."

########################
# Appearance – Dark Mode
########################
# Disable automatic Light/Dark switching
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool false

# Enable Dark Mode
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

# Optional: reduce transparency (cleaner UI)
defaults write com.apple.universalaccess reduceTransparency -bool true

########################
# Finder
########################
# Enables display of hidden files in Finder (e.g. .git, .env, .ssh)
defaults write com.apple.finder AppleShowAllFiles -bool true

########################
# Keyboard
########################

# Fast key repeat (developer friendly)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15

########################
# Storage & Cleanup
########################

# Automatically remove items from Trash after 30 days
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

########################
# Dock
########################

# Automatically hides the Dock when not in use
defaults write com.apple.dock autohide -bool true

########################
# Restart affected services
########################
# Restarts the Dock and Finder to apply changes
killall Dock || true
killall Finder || true
killall SystemUIServer || true
