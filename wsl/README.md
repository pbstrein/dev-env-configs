# Purpose
This directory contains all the configuration I use for Windows Subsystem for Linux (WSL).

## Manual Changes

### Remove Bell sound
https://stackoverflow.com/questions/36724209/disable-beep-in-wsl-terminal-on-windows-10
1. `sudo vim /etc/inputrc`
2. Uncomment / add `set bell-style none`
3. Add `set visualbell` in `~/.vimrc`
4. Add `export LESS=$LESS -R -Q" in  your `~/.profile` file.
