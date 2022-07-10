if !has('nvim')
  echo 'this .vimrc is optimized for nvim, so it is not sourced here'
  finish
endif

"""""""""""
" Plugins "
"""""""""""

" auto install vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
  Plug 'preservim/nerdtree'
  Plug 'vim-airline/vim-airline'
  Plug 'joshdick/onedark.vim'

  " rust
  Plug 'neovim/nvim-lspconfig'
  Plug 'simrat39/rust-tools.nvim'
call plug#end()

"
" Colors / onedark
"

set termguicolors
syntax on
colorscheme onedark

"
" Rust Tools
"

lua require('rust-tools').setup({})

"
" NERDTree
"

autocmd FileType nerdtree nmap <buffer> <CR> go

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

"
" Airline
"

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='onedark'

"""""""""""""
" Functions "
"""""""""""""

function SetupIde()
  below 10sp term://bash
  NERDTree
endfunction

function DestroyIde()
  NERDTreeClose
  bw! term://
endfunction

function ToggleIde()
  let g:is_ide_active = exists('g:is_ide_active') ? !g:is_ide_active : 0
  if g:is_ide_active
    call DestroyIde()
  else
    call SetupIde()
  endif
endfunction

""""""""""""""""""""""""""""
" Keys / Bindings / Remaps "
""""""""""""""""""""""""""""

let g:mapleader = ','

nnoremap <f4> :call ToggleIde()<cr>

" add terminal buffer
nnoremap <leader>t :below 10sp term://bash<cr>i

" navigate windows
tnoremap <c-h> <C-\><C-N><C-w>h
tnoremap <c-j> <C-\><C-N><C-w>j
tnoremap <c-k> <C-\><C-N><C-w>k
tnoremap <c-l> <C-\><C-N><C-w>l
nnoremap <c-h> <C-w>h
nnoremap <c-j> <C-w>j
nnoremap <c-k> <C-w>k
nnoremap <c-l> <C-w>l

" cycle through buffers
nnoremap <a-h> :bprev<cr>
nnoremap <a-l> :bnext<cr>

" switch buffer
" https://2.bp.blogspot.com/-d1GaUBk-Y10/TyFhskmCYRI/AAAAAAAAARQ/CIEx1V7FLqg/s640/vim-and-vigor-004-flying_is_faster_than_cycling.png
nnoremap <leader>l :ls<cr>:b<space>
tnoremap <Esc> <C-\><C-n>

"""""""""
" Other "
"""""""""

set listchars=trail:·,extends:>,precedes:<,tab:→→
set list
set cursorline
set signcolumn=yes
set wildmenu
set showcmd
set scrolloff=2
set laststatus=2

" autosave
set updatetime=200
autocmd CursorHold * :wa

" hide / unlist terminal buffer
autocmd TermOpen * if bufwinnr('') > 0 | setlocal nobuflisted | endif

" directories for swap files and backup
set directory=$HOME/.vim/swapfiles//
set backupdir=$HOME/.vim/backup//

" automatically update buffers that where change externally (eg. git)
" autoread by itself does not work in terminal, see https://stackoverflow.com/a/20418591/5460583
set autoread
au FocusGained,BufEnter * :checktime

" folding / code collapse
" open/close fold: zo/zc
set foldmethod=indent
set foldlevelstart=20

" matching brackets
set showmatch
set matchtime=2
hi MatchParen cterm=bold,underline ctermbg=none ctermfg=none


