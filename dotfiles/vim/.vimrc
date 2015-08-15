execute pathogen#infect()

let g:airline#extensions#branch#enabled = 1

set t_Co=256
color wombat

set runtimepath^=~/.vim/bundle/ctrlp.vim

set laststatus=2
let g:airline_theme = 'powerlineish'
if !exists('g:airline_powerline_fonts')
    " Use the default set of separators with a few customizations
    let g:airline_left_sep=' ›'  " Slightly fancier than '>'
    let g:airline_right_sep='‹ ' " Slightly fancier than '<'
endif

autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
