# macOS Support

macOS is no longer actively tested as part of these dotfiles.

These files are a collection of the scripts used prior to moving away from macOS completely and are here in case I may need to use it at some point.

If you are looking for the last tested macOS use of these dotfiles look at the v1.0.0 release.

# Installation

## Install iTerm2

Install [iTerm2](https://www.iterm2.com/)

You can optionally install my preferred iTerm2 color scheme (`39digits.itermcolors`). Double click to install. To enable, open iTerm2 → Preferences → Profiles → Colors and select _39digits_ from the color presets drop-down.

Once installation is complete the fonts will also be in place so be sure to change the iTerm font: Open iTerm2 → Preferences → Profiles → Text and set Font to MesloLGS NF.

## Run the installer script

Run `./macos.sh`

## Homebrew install apps

Run `brew bundle` to install all of the apps listed in the `Brewfile` (amend this to meet your own needs).

# iTerm Settings:

Windows:

- Cols: 135 -> 158
- Rows: 35 -> 36

Text:

- 14pt Sauce Code Powerline
- Anti-aliased text; Use thin strokes on Retina;
- Italic text allowed
- Draw bold text in bold font
- Draw bold text in bright colors

Keys:

- **alt-Left**: `Send HEX Codes: 0x1b 0x1b 0x5b 0x44` should be `Send Escape Sequence b`
- **alt-Right**: `Send HEX Codes: 0x1b 0x1b 0x5b 0x43` should be `Send Escape Sequence f`
