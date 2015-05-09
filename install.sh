#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then

   cp -R vim ~/.vim
   cp vimrc ~/.vimrc
   cp tmux.conf ~/.tmux.conf
   cp bash_aliases ~/.bash_aliases
   cp shell_prompt.sh ~/.shell_prompt

   sudo cp -R vim /root/.vim
   sudo cp vimrc /root/.vimrc
   sudo cp tmux.conf /root/.tmux.conf
   sudo cp bash_aliases /root/.bash_aliases
   sudo cp shell_prompt.sh /root/.shell_prompt

   git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
   sudo git clone https://github.com/gmarik/Vundle.vim.git /root/.vim/bundle/Vundle.vim

   vim +PluginInstall +qall
   sudo vim +PluginInstall +qall
   exit 1
fi

echo 'dont run as sudo ;)'
