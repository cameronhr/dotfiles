A collection of my dotfiles, as well as other customization steps to be taken when setting up a new Linux environment.

## Installation

Assume all repos are to be located in `~/workspace`.

```bash
mkdir -p ~/bin
curl -sL https://github.com/djl/vcprompt/raw/master/bin/vcprompt > ~/bin/vcprompt
chmod 755 ~/bin/vcprompt
mkdir -p  ~/workspace && cd ~/workspace
git clone git@github.com:cameronhr/dotfiles.git
python dotfiles/setup.py
```
On first use of vim: `:PlugInstall`


## Other

1. Correct vim solarized colour display in Terminal:
    Open a Terminal window and modify the Profile (Terminal -> Preferences -> Profiles in Ubuntu 18.04)
    Select 'Solarized Dark' for both 'Text and Background Color' and 'Palette'
2. Bind `Control_L` to `Caps_Lock`:
    Install _Tweaks_ tool: `sudo apt-get install -yq gnome-tweak-tool && gnome-tweaks`
    Click through: 'Keyboard & Mouse -> Additional Layout Options -> Caps Lock behavior'
