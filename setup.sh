# helpers
function echo_ok { echo '\033[1;32m'"$1"'\033[0m'; }
function echo_warn { echo '\033[1;33m'"$1"'\033[0m'; }
function echo_error  { echo '\033[1;31mERROR: '"$1"'\033[0m'; }


# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Creating an SSH key for you..."
ssh-keygen -t rsa -b 4096 -C "dhcrain@gmail.com"

echo_warn "Please add this public key to Github \n"
echo_ok "https://github.com/settings/keys \n"
read -p "Press [Enter] key after this..."

echo_ok "Installing xcode-stuff"
xcode-select --install

sudo xcodebuild -license accept # Accepts the Xcode license

# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo_ok "Installing homebrew... 🍺"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else 
  echo_ok "🍺Homebrew already installed"
fi

echo_ok "Running Brew Doctor... 👨‍⚕️"
brew doctor

# Update homebrew recipes
echo_ok "Updating homebrew..."
brew update

echo_ok "Installing Git..."
brew install git

echo_ok "Git config"
git config --global user.name "Davis Crain"
git config --global user.email dhcrain@gmail.com

echo_ok "installing dotfiles"
git clone https://github.com/JarrodCTaylor/dotfiles.git ~/dotfiles
bash ~/dotfiles/install-scripts/OSX/install-packages.sh
bash ~/dotfiles/install-scripts/OSX/create-symlinks.sh

echo_ok "Installing MAS 👨‍💻"
# https://github.com/mas-cli/mas
brew install mas
read -p "What is your Apple ID email? " appleID
mas signin $appleID

echo_ok "Installing tap caskroom/fonts to Fira-code can be installed🙌"
brew tap caskroom/fonts

echo_ok "Installing apps from Brewfile 🙌"
brew bundle install

brew cask cleanup
brew cleanup

echo_waarn "Open Chrome and set as default browser 💻"
read -p "Press [Enter] once this is done."

echo_ok "Installing Python related items 🐍"
echo " * intalling virturalenv"
sudo pip3 install virtualenv
echo " * installing direnv"
# http://direnv.net/
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> .zshrc

echo_warn "Login to Dropbox and have the Dropbox folder in the $HOME directory."
read -p "Press [Enter] once this is done."

echo_warn "Find the settings for iTerm2 in Dropbox and link each one of these applications with their corresponding settings file. Also setup 1Password to sync with Dropbox."
read -p "Press [Enter] once this is done."

echo_ok "Installing Angular CLI"
npm install -g @angular/cli

# Check FileVault status
echo "--> Checking full-disk encryption status:"
if fdesetup status | grep $Q -E "FileVault is (On|Off, but will be enabled after the next restart)."; then
  echo_ok "OK 👌"
else
  echo_warn "Enabling full-disk encryption on next reboot:"
  sudo fdesetup enable -user "$USER" \
    | tee ~/Desktop/"FileVault Recovery Key.txt"
  echo_ok "OK 👌"
fi

echo_ok "Expanding the save panel by default"
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo_ok "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo_ok "Showing icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

echo_ok "Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo_ok "Setting the icon sizes of Dock items"
defaults write com.apple.dock tilesize -int 34
defaults write com.apple.dock largesize -int 55
defaults write com.apple.dock magnification -bool true

echo_ok "Setting Dock to auto-hide and removing the auto-hiding delay"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

echo_ok "Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo_ok "Show path in finder windows"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true;

killall Dock
killall Finder

echo "Done!"
