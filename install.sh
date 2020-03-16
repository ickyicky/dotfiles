#! /bin/bash
#

# create cache for zsh, install it and switch to it
mkdir -f .cache .cache/zsh

# clone vundle vim plugin and install all plugins
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim -c PluginInstall q

