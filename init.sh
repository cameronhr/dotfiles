#!/usr/bin/env bash

# Tell bash to fail immediately on any error as well as unset variables
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

symlink() {
    local SOURCE="${1}"
    local TARGET="${2}"

    # Make sure the parent folder exists before creating the symlink
    mkdir -pv "$(dirname ${TARGET})"

    ln -sf "${SOURCE}" "${TARGET}"
}

# Set-up the dotfile repo
setup_dotfiles() {
    local readonly WORKSPACE="${HOME}/workspace"
    local readonly DOTFILES="${WORKSPACE}/dotfiles"
    mkdir -p "${WORKSPACE}"

    if [[ -d "${DOTFILES}" ]]; then
        echo "dotfiles already cloned, skipping"
    else
        git clone git@github.com:cameronhr/dotfiles.git "${DOTFILES}"
        cd dotfiles
        git checkout updates
    fi

    # Set-up symlinks
    symlink "${DOTFILES}/bash_custom" ~/.bash_custom
    symlink "${DOTFILES}/bash_linux" ~/.bash_linux
    symlink "${DOTFILES}/bash_mac" ~/.bash_mac
    symlink "${DOTFILES}/docker_config.json" ~/.docker/config.json
    symlink "${DOTFILES}/gitconfig" ~/.gitconfig
    symlink "${DOTFILES}/gitignore_global" ~/.gitignore_global
    symlink "${DOTFILES}/tmux.conf" ~/.tmux.conf
    symlink "${DOTFILES}/vim" ~/.vim
    symlink "${DOTFILES}/xmodmap" ~/.xmodmap

    # Mac-only symlinks
    if ! grep -Fxq 'source ~/.bash_custom' "${HOME}/.bashrc"; then
        echo 'source ~/.bash_custom' >> "${HOME}/.bashrc"
    fi
    if ! grep -Fxq 'source ~/.bash_custom' "${HOME}/.profile"; then
        echo 'source ~/.bash_custom' >> "${HOME}/.profile"
    fi
}

setup_virtualenv() {
    local default_venv="${HOME}/.virtualenvs/default"
    if [[ -d ${default_venv} ]]; then
        echo "default virtualenv exists, skipping" && return 0
    fi
    python3 -m venv ${default_venv}
    source ${default_venv}/bin/activate
    python3 -m pip install -U pip ipython click black isort flake8 bandit
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    source ${default_venv}/bin/activate
}

install_packages() {
    if [[ $(uname) == "Darwin" ]]; then
        if ! which brew &> /dev/null; then
            echo 'Installing `brew` package manager: https://brew.sh/'
            echo 'Requires user password'
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.profile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        brew install \
            bash \
            bash-completion \
            git \
            mosh \
            python3 \
            tmux \
            vim
        brew install --cask -f \
            rectangle \
            docker

        # Note: Homebrew has different prefixes for Apple Silicon and Intel-based macs
        # brew_bash="/usr/local/bin/bash"
        brew_bash="/opt/homebrew/bin/bash"
        echo "Adding ${brew_bash} to /etc/shells if not present"
        grep ${brew_bash} /etc/shells &>/dev/null || echo ${brew_bash} | sudo tee -a /etc/shells
        [[ ${SHELL} = ${brew_bash} ]] || chsh -s ${brew_bash} $(whoami | xargs echo -n)

    else
        # Currently only working for Debian and Ubuntu based distros
        if grep -qE "Ubuntu|Debian|Raspbian" /etc/issue; then
            echo "Installing required packages"
            sudo -E apt-get update
            sudo -E apt-get install -yq \
                bash-completion \
                curl \
                git \
                python3 \
                python3-pip \
                python3-venv \
                tmux \
                vim-nox
        fi
    fi
}

init() {
    install_packages

    # Set vim as default system editor on Linux
    [[ $(uname) == "Linux" ]] && sudo update-alternatives --set editor /usr/bin/vim.nox

    # Get my public keys on the machine
    mkdir -p "${HOME}/.ssh"
    curl -L https://github.com/cameronhr.keys >> "${HOME}/.ssh/authorized_keys"

    # Add ssh agent to system keychain on first unlock
    ssh_agent_config="AddKeysToAgent yes"
    grep "${ssh_agent_config}" ~/.ssh/config &>/dev/null || echo "${ssh_agent_config}" >> ~/.ssh/config

    setup_virtualenv
    setup_dotfiles

    echo "Installing vim plugins"
    vim +'PlugInstall --sync' +qall > /dev/null

    echo "setup complete, run 'source ~/.bashrc' to source changes"
}

init "$@"
