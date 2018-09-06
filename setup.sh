# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Creating an SSH key for you..."
ssh-keygen -t rsa

echo "Please add this public key to Github \n"
echo "https://github.com/settings/keys \n"
read -p "Press [Enter] key after this..."

echo "Installing xcode-stuff"
xcode-select --install

sudo xcodebuild -license accept # Accepts the Xcode license

# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew... 🍺"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Running Brew Doctor... 👨‍⚕️"
brew doctor

# Update homebrew recipes
echo "Updating homebrew..."
brew update

echo "Installing Git..."
brew install git

echo "Git config"
git config --global user.name "Davis Crain"
git config --global user.email dhcrain@gmail.com

echo "installing dotfiles"
git clone https://github.com/JarrodCTaylor/dotfiles.git ~/dotfiles
bash ~/dotfiles/install-scripts/OSX/install-packages.sh
bash ~/dotfiles/install-scripts/OSX/create-symlinks.sh

echo "Open Chrome and set as default browser 💻"
read -p "Press [Enter] once this is done."

echo "Installing MAS 👨‍💻"
# https://github.com/mas-cli/mas
brew install mas
read -p "What is your Apple ID email? " appleID
mas signin $appleID

echo "Installing apps from Brewfile 🙌"
brew bundle install

brew cask cleanup
brew cleanup

echo "Installing Python related items 🐍"
echo " * intalling virturalenv"
sudo pip3 install virtualenv
echo " * installing direnv"
# http://direnv.net/
brew install direnv
echo '"eval $(direnv hook zsh)"' >> .zshrc

echo "Login to Dropbox and have the Dropbox folder in the $HOME directory."
read -p "Press [Enter] once this is done."

echo "Find the settings for iTerm2 in Dropbox and link each one of these applications with their corresponding settings file. Also setup 1Password to sync with Dropbox."
read -p "Press [Enter] once this is done."

echo "Installing Angular CLI"
npm install -g @angular/cli

# Check FileVault status
echo "--> Checking full-disk encryption status:"
if fdesetup status | grep $Q -E "FileVault is (On|Off, but will be enabled after the next restart)."; then
  echo "OK 👌"
else
  echo "Enabling full-disk encryption on next reboot:"
  sudo fdesetup enable -user "$USER" \
    | tee ~/Desktop/"FileVault Recovery Key.txt"
  echo "OK 👌"
fi

echo "Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "Showing icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

echo "Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Setting the icon sizes of Dock items"
defaults write com.apple.dock tilesize -int 34
defaults write com.apple.dock largesize -int 55
defaults write com.apple.dock magnification -bool true

echo "Setting Dock to auto-hide and removing the auto-hiding delay"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

echo "Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

killall Finder

echo "Done!"
