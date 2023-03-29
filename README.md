# 39digits dotfiles

These are dotfiles I use with **Windows 11** and **Ubuntu on WSL2** to get a fresh OS install ready for **JavaScript** and **Node** development with a little Game Development thrown in for fun.

## Concepts

### Document Everything!

Upon making the decision to make a copy of my dotfiles as a public repo, I took the opportunity to try document everything with as much detail as possible. I'm hoping it will help anybody else looking to start their own dotfiles repo.

### Idempotency

To quote, idemptotency is the property of certain operations in mathematics and computer science whereby they can be applied multiple times without changing the result beyond the initial application.

It's just a fancy word meaning the same operation can be run multiple times with the same result.

I have written these dotfiles so that it can be safely run over and over again without any negative impact. If a step has already been successfully completed then the script will automatically skip this and move to the next.

### Single point of entry

The main script to run is `install.sh`. This pulls in the functions helper file and near the end it includes and runs our boosters (aka personal customisations).

For a default setup that is all that is really required. But where's the fun in being default...

### Customisations through Boosters

Boosters (set in a `boosters` file) are extra steps we might want to run to really customise the dotfiles to our personal preferences. These rockets will take us from a simple orbit all the way to the moon.

My own boosters file sets my Git user and email and lets me avoid commiting those details to a public repo.

## Installation

### 1. Enable WSL2 and install Linux

To activate WSL2 services in Windows 11 and automatically install the latest Ubuntu LTS, open PowerShell in Windows Terminal and run:

```
wsl --install
```

Check the documentation on [installing WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) if you wish to install a different version of Linux other than Ubuntu LTS.

Once completed you will need to reboot your system. Terminal will automatically open upon login to the newly installed Linux and ask you to setup your new user.

### 2. Clone the dotfiles into Linux

If you don't have it open from the previous step, open Terminal and a tab to your installed Linux distro.

There is no requirement for the location, however I recommend cloning into a `.dotfiles` directory in your home folder.

```
git clone https://github.com/39digits/dotfiles ~/.dotfiles && cd ~/.dotfiles
```

### 3. Read the scripts

At a minimum, read the `install.sh` and `boosters.sample` files to familiarise yourself with the specific steps each will take.

If you're curious, also dive into the `functions` file.

I also make use of [winget](https://github.com/microsoft/winget-cli) to automatically install any GUI apps via JSON files in the `windows` folder.

I tried to document everything as thoroughly as possible in case it helps someone new to shell scripts or the concept of dotfiles.

### 4. Create your own Boosters file (Optional)

Create your own `boosters` file in the root of the dotfiles to run your own custom steps during the install.

I have provided a sample file that includes the actual custom steps I run. It is named `boosters.sample` to avoid it being run by default as only a file named `boosters` will be included in the main script.

```
cp boosters.sample boosters
```

Open `boosters` and edit it to your liking. There are some variables close to the top of the samples file that you can customise, for example setting your preferred Git username and email will add that to your `~/.gitconfig`.

### 5. Initiate Launch Sequence

We are now ready to launch!

```
./install.sh
```

By default these dotfiles will install the following on Ubuntu in WSL2:

- Git (latest version)
- ZSH (latest version)
- oh-my-zsh (including helpful ZSH plugins for Node)
- Preferred ZSH prompt (using powerlevel10k)
- Latest version of Node (via nvm)
- A set of commandline tools (e.g. httpie, tree, etc)
- Latest version of vim
- Preferred vim plugins and themes

Any extras or customisations you included in your own `boosters` file will also be installed as part of the install.

### 6. Install Windows GUI apps (Optional)

The Windows Package Manager (aka winget) allows us to easily and quickly install apps via the commandline. An extra helpful feature is the ability to run an [import command](https://learn.microsoft.com/en-us/windows/package-manager/winget/import) to install all apps within a JSON file.

I have a couple of JSON import files of apps for different purposes that I use to easily decide which apps to install.

To install all my Windows GUI apps, run each of the following.

**General Windows apps:**

```
winget.exe import -i ./windows/winget-apps.json
```

**Development Tools:**

```
winget.exe import -i ./windows/winget-devtools.json
```

**Videogame Development:**

The `import` command doesn't allow for interactive installs yet, so we install Visual Studio 2022 Community as a separate command before running the rest of the videogame development import.

```
winget.exe install --interactive --id Microsoft.VisualStudio.2022.Community --exact
```

This allows us to customise our Visual Studio installation to include C++ and any other modules we may require.

```
winget.exe import -i ./windows/winget-gamedev.json
```

**Gaming:**

```
winget.exe import -i ./windows/winget-gaming.json
```

Note: `winget.exe` is being run from the Linux shell but we get access to Windows commands!

## My preferred app settings

### Fonts

A monospace powerline font is highly recommended to take full advantage of the customisations in the prompt.

These dotfiles include my recommended fonts:

- **For Terminal:** _MesloLGS NF_
- **For Code Editor:** _Source Code Pro for Powerline_

Both fonts can be found in the `fonts` directory which will need to be manually installed. You can open the current folder inside Windows Explorer by typing `explorer.exe .` from the Linux shell.

You will need to manually install these fonts. While, on **MacOS** these will be automatically installed within the provided `boosters` file.

Configure your terminal to use _MesloLGS NF_ as the default font to get the most out of the terminal prompt we install for ZSH. If you don't want to use a Powerline font on the prompt you can run `p10k configure` after installation completes and configure the prompt to not use icons at all.

### Windows Terminal Settings

In Terminal settings find the Linux distro's Profile and edit the Appearance settings. I recommend setting the Windows Terminal color theme to `One Half Dark` which comes packaged with Windows Terminal. Set the font to `MesloLGS NF` (see Fonts section).

I also recommend changing the main Startup settings to use Ubuntu as the _Default Profile_ and to ensure Windows Terminal is set as your _Default Terminal Application_.

## Acknowledgements

- The design of how sections and steps look was heavily inspired by [slay.sh by Mina Markham](https://slay.sh)
- Huge thank you to [Mathias Bynens MacOS settings](https://github.com/mathiasbynens/dotfiles) in his dotfiles repo
