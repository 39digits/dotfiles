@echo off
REM -- Some apps require some customisation during the install.
REM -- winget import doesn't allow INTERACTIVE installs yet.
winget install --interactive --id Microsoft.VisualStudio.2022.Community --exact
winget install --interactive --id GnuPG.Gpg4win --exact
