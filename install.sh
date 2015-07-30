#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then

   cp -R vim ~/.vim
   cp vimrc ~/.vimrc
   cp tmux.conf ~/.tmux.conf
   cp bash_aliases ~/.bash_aliases
   cp shell_prompt.sh ~/.shell_prompt
   cp tmux_prompt.sh ~/.tmux_prompt

   git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

   vim +PluginInstall +qall

   echo 'install the fuck!'
   pip install thefuck
   exit 1
fi

echo 'install for root user'

cp -R vim /root/.vim
cp vimrc /root/.vimrc
cp tmux.conf /root/.tmux.conf
cp bash_aliases /root/.bash_aliases
cp shell_prompt.sh /root/.shell_prompt
cp tmux_prompt.sh /root/.tmux_prompt

git clone https://github.com/gmarik/Vundle.vim.git /root/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

echo 'install the fuck!'
pip install thefuck
