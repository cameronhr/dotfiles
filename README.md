A collection of my dotfiles, as well as other customization steps to be taken when setting up a new Linux environment.

## Installation

The following assumes all repos are to be located in `~/workspace`.

Copy / paste the following script into a terminal to install initial packages, clone this repo, and execute `setup.py`.

```
# Continue on failure
set +e
# Install dependencies and my essential packages
sudo apt install -y curl &&\
sudo apt install -y git &&\
sudo apt install -y python &&\
sudo apt install -y python3-pip &&\
sudo apt install -y tmux &&\
sudo apt install -y vim &&\
pip3 install virtualenv &&\
virtualenv -p python3 ~/.virtualenvs/default &&\
source ~/.virtualenvs/default/bin/activate &&\
mkdir -p ~/bin &&\
curl -sL https://github.com/djl/vcprompt/raw/master/bin/vcprompt > ~/bin/vcprompt &&\
chmod 755 ~/bin/vcprompt &&\
mkdir -p  ~/workspace && cd ~/workspace &&\
git clone git@github.com:cameronhr/dotfiles.git || echo &&\
python dotfiles/setup.py &&\
source ~/.bash_custom &&\
vim tmp_pluginstall -c "PlugInstall|qa!"
```


## Other

1. Correct vim solarized colour display in Terminal:
    Open a Terminal window and modify the Profile (Edit -> Preferences -> Profiles in Ubuntu 18.04)
    Select 'Solarized Dark' for both 'Built-in schemes' and 'Palette'
2. Bind `Control_L` to `Caps_Lock`:
    Install _Tweaks_ tool: `sudo apt-get install -yq gnome-tweak-tool && gnome-tweaks`
    Click through: 'Keyboard & Mouse -> Additional Layout Options -> Caps Lock behavior'
