#!/usr/bin/env bash

# Tell bash to fail immediately on any error as well as unset variables
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Define global directory paths
readonly home_dir="${HOME}"
readonly workspace_dir="${home_dir}/workspace"
readonly dotfiles_dir="${workspace_dir}/dotfiles"
readonly ssh_dir="${home_dir}/.ssh"
readonly local_bin_dir="${home_dir}/.local/bin"
readonly config_dir="${home_dir}/.config"

symlink() {
    local source="${1}"
    local target="${2}"

    # Remove any existing symlink at the target
    # Prevents creating a symlink loop
    if [[ -L "${target}" ]]; then
        rm "${target}"
    fi

    echo "Creating symlink from: ${source} to: ${target}"
    if [[ -e "${target}" ]]; then
        echo "Target ${target} exists and points to $(readlink "${target}" || echo "non-symlink")."
    fi

    # Make sure the parent folder exists before creating the symlink
    mkdir -pv "$(dirname "${target}")"

    ln -sf "${source}" "${target}"
}

install_prerequisites() {
    echo "Installing prerequisites"

    if [[ $(uname) == "Linux" ]]; then
        sudo -E apt-get -yqq update > /dev/null
        sudo -E apt-get -yqq install \
            curl \
            git \
            > /dev/null
    fi
    if [[ $(uname) == "Darwin" ]]; then
        # On MacOS, install and use brew package manager
        if ! which brew &>/dev/null; then
            echo 'Installing brew package manager: https://brew.sh/'
            echo 'Requires user password'
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    fi
}

setup_dotfiles() {
    mkdir -p "${workspace_dir}"

    if [[ -d "${dotfiles_dir}" ]]; then
        echo "dotfiles already cloned, skipping"
    else
        git clone git@github.com:cameronhr/dotfiles.git "${dotfiles_dir}"
        cd "${dotfiles_dir}"
        git checkout updates
    fi
}

setup_symlinks() {
    symlink "${dotfiles_dir}/aliases" "${home_dir}/.aliases"
    symlink "${dotfiles_dir}/bash_custom" "${home_dir}/.bash_custom"
    symlink "${dotfiles_dir}/gitconfig" "${home_dir}/.gitconfig"
    symlink "${dotfiles_dir}/gitignore_global" "${home_dir}/.gitignore_global"
    symlink "${dotfiles_dir}/tmux.conf" "${home_dir}/.tmux.conf"
    symlink "${dotfiles_dir}/vim" "${home_dir}/.vim"
    symlink "${dotfiles_dir}/nvim" "${config_dir}/nvim"
    symlink "${dotfiles_dir}/mise.toml" "${config_dir}/mise/config.toml"
    symlink "${dotfiles_dir}/wezterm/wezterm.lua" "${home_dir}/.wezterm.lua"

    # Add sourcing of ~/.bash_custom to .bashrc and .profile if not present
    for file in "${home_dir}/.bashrc" "${home_dir}/.profile"; do
        if ! grep -Fxq 'source ~/.bash_custom' "$file"; then
            echo 'source ~/.bash_custom' >> "$file"
        fi
    done
}

setup_system() {
    if [[ $(uname) == "Darwin" ]]; then
        if ! which brew &> /dev/null; then
            echo 'Installing `brew` package manager: https://brew.sh/'
            echo 'Requires user password'
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${home_dir}/.profile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        echo "Installing packages with brew"
        brew install \
            bash \
            bash-completion \
            colima \
            docker \
            git \
            mosh \
            pgcli \
            python3 \
            raycast \
            ripgrep \
            shellcheck \
            stylua \
            tmux

        brew install --cask -f \
            wezterm

        if [[ $(uname -m) == "arm64" ]]; then
            brew_bash="/opt/homebrew/bin/bash"
        else
            brew_bash="/usr/local/bin/bash"
        fi
        echo "Adding ${brew_bash} to /etc/shells if not present"
        grep "${brew_bash}" /etc/shells &>/dev/null || echo "${brew_bash}" | sudo tee -a /etc/shells
        [[ ${SHELL} = ${brew_bash} ]] || chsh -s "${brew_bash}" "$(whoami | xargs echo -n)"
        
        ssh_agent_config="AddKeysToAgent yes"
        grep "${ssh_agent_config}" "${ssh_dir}/config" &>/dev/null || echo "${ssh_agent_config}" >> "${ssh_dir}/config"
    else
        # Currently only working for Debian and Ubuntu based distros
        if grep -qE "Ubuntu|Debian|Raspbian" /etc/issue; then
            echo "Installing required packages"
            
            # Add wezterm repo and install
            curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/wezterm-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/wezterm-archive-keyring.gpg] https://apt.fury.io/wez/ * *" | sudo tee /etc/apt/sources.list.d/wezterm.list
            sudo apt-get update

            sudo -E apt-get install -yq \
                bash-completion \
                curl \
                git \
                mosh \
                pgcli \
                python3 \
                python3-pip \
                ripgrep \
                shellcheck \
                tmux \
                wezterm

            # Install mise using their official install script
            if ! which mise &> /dev/null; then
                curl https://mise.run | sh
            fi
        fi
    fi
}

setup_mise() {
    # Install mise from their install script
    curl --no-progress-meter https://mise.run | sh

    eval "$("${local_bin_dir}/mise" activate bash)"
    mise trust "${config_dir}/mise/config.toml" || echo "No global mise config, not trusting"

    mise use -g node@22.12.0 || mise use -g node@latest

    mise plugin add usage
    mise use -g python@3.12

    mise install -y neovim
    mise use -g neovim

    if [[ -f "${config_dir}/mise/config.toml" ]]; then
        mise exec python -- python3 -m pip install \
            ipython \
            pynvim \
            requests
    fi
}

init() {
    install_prerequisites

    # Get my public keys on the machine
    mkdir -p "${ssh_dir}"
    curl -L https://github.com/cameronhr.keys >> "${ssh_dir}/authorized_keys"

    setup_dotfiles
    setup_system
    setup_symlinks
    setup_mise

    echo "Setup complete. Please run 'source ~/.bashrc' to apply changes."
}

# When piping in from stdin (eg curl), BASH_SOURCE[0] will be unset, and
# when executing via ./init.sh or bash init.sh, BASH_SOURCE[0] and ${0}
# will be equal
if [ "${BASH_SOURCE[0]}" == "${0}" ] || [ -z "${BASH_SOURCE[0]}" ]; then
  # Tell bash to fail immediately on any error as well as unset variables
  set -eu -o pipefail
  init "$@"
fi
