A collection of my dotfiles, as well as other customization steps to be taken when setting up a new OSX or Linux environment.

## Installation

You can pipe the install script directly to bash with the following: 

`curl -fL https://raw.githubusercontent.com/cameronhr/dotfiles/main/init.sh | bash`

Run it from the directory that you want the dotfiles repo cloned into.

## Other

Ubuntu:

1. Bind `Control_L` to `Caps_Lock`:
    Install _Tweaks_ tool: `sudo apt-get install -yq gnome-tweak-tool && gnome-tweaks`
    Click through: 'Keyboard & Mouse -> Additional Layout Options -> Caps Lock behavior'

OS X:

1. Remap caps lock to ctrl: System Preferences -> Keyboard -> Modifier Keys
2. Turn off the dumb Force Click / haptic feedback garbage in the trackpad: System Preferences -> Trackpad
