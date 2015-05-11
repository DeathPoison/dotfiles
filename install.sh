#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then

   cp -R vim ~/.vim
   cp vimrc ~/.vimrc
   cp tmux.conf ~/.tmux.conf
   cp bash_aliases ~/.bash_aliases
   cp shell_prompt.sh ~/.shell_prompt
   cp tmux_prompt.sh ~/.tmux_prompt

   git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>/dev/null

   mkdir ~/git 2>/dev/null # install new fonts - for powerline
   mkdir ~/git/EXTERNAL 2>/dev/null
   git clone https://github.com/powerline/fonts.git ~/git/EXTERNAL/fonts 2>/dev/null
   cd ~/git/EXTERNAL/fonts/
   ./install.sh
   sudo fc-cache -f -v 1>/dev/null

   vim +PluginInstall +qall
   exit 1
fi

echo 'install for root user'

cp -R vim /root/.vim
cp vimrc /root/.vimrc
cp tmux.conf /root/.tmux.conf
cp bash_aliases /root/.bash_aliases
cp shell_prompt.sh /root/.shell_prompt
cp tmux_prompt.sh /root/.tmux_prompt

sudo git clone https://github.com/gmarik/Vundle.vim.git /root/.vim/bundle/Vundle.vim
sudo vim +PluginInstall +qall

exit 1
