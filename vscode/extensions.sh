#!/usr/bin/env bash

source ../functions.sh

###############################################################################
# Visual Studio Code
###############################################################################
if [ if_macos ]; then
  section "Visual Studio Code"

  step "Installing Visual Studio Code"
  if ! [ $(brew cask list | grep -w visual-studio-code) ]; then
    # Brew cask install Visual Studio Code editor
    brew cask install visual-studio-code
  fi
    # For reference:
    # To install VSCode packages using CLI
    # code --list-extensions
    # code --install-extension ms-vscode.cpptools
    # code --uninstall-extension ms-vscode.csharp

    step "Installing Visual Studio Code extensions"
    # Advanced New File
    code --install-extension patbenatar.advanced-new-file
    # Anchorage Theme
    code --install-extension 39digits.anchorage-vscode-theme
    # Auto-close Tag
    code --install-extension formulahendry.auto-close-tag
    # Dark Bliss Reloaded (Theme)
    code --install-extension rootix.dark-bliss-reloaded
    # Debugger for Chrome
    code --install-extension msjsdiag.debugger-for-chrome
    # Debugger for Firefox
    code --install-extension firefox-devtools.vscode-firefox-debug
    # Docker
    code --install-extension ms-azuretools.vscode-docker
    # DotEnv .env syntax highlighting
    code --install-extension mikestead.dotenv
    # ESLint
    code --install-extension dbaeumer.vscode-eslint
    # Git Graph
    code --install-extension mhutchie.git-graph
    # Import Cost
    code --install-extension wix.vscode-import-cost
    # Liqube Dark Theme
    code --install-extension liqube.theme-liqube-dark
    # Latest TypeScript and JavaScript Grammar
    # code --install-extension ms-vscode.typescript-javascript-grammar
    # MDX syntax highlighting
    code --install-extension silvenon.mdx
    # Path Intellisense
    code --install-extension christian-kohler.path-intellisense
    # Prettier
    code --install-extension esbenp.prettier-vscode
    # Remote Development package by Microsoft - used mostly for WSL
    # code --install-extension ms-vscode-remote.vscode-remote-extensionpack
    # Tailwind CSS class name completions
    code --install-extension bradlc.vscode-tailwindcss
    # Visual Studio IntelliCode - AI enhanced IntelliSense
    code --install-extension visualstudioexptteam.vscodeintellicode

    # ========= PHP EXTENSIONS
    # PHP Intelephense
    # code --install-extension bmewburn.vscode-intelephense-client
    # PHP CS fixer
    # code --install-extension junstyle.php-cs-fixer
    # Laravel Blade Syntax highlighting
    # code --install-extension onecentlin.laravel-blade

    # ========= HONOURABLE MENTIONS
    # Github Pull Requests
    # code --install-extension github.vscode-pull-request-github
    # Support for .editorconfig files
    # code --install-extension EditorConfig.EditorConfig
    # Mono Debug
    # code --install-extension ms-vscode.mono-debug
    # Nord (Dark Theme)
    # code --install-extension arcticicestudio.nord-visual-studio-code
    # Peacock - Change UI colour when switching Workspaces (root folders within same workspace not currently supported)
    # code --install-extension johnpapa.vscode-peacock

    create_symlink $HOME/.dotfiles/packages/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
  else
    print_success_muted "Visual Studio Code already installed. Skipping."
  fi
###############################################################################
else
  print_error "This script should only be run on MacOS. If using Windows and WSL2 please run the extensions.bat instead."
fi