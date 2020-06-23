# 39digits dotfiles

These are dotfiles to get both **MacOS** and **Windows 10 using Ubuntu on WSL2** setup and ready for **JavaScript** and **Node** development.

# Concepts

## Document Everything!

Upon making the decision to make a copy of my dotfiles as a public repo, I took the opportunity to try document everything with as much detail as possible. I'm hoping it will help anybody else looking to start their own dotfiles repo.

## Idempotency

To quote, idemptotency is the property of certain operations in mathematics and computer science whereby they can be applied multiple times without changing the result beyond the initial application.

It's just a fancy word meaning the same operation can be run multiple times with the same result.

I have written these dotfiles so that it can be safely run over and over again without any negative impact. If a step has already been successfully completed then the script will automatically skip this and move to the next.

## Single point of entry

The main script to run is `install.sh`. This pulls in the functions helper file and near the end it includes and runs our boosters (aka personal customisations).

For a default setup that is all that is really required. But where's the fun in being default...

## Customisations through Boosters

Boosters are extra steps we might want to run to really customise the dotfiles to our personal preferences. These rockets will take us from a simple orbit all the way to the moon.

My own boosters file sets some MacOS preferences and some development directories. Both of these are very much personal choice and wouldn't make sense for such opinionated decisions to be part of the default install.

I am however being opinionated with regards to the prompt and vim themes.

# What is installed?

## Default install script

By default these dotfiles will install:

- Homebrew [MacOS only]
- Git
- ZSH
- oh-my-zsh (including helpful ZSH plugins for Node)
- Preferred ZSH prompt (using powerlevel10k)
- Latest version of Node (and nvm)
- A set of commandline tools (e.g. httpie, tree, etc)
- Latest version of vim
- Preferred vim plugins and themes

Any extras or customisations should be included in your own `boosters` file.

## Extra installation scripts

There are some scripts which can be run manually. These are optional and don't form part of the main setup.

- **Brewfile** - a script to install a list of applications in MacOS
- **winget.bat** - a script to install a list of applications in Windows 10
- **vscode/extensions.{sh,bat}** - OS specific scripts to install the preferred Visual Studio Code extensions

# Prerequisites

## MacOS

In **MacOS**:

- Install [iTerm2](https://www.iterm2.com/)

You can optionally install my preferred iTerm2 color scheme (`iterm2/39digits.itermcolors`). Double click to install. To enable, open iTerm2 → Preferences → Profiles → Colors and select _39digits_ from the color presets drop-down.

If you want to continue using Terminal.app then you will need to install the [Terminal.app Nord theme](https://github.com/arcticicestudio/nord-terminal-app/releases) and comment out the line `set termguicolors` in the provided `vim/vimrc` file. This is because Terminal.app is not a truecolor terminal but our vim theme requires truecolor support.

Technically, **Homebrew** is a requirement but this is automatically installed as part of `install.sh` if run on MacOS.

## Windows 10

In **Windows 10**, you will need to first install:

- The new [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701)
- [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and your preferred Linux distro
- [Windows Package Manager](https://github.com/microsoft/winget-cli) aka winget (recommended, but only required to use `winget.bat`)

The primary install script is run within WSL2 as it is tailored to get Linux setup for web development.

### Windows Terminal Settings

I recommend setting the Windows Terminal color theme to `One Half Dark` which comes packaged with Windows Terminal. Set the font to _MesloLGS NF_ (see Fonts section).

I also recommend setting the default Profile to our WSL2 distro. Find out the `guid` by opening the Windows Terminal settings and scrolling down to the Profiles. Find the WSL2 Linux profile and copy the guid. Add this value to a `defaultProfile` key.

We also want to set it so that our Linux home folder is the default location when opening up a WSL2 tab in Terminal. To do this we need to simply set the default starting directory in the WSL2 profile.

Edit `terminal.json` by hitting `Ctrl+,`

```
{
  "defaultProfile": "{the-Ubuntu-guid-goes-here}",
  "profiles": {
    "defaults": {
      // Put settings here that you want to apply to all profiles.
      "colorScheme": "One Half Dark",
      "fontFace": "MesloLGS NF",
      "cursorShape": "vintage",
      "cursorHeight": 100,

    },
    "list": [
      ...
      {
        "guid": "{the-Ubuntu-guid}",
        "hidden": false,
        "name": "Ubuntu",
        "source": "Windows.Terminal.Wsl",
        "startingDirectory": "\\\\wsl$\\Ubuntu\\home\\39digits"
      },
      ...
    ]
  }
}
```

Note that _Ubuntu_ in the `startingDirectory` might be named differently depending on the distro and version you install. For example, it might be _Ubuntu-20.04_.

## Fonts

I recommend the following fonts:

- **For Terminal:** _MesloLGS NF_ powerline font (or any other powerline font of your choice)
- **For Code Editor:** _Source Code Pro for Powerline_ font

Both fonts can be found in the `fonts` directory.

**Windows 10** users will need to manually install these fonts. While, on **MacOS** these will be automatically installed within the provided `boosters` file.

Configure your terminal to use _MesloLGS NF_ as the default font to get the most out of the terminal prompt we install for ZSH.

- **iTerm2**: Open iTerm2 → Preferences → Profiles → Text and set Font to _MesloLGS NF_.
- **Visual Studio Code**: Open File → Preferences → Settings, enter `terminal.integrated.fontFamily` in the search box and set the value to _MesloLGS NF_.
- **Windows Terminal**: Open Settings (Ctrl+,), search for `fontFace` and set value to _MesloLGS NF_ for every profile.

If you don't want to use a Powerline font on the prompt you can run `p10k configure` after installation completes and configure the prompt to not use icons at all.

## General

At a minimum, read the `install.sh` and `boosters.sample` files to familiarise yourself with the specific steps each will take.

If you're curious, also dive into the `functions` file.

Customise the `winget.bat` (Windows 10) or `Brewfile` (MacOS) if you wish to automatically install any GUI apps.

I tried to document everything as thoroughly as possible in case it helps someone new to shell scripts or the concept of dotfiles.

# Steps to Launch

## 1. Clone the repository

Open your terminal and clone this repository.

- **MacOS**: Simply open _iTerm2_ (or _Terminal.app_)
- **Windows 10**: Open a WSL2 tab within _Windows Terminal_

There is no requirement for the location, however I recommend cloning into a `.dotfiles` directory in your home folder.

```
git clone https://github.com/39digits/dotfiles ~/.dotfiles && cd ~/.dotfiles
```

## 2. Create your own Boosters file (Optional)

Create your own `boosters` file in the root to run your own custom steps during the install.

I have provided a sample file that includes the actual custom steps I run. It is named `boosters.sample` to avoid it being run by default as only a file named `boosters` will be included in the main script.

```
cp boosters.sample boosters
```

Open `boosters` and edit it to your liking. There are some variables close to the top of the samples file that you can customise, for example setting your preferred Git username and email will add that to your `~/.gitconfig`.

## 3. Initiate Launch Sequence

We are now ready to launch!

```
./install.sh
```

## 4. Install OS specific applications (Optional)

I have tried to automate as much as possible - including the installation of any GUI applications such as Firefox Developer Edition, Insomnia, etc.

### MacOS (Brewfile)

I have a list of applications I like to install in a `Brewfile`. Edit this list to meet your own needs.

Once it is customised, run it.

```
brew bundle
```

Homebrew would have been installed as part of the main `install.sh` thus making the `brew` command available to us.

### Windows 10 (winget.bat)

Similar to MacOS where I use a Brewfile, I have a list of applications I always install on a Windows machine using the new official Windows Package Manager (winget).

Winget is not yet in v1.0 so there may be some stability issues or packages not quite installing correctly (I had an issue with Insomnia REST client, for example).

Open a **PowerShell** tab inside _Windows Terminal_ (as opposed to a terminal for WSL as used up to this point) and navigate to your dotfiles.

For example:

```
cd \\wsl$\Ubuntu\home\39digits\.dotfiles
```

Once you have customised your own winget.bat, run it.

```
.\winget.bat
```

## 5. Setup Visual Studio Code (Optional)

I use Visual Studio Code as my default code editor. Windows 10's constantly improving integration with WSL2 means we can use Windows applications to directly access our Linux code/filesystem.

Once Visual Studio Code is installed (either as part of the previous step or manually) I automatically install my preferred set of extensions.

On **MacOS** navigate into the `vscode` directory and run `./extensions.sh`

On **Windows 10** while inside PowerShell in Windows Terminal, navigate into the `vscode` directory and run `extensions.bat`

## Acknowledgements

- The design of how sections and steps look was heavily inspired by [slay.sh by Mina Markham](https://slay.sh)
- Huge thank you to [Mathias Bynens MacOS settings](https://github.com/mathiasbynens/dotfiles) in his dotfiles repo
