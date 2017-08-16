# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin directories
PATH="$HOME/bin:$HOME/.local/bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"

gsettings set org.gnome.desktop.default-applications.terminal exec 'st -t "Suckless Terminal" -g "256x256"'
# gsettings reset org.gnome.shell enabled-extensions
gsettings set org.gnome.shell enabled-extensions ['clipboard-indicator@tudmotu.com', 'native-window-placement@gnome-shell-extensions.gcampax.github.com', 'nohotcorner@azuri.free.fr', 'pixel-saver@deadalnix.me', 'pomodoro@arun.codito.in', 'drive-menu@gnome-shell-extensions.gcampax.github.com', 'suspend-button@laserb', 'TopIcons@phocean.net', 'multi-monitors-add-on@spin83']

if [ -e /home/anpryl/.nix-profile/etc/profile.d/nix.sh ]; then . /home/anpryl/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
