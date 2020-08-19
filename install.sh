#!/usr/bin/env bash

# The assumption is that this will be run on a system that contains Bash.

# It is good practise to handle errors and provide some feedback to the user.
handle_exit_code() {
  # $? is a bash variable that stores the result of the last executed command.
	# A value of 0 means it was successful, so any result that is not 0 failed.
  ERROR_CODE="$?";
  # This is a good place to do any kind of cleanup code you might want to run
  # regardless of the exit type.
  #
  # We just want to handle error exit codes though, so we check if the return code
  # is NOT equal (ne) to 0 signifying it was not a success (0 = success)
  if [ $ERROR_CODE -ne 0 ]; then
    # You might sometimes see printf called with --.
    #
    # A double dash ( -- ) signifies the end of command options and anything
    # after it will be used as positional parameters. Therefore running
    #    printf -- "--- My header ---"
    # tells printf to stop looking for options after the double dashes and it
    # takes "--- My header ---" as the first positional parameter.
    # For printf the positional parameter is format (aka the string to print)
    #
    # If we did not use double dash and the string to print contains a single dash
    # then printf will try to use what follows as an option. This will likely
    # throw an error and inform you it is an invalid option for the printf command.
    #
    # For example:
    #   This would error: printf "-"
    #   This would error: printf "-----------"
    #   This would work: printf -- "-----------"
    #   This would also work due to the leading space: printf " -----------"
    #
    # The double dashes are also sometimes used for safety to ensure no accidental
    # (or malicious?) options are sent to the command being run.
    printf -- "\n\033[31m LAUNCH SEQUENCE ABORTED.\033[0m\nExiting with error code ${ERROR_CODE}.\n";
    exit ${ERROR_CODE};
  fi
}
# We set a trap - which sounds nefarious but is actually very helpful.
# A trap looks for a particular signal (in our case we look for the EXIT signal)
# and then runs the function (or command) specified after the `trap` command.
# In our instance we run the `handle_exit_code` on any EXIT signal.
#
# There are a number of less generalised signal types. If you're curious
# you can read more https://www-uxsup.csx.cam.ac.uk/courses/moved.Building/signals.pdf
trap "handle_exit_code" EXIT;
# Any error after running `set -e` will trigger an EXIT signal.
# This means that the script will terminate at the point or error instead of
# continuing to run subsequent steps.
# There may be reasons where you would want a script to continue after an error
# in which case you can use `set +e`.
set -e

###############################################################################
# Settings and Preferences
###############################################################################
# Lets break this command down into its numerous parts.
# Assume that we have installed the dotfiles to /home/rando/.dotfiles.
# We cannot rely only on pwd as we could invoke our script using an absolute
# path from anywhere on our system. We want the full path to the script's location.
#
# $0 is the command exactly as it was called from the command line.
# For example if we ran install.sh from the directory within which it is contained,
# then $0 would be ./install.sh (a single dot signifies the current location in the file system).
# But if we ran install.sh from somewhere else on our system and used a full path
# to the script, then $0 might be something like /home/rando/.dotfiles/install.sh
#
# Next up, dirname returns the directory portion of the value contained in $0.
#
# We therefore use cd to first change into the script's location and only then run a pwd.
# We can now be confident we have the full absolute path to where our install script can be found.
DOTFILES_DIR=$(cd $(dirname $0) && pwd)


###############################################################################
# Source any required files
###############################################################################
# We first check that the required functions file exists.
# If not exit with an error.
if [ -f "functions" ]; then
  source functions
else
  printf -- "\n\033[31mThe required file `./functions` cannot be found.\033[0m\n";
  exit 1
fi
###############################################################################
# Launch sequence initiated.
###############################################################################
launch_banner

###############################################################################
# Prerequisites
###############################################################################
section "Launch Readiness"

# Here we handle any OS-specific prerequisites for our install script.
# If it is MacOS we will want to install homebrew (https://brew.sh/)
# or if it is Ubuntu we might want to run an apt update
if is_macos; then
  # ----- First check if homebrew is installed
  # We used to first check that XCode CLI tools were installed, but the latest
  # brew install scripts looks for any dependencies and kicks off the installation
  # thus saving us an extra step :)
  if ! command_exists brew; then
    step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    # Make the brew path available immediately for the rest of this script.
    # Otherwise we would need to explicitly call via the full path or start a fresh
    # shell session which would kill the rest of our script from runnning.
    export PATH="/usr/local/bin:$PATH"
    echo_success "Homebrew installed!"
  else
    echo_safe_skip "Homebrew already installed. Skipping."
  fi
else
  # ----- Update Ubuntu package lists
  sudo apt-get update
fi

###############################################################################
# GIT
###############################################################################
section "Git"

if is_macos; then
  step "Installing git"
  install_brew_package git
else
  sudo add-apt-repository ppa:git-core/ppa
  sudo apt-get update
  sudo apt install git
  if [ $? -eq 0 ]; then
    echo_success "Latest version of git successfully installed."
	else
		echo_error "The latest version of git could not be installed."
	fi
fi

# Symlink git global_ignore to home directory
# The install script will also symlink to our preferred global ignore file.
# This includes items that I never want to accidentally include in a commit
# that don't neeed to be part of a project's `.gitignore` file. These
# include `.DS_Store` or `Thumbs.db` for example.
#
# It's always good to have a .gitignore inside of your project to ensure
# project specific things like node_modules are ignored. If you put project
# level items in your global ignore instead and someone collaborated on
# your project without a .gitignore they might accidentally commit unwanted
# files / folders.
step "Creating global_ignore symlink in home directory"
create_symlink $DOTFILES_DIR/git/gitignore_global ~/.gitignore_global

# Copy the gitconfig template into our home directory.
# We don't symlink it in as we'll want this file in the git repository
# should we make any changes we would want to keep available by default.
# But at the same time we don't want to commit our username and email
# address to the public repository.
# Don't worry - we'll set the name and email in the post-install.
step "Copy gitconfig into home directory"
copy_file $DOTFILES_DIR/git/gitconfig ~/.gitconfig

###############################################################################
# ZSH
###############################################################################
section "ZSH"

# There are different types of shell sessions and these determine the files
# that are loaded upon the start of that shell session.
#
# The types include:
# - login
# - interactive
# - non-login
# - non-interactive
#
# To keep this simple, interactive is a shell session where you, the user, can
# interact with the shell via commands you type in at the prompt. Login refers
# to the system identifying you by your login (if you SSH into a system you have
# to log into it first; on MacOS or Windows 10 you are already logged into your
# user account).
#
# Most of your usage will likely be in an interactive login shell. For example,
# if you open the terminal program in either MacOS or Windows 10 WSL2 you enter
# into an interactive login session.
#
# If you load another shell (e.g. /bin/bash) after your login shell session has started
# you may be in an interactive, non-login state. But we're talking about configuring
# zsh and making it the default so switching to another shell altogether is beside the point.
#
# ZSH will load files in a specific order based on the type of shell session.
# ZSH will also only load certain files based on the type so not all are loaded up.
#
# The order within which files are sourced/read are as follows:
# -------
# .zshenv
# [Sourced: Always]
# This file is always sourced regardless of the type of session. As the name implies
# it is most commonly used to set any environment variables that may be required.
# Be warned though that this file is sourced even if zsh is used to run just a quick,
# single command using the -c option as is done by other tools (e.g. make). As such any
# changes you make to this file may have a further reaching impact so be cautious.
# -------
# .zprofile
# [Sourced: Login]
# There might be a tendency to want to put everything inside of your .zshrc file
# by default and that is often the advice given. It has merit in that it keeps things
# simple and you'll always know where to look.
#
# Personally, I put most things inside of .zshrc but use .zprofile for two main categories:
#   - Paths
#   - User Commands
#
# An example of a user command is to run the `rbenv init` command if it is installed.
# -------
# .zshrc
# [Sourced: Interactive]
# You will make most of your changes and customisations within your ~/.zshrc file.
# These would include:
# * Prompt
# * Command completions
# *
# I use oh-my-zsh which is a helpful framework for managing ZSH configurations. It also
# includes many helpful plugins that you can easily activate. It is within .zshrc that
# you source oh-my-zsh and set any plugins you wish to use.
#
# Normally you would put Aliases inside your .zshrc file but oh-my-zsh allows us
# to create aliases and keep our .zshrc file clean. When using Oh My ZSH, aliases are loaded
# from ~/.oh-my-zsh/custom/aliases.zsh.
# For a full list of active aliases (be those set by yourself or any plugins),
# simply run `alias` from your terminal.
# -------
# .zlogin
# [Sourced: Login]
# The official zsh documentation states that `.zlogin' is not the place for alias definitions,
# options, environment variable settings, etc. As a general rule, it should not change the
# shell environment at all.  Rather, it should be used to set the terminal type and run
# a series of external commands (fortune, msgs, etc).
#
# So its a good place to show a message to the user upon login or output a fortune piped through cowsays.
# -------
# .zlogout
# [Sourced: Logging out of a Login shell session]
# Any kind of clean-up you may want to run upon logging out. I don't use this file locally.

# Start by installing the latest version of ZSH on our system
step "Installing ZSH"
if is_macos; then
# It seems that using brew install of zsh on MacOS Catalina throws an error
# about insecure directories and files when running compinit required by the
# zsh-completions plugin for oh-my-zsh.
# It won't show an error until you open a fresh instance of zsh but there
# is an easy solution to fix things.
# Simply run:  compaudit | xargs chmod g-w
  install_brew_package zsh
else
  sudo apt-get install zsh
fi

# Install oh-my-zsh which is a handy framework for enhancing zsh
step "Installing oh-my-zsh"
# You could run the official install script to get Oh-My-ZSH on your machine.
# But I find it requires a few too many extra steps to get right in the context
# of continuing to run through our entire script.
#
# One of the issues with using the official ohmyzsh install script is that,
# by default, the script will run `zsh -l` after all steps are complete.
# This will start a fresh instance of the zsh shell after it installs everything.
# We definitely do not want this as it will terminate our dotfiles script and
# nothing else beyond that point will get installed.
# Thankfully, there is a toggle for that behaviour by setting RUNZSH=no (the default is yes).
#
# That solves one problem, but the install script will want a .zshrc file to exist
# in our user's home directory. We have our own .zshrc file that we symlink into place
# after intalling ohmyzsh.
#
# We could set KEEP_ZSHRC=yes (default no) but this only keeps an existing .zshrc file.
# If one doesn't exist at all at this stage the automated ohmyzsh install script
# will use a default template and create a ~/.zshrc for us.
# This would cause our step to symlink our own .zshrc to fail as the destination
# for the link already exists thanks to the ohmyzsh install script.
#
# You might wonder why we don't symlink our own zshrc file into place before running
# the ohmyzsh install script. And that's a good question.
# That will solve the issue of using its zshrc template instead of our settings.
# But we reference some plugins that aren't yet installed in our zshrc file.
# If we try to install those custom plugins ahead of running the script then installation
# will stop since the ~/.oh-my-zsh folder now exists (custom plugins go into ~/.oh-my-zsh/custom/plugins/).
# We could solve this by letting the install script run and create its own zshrc
# file from the template and then just `rm ~/.zshrc` before we symlink our own into place.
# But that just seems a bit pointless when we can just do a manual install using git clone.
#
# KEEP_ZSHRC=yes RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
clone_git_repo git://github.com/ohmyzsh/oh-my-zsh.git ~/.oh-my-zsh

# Clone oh-my-zsh plugins
# The plugins below are a good mix but feel free to add any of your own preferences.
# Just don't forget to also add it to the plugins activation within the ~/.zshrc config.
step "Install oh-my-zsh plugins"
clone_git_repo https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
clone_git_repo https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
clone_git_repo https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
clone_git_repo https://github.com/lukechilds/zsh-nvm ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm
clone_git_repo https://github.com/lukechilds/zsh-better-npm-completion ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-better-npm-completion

# Create symlinks for zsh and oh-my-zsh files.
# The reason we use symlinks here instead of copying is to ensure any future updates we make
# can be committed back to our repository ensuring any changes are always ready to roll out
# on a clean installation.
step "Create symlinks for zsh and oh-my-zsh files in home directory"
create_symlink $DOTFILES_DIR/zsh/zshrc ~/.zshrc
create_symlink $DOTFILES_DIR/zsh/zshenv ~/.zshenv
create_symlink $DOTFILES_DIR/zsh/zprofile ~/.zprofile
create_symlink $DOTFILES_DIR/zsh/aliases.zsh ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/aliases.zsh

# I use powerlevel10k (not to be confused with powerlevel9k).
# p10k is an incredibly fast command prompt (especially compared to 9k)
# and is very, very customisable.
#
# I have a very minimal theme on purpose - I much prefer to keep the prompt
# as pure and clean as possible. The prompt itself is across two lines with
# the top line showing most of the information about the current directory
# and any version control information (if relevant). You will see a line break
# ahead of the prompt display to keep a little extra space between each command
# to make parsing the command line a little quicker. Unlike many themes, I keep
# it lean without much visual noise.
#
# If my prompt isn't to your liking, run `p10k configure` in the commandline to
# run through the configuration wizard yourself. You'll be amazed at the options!
#
# Read up more at https://github.com/romkatv/powerlevel10k
step "Installing ZSH theme"
clone_git_repo https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k "--depth=1"
# If installing powerlevel10k, there is a window text reflow issue affecting all themes
# with prompts using the right side of the screen. This is not a powerlevel10k bug
# but affects all prompt themes / frameworks that put data on the right side. This is because
# it has to pad the line to reach the right side of thhe viewport leading to odd reflow
# behaviour when resizing the screen.  If you resize and it looks weird, just `clear`.
# If it really, really bothers you, the fix for powerlevel10k is to run
# p10k configure and choose "Disconnected" when asked about Prompt Connection.
# Then open ~/.p10k.zsh and either comment out all elements of
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS or move them to POWERLEVEL9K_LEFT_PROMPT_ELEMENTS.

# I used to use a theme of my own. Left here for posterity.
# create_symlink $DOTFILES_DIR/zsh/39digits.zsh-theme ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/themes/39digits.zsh-theme

step "Create symlinks for powerlevel10k prompt"
create_symlink $DOTFILES_DIR/zsh/p10k.zsh ~/.p10k.zsh

# We need to check that:
# 1. ZSH is available in our path,
# 2. ZSH is in our shell list
# 3. Set ZSH to be the default shell.
# So we start by checking that ZSH is actually in the path. If not we don't go any further
# and let the user know that they might have some tasks to fix manually.
if DOTFILES_ZSH=$(which zsh); then

	step "Add ZSH to shells"
	# Next up check that the ZSH from our path is actually in our available shells file.
	# I'm not checking for specific systems and their shell locations since both
	# MacOS and Ubuntu keep this in /etc/shells but your own usage may vary.
  DOTFILES_SHELLS="/etc/shells"
	#
	# grep arguments:
	# -F, --fixed-strings
	#        Interpret PATTERN as a list of fixed strings, separated by  new-
	#        lines, any of which is to be matched.
	# -x, --line-regexp
	#        Select only those matches that exactly match the whole line.
	# -q, --quiet, --silent
	if ! grep -qxF "$DOTFILES_ZSH" "$DOTFILES_SHELLS"; then
		echo $DOTFILES_ZSH | sudo tee -a $DOTFILES_SHELLS
		echo_success "ZSH added to $DOTFILES_SHELLS\n"
	else
		echo_error "ZSH already in $DOTFILES_SHELLS\n"
	fi

	# Set zsh as default shell.
	step "Set ZSH as default"
	# chsh -s /usr/local/bin/zsh >/dev/null
	chsh -s $DOTFILES_ZSH > /dev/null
	# $? is a bash variable that stores the result of the last executed command.
	# A value of 0 means it was successful, so any result that is not 0 failed.
	if [ $? -eq 0 ]; then
		export SHELL="$DOTFILES_ZSH"
    echo_success "Default shell set to $DOTFILES_ZSH"
	else
			echo_error "chsh could not change your default shell. You will need to do so manually."
	fi
else
	echo_error "ZSH does not appear to be installed."
fi

###############################################################################
# # Node
# ###############################################################################
section "Web Development - Node"

# It is worth noting that we make use of the zsh-nvm plugin to make managing
# and upgrading nvm easier. One advantage is that the plugin auto-installs nvm
# upon starting a shell instance if nvm has not yet been installed. We aren't
# starting a fresh shell instance just yet - we have more script to run!
# So we'll manually install nvm now to allow us to install node and some
# global packages.
step "Installing Node via nvm"
if [ $(dir_does_not_exist "${HOME}/.nvm") ]; then
  # There is an automatic install script available
  # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  # However it tries to add some lines to your .zshrc file which aren't required
  # given we are using the zsh-nvm plugin instead. To avoid these extra lines
  # being added we can simply clone the repo at the latest tag
  # git clone https://github.com/nvm-sh/nvm.git ~/.nvm --branch v0.35.3
  clone_git_repo "https://github.com/nvm-sh/nvm.git" "${HOME}/.nvm" "--branch v0.35.3"
  echo_success "nvm installed"
else
  echo_safe_skip "nvm already installed"
fi

# Create ~/.nvm folder
# step "Create ~/.nvm directory"
# create_dir "$HOME/.nvm"
# Done by the install script.

# Link default-packages for use by nvm.
# Any packages listed will be globally installed by default.
# This happens any time we install a new version of node using NVM which
# makes it super easy to ensure the global packages you depend upon
# are always installed and ready to go. You no longer need to manually
# install those making it even easier to switch between node versions on the fly.
#
# Potential default-packages candidates:  https://github.com/sindresorhus/awesome-nodejs
step "Create symlink for default-packages"
create_symlink $DOTFILES_DIR/node/default-packages ~/.nvm/default-packages

# Ensure it's accessible on the path for this terminal session
step "Sourcing nvm for current terminal session"
# source $(brew --prefix nvm)/nvm.sh
# Time to source nvm for the rest of our session. This helps us not need
# to open a new shell tab. It is also required to source nvm for us to be
# able to run the nvm commands below from within this shell script.
# !! Please note: This is also something we would put into our .zshrc file
# if we were not using the zsh-nvm plugin as it sources nvm for use in terminal.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
echo_success "nvm sourced for current session"

# ////////////////////////////
# DOTFILES_NVM_NODE_CURRENT="$(nvm current || false)"
# DOTFILES_NVM_WHICH="$(nvm which current || false)"
# DOTFILES_NODE_CURRENT="$(node -v || false)"
# DOTFILES_NODE_WHICH="$(which node || false)"
# ////////////////////////////

# First set it to "none" by default as if nvm has not yet installed
# a version of node, running nvm current will throw an error - something
# that will definitely be the case on the first run of this script.
DOTFILES_NVM_NODE_CURRENT="none"
if [ $(nvm current) ]; then
  DOTFILES_NVM_NODE_CURRENT="$(nvm current)"
fi
# You might be tempted to check if this returns empty.
# if [[ ! -z $DOTFILES_NVM_NODE_CURRENT ]]; then
# But if there is no current node version, nvm returns "none"
# with an EXIT code of 0 since it wasn't in error
if [[ $DOTFILES_NVM_NODE_CURRENT == "none" ]]; then
  # Use nvm to install latest node version.
  # This should also take our default-packages into account.
  step "Install latest node using nvm"
  nvm install node &>/dev/null
  # TODO: Check for actual success
  echo_success "Node installed via nvm"

  # Set default node version for nvm
  step "Set latest node as default system version"
  nvm use node &>/dev/null
  # For reference:
  # nvm run node --version
  echo_success "Now using Node $(node -v)!"
else
  echo_safe_skip "nvm version of Node already installed."
fi

# Now that we have node installed lets copy our npmrc file into place.
# This is the config file for npm. The npmrc in this repository is
# here for you to enter your own configuration and defaults.
step "Copy .npmrc to home directory"
copy_file $DOTFILES_DIR/node/npmrc ~/.npmrc

###############################################################################
# General command line tools
###############################################################################
section "Command-line tools"

step "Installing command-line tools"
if is_macos; then
  install_brew_package coreutils
  install_brew_package findutils
  install_brew_package ack
  install_brew_package autoconf
  install_brew_package automake
  install_brew_package tree
  install_brew_package wget --with-iri
  install_brew_package openssl
  install_brew_package httpie
else
  sudo apt-get install httpie
  sudo apt-get install tree
fi

###############################################################################
# Vim
###############################################################################
section "Vim - let's hope we can quit!"

# MacOS does not support true colour mode so we will replace the default version
# We also update Ubuntu to use the latest though too.
step "Install latest version of Vim"
if is_macos; then
  install_brew_package vim
else
  sudo add-apt-repository ppa:jonathonf/vim
  sudo apt-get update
  sudo apt install vim
  if [ $? -eq 0 ]; then
    echo_success "Latest Vim successfully installed."
	else
		echo_error "The latest version of Vim could not be installed."
	fi
fi

step "Creating ~/.vim directories"
create_dir "$HOME/.vim"
create_dir "$HOME/.vim/bundle"
create_dir "$HOME/.vim/colors"

if [ -d $HOME/.vim ]; then
  chmod -R 0755 $HOME/.vim
fi

# Install Vundle
step "Install Vundle (vim extension manager)"
clone_git_repo https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Create symlinks for home files.
step "Create symlinks for .vimrc and plugin list"
create_symlink $DOTFILES_DIR/vim/vimrc ~/.vimrc
create_symlink $DOTFILES_DIR/vim/plugins.vim ~/.vim/plugins.vim

# Install vim themes.
step "Install vim themes via symlinks"
create_symlink $DOTFILES_DIR/vim/nord.vim ~/.vim/colors/nord.vim
# create_symlink $DOTFILES_DIR/vim/atom-dark.vim ~/.vim/colors/atom-dark.vim
# create_symlink $DOTFILES_DIR/vim/material-theme.vim ~/.vim/colors/material-theme.vim

# Install vim plugins
step "Install vim plugins"
vim +PluginInstall +qall
echo_success "vim plugins installed"


###############################################################################
# Custom boosters...
###############################################################################
# Not everybody's setup will be the same and there will be a few items you
# require that we wouldn't want to keep in the general default list.
# Perhaps you like to have MongoDB installed on your machine whereas someone
# else prefers to run these through Docker instead.
# Or perhaps you would like to add Ruby to your installation?
# The boosters file is the place to put all those little specific extras.
if [ -e "boosters" ]; then
  source "boosters"
fi


###############################################################################
# LAUNCH IS GO!
###############################################################################
section "Post Launch Checklist"
if is_macos; then
  echo_info "Run the Brewfile (brew bundle)"
  echo_info "Install Visual Studio Code extensions (vscode/extensions.sh)"
  echo_info "Install & set iTerm2 themes from iterm2 folder"
  echo_info "ZSH might need you to run (only once): compaudit | xargs chmod g-w"
else
  echo_info "Install fonts"
  echo_info "Run winget.bat from PowerShell"
  echo_info "Copy Visual Studio Code settings (vscode/settings.json)"
  echo_info "Install Visual Studio Code extensions in PowerShell (vscode/extensions.bat)"
  echo_info "Install Spicetify via Powershell"
  # Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/khanhas/spicetify-cli/master/install.ps1" | Invoke-Expression
fi
# PowerToys keymaps for Windows
# - Shift+2 = Shift+'
# - Shift+' = Shift+2
# - Win+Q = Alt+F4
# - Win+W = Ctrl+W
# - Win+T = Ctrl+T

# It is good to exit our script with a newline to ensure their prompt is not
# awkwardly tacked onto the end of our last output line.
printf "\n${green}LAUNCH SEQUENCE COMPLETE.${reset}\n\n";
# We also explicitly exit with a success code of 0.
# As a developer it always feels weird to use 0 as success code
# given how 0 is a falsey value in the languages I use in coding day to day.
exit 0;