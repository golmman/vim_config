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
    Plug 'cespare/vim-toml'
    Plug 'evanleck/vim-svelte'
    Plug 'hashivim/vim-terraform'
    Plug 'joshdick/onedark.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'pangloss/vim-javascript'
    Plug 'preservim/nerdtree'
    Plug 'simrat39/rust-tools.nvim'
    Plug 'terryma/vim-expand-region'
    Plug 'vim-airline/vim-airline'
call plug#end()

" Colors / onedark
set termguicolors
syntax on
colorscheme onedark

" Typescript
" https://terminalroot.com/how-to-configure-lsp-for-typescript-in-neovim/
lua require('lspconfig').tsserver.setup {}

" Rust Tools
lua require('rust-tools').setup({})

"
" NERDTree
"

let NERDTreeShowHidden=1

autocmd FileType nerdtree nmap <buffer> <CR> go

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

"
" Airline
"

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = '  '
let g:airline#extensions#tabline#left_alt_sep = '█'
let g:airline#extensions#tabline#formatter = 'jsformatter'
let g:airline_theme='onedark'

"
" vim-expand-region
"

" 0 means non-recursive expansion, 1 means with recursion
" see :h object-select for the list of possible values
" note that 'iw: 1' conflicts with braces
" e.g. in '{ {a: 1}}' the word select is '{a:'
let g:expand_region_text_objects = {
      \ 'iw'  :0,
      \ 'i''' :1,
      \ 'i"'  :1,
      \ 'i`'  :1,
      \ 'i>'  :1,
      \ 'i]'  :1,
      \ 'i}'  :1,
      \ 'i)'  :1,
      \ 'it'  :1,
      \ 'a''' :1,
      \ 'a"'  :1,
      \ 'a`'  :1,
      \ 'a>'  :1,
      \ 'a]'  :1,
      \ 'a}'  :1,
      \ 'a)'  :1,
      \ 'at'  :1,
      \ }

"""""""""""""
" Functions "
"""""""""""""

function SetupIde()
    " show directory name as title
    set titlestring=nvim\ \|\ %{fnamemodify(getcwd(),\":t\")}\/

    " TODO: work with 'buftype' instead, e.g. https://stackoverflow.com/a/57904110
    below 15sp term://bash | setlocal filetype=terminal
    NERDTree
endfunction

function DestroyIde()
    set titlestring=nvim\ \|\ %f

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

function ToggleModifiable()
    if &modifiable
        set nomodifiable
    else
        set modifiable
    endif
endfunction

function DeleteCurrentBuffer()
    let current_buffer = bufnr('')
    bnext
    execute 'bd ' . current_buffer
endfunction

function CloseHiddenBuffers()
    let buffers = nvim_list_bufs()
    for buffer in buffers
        if getbufinfo(buffer)[0].hidden == 1
            silent exec 'bw' buffer
        endif
    endfor
    silent redrawtabline
endfunction

""""""""""""""""""""""""""""
" Keys / Bindings / Remaps "
""""""""""""""""""""""""""""

let g:mapleader = ','

nnoremap <f4> :call ToggleIde()<cr>
nnoremap <a-space> :call ToggleModifiable()<cr>

" testing stuff
"nnoremap <a-x> :echo getbufinfo(bufnr(''))[0].listed<cr>

" trigger code completion
inoremap <c-space> <c-x><c-o>

" global search
autocmd Filetype * nnoremap <buffer> <leader>f :Rg<cr>
autocmd Filetype nerdtree unmap <buffer> <leader>f
autocmd Filetype terminal unmap <buffer> <leader>f

" add terminal buffer
"nnoremap <leader>ht :split 10sp <bar> term<cr>
nnoremap <leader>t :vsplit <bar> term<cr>

" browse terminal command history
tnoremap <c-p> <up>
tnoremap <c-n> <down>
tnoremap <esc> <c-\><c-n>

" navigate windows
tnoremap <c-h> <c-\><c-N><c-w>h
tnoremap <c-j> <c-\><c-N><c-w>j
tnoremap <c-k> <c-\><c-N><c-w>k
tnoremap <c-l> <c-\><c-N><c-w>l
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" cycle through buffers
"nnoremap <a-h> :bprev<cr>
"nnoremap <a-l> :bnext<cr>
autocmd Filetype * nnoremap <buffer> <a-h> :bprev<cr>
autocmd Filetype nerdtree unmap <buffer> <a-h>
autocmd Filetype terminal unmap <buffer> <a-h>

autocmd Filetype * nnoremap <buffer> <a-l> :bnext<cr>
autocmd Filetype nerdtree unmap <buffer> <a-l>
autocmd Filetype terminal unmap <buffer> <a-l>

noremap <silent> <a-p> :call DeleteCurrentBuffer()<cr>
nnoremap <silent> <a-o> :call CloseHiddenBuffers()<cr>

" switch buffer
" https://2.bp.blogspot.com/-d1GaUBk-Y10/TyFhskmCYRI/AAAAAAAAARQ/CIEx1V7FLqg/s640/vim-and-vigor-004-flying_is_faster_than_cycling.png
nnoremap <leader>l :ls<cr>:b<space>

" vim loses track of syntax sometimes...
" https://github.com/vim/vim/issues/2790
" see also: https://stackoverflow.com/questions/27235102/vim-randomly-breaks-syntax-highlighting
nnoremap m :syntax sync fromstart<cr>
autocmd BufEnter * syntax sync fromstart

" fold/unfold
nnoremap zz za

" clear search highlights
nnoremap <backspace> :nohls<cr>

" insert blank line in normal mode
nnoremap <enter> o<esc>

" differentiate 'cut' and 'delete'
" thanks to https://stackoverflow.com/a/30423919/5460583

" delete/overwrite
nnoremap x "_x
nnoremap c "_c
nnoremap C "_C
vnoremap c "_c
nnoremap d "_d
nnoremap D "_D
vnoremap d "_d
vnoremap p pgvy

" cut
nnoremap <leader>c "+c
nnoremap <leader>C "+C
vnoremap <leader>c "+c
nnoremap <leader>d "+d
nnoremap <leader>D "+D
vnoremap <leader>d "+d

" lsp
inoremap <silent> <a-q> <cmd>lua vim.lsp.buf.signature_help()<cr>
nnoremap <silent> <a-w> <cmd>lua vim.lsp.buf.hover()<cr>
nnoremap <silent> <a-e> <cmd>lua vim.lsp.buf.code_action()<cr>
nnoremap <silent> <a-r> <cmd>lua vim.lsp.buf.rename()<cr>

" movement with static cursor
nnoremap <m-j> Mj<c-e>
nnoremap <m-k> Mk<c-y>

" expand visual selection
map <m-,> <Plug>(expand_region_shrink)
map <m-.> <Plug>(expand_region_expand)

" formatter
autocmd FileType css        nnoremap <buffer> <a-f> :!cd %:h; npx prettier --write %:t<cr>:e<cr>
autocmd FileType html       nnoremap <buffer> <a-f> :!cd %:h; npx prettier --write %:t<cr>:e<cr>
autocmd FileType javascript nnoremap <buffer> <a-f> :!cd %:h; npx prettier --write %:t<cr>:e<cr>
autocmd FileType json       nnoremap <buffer> <a-f> :!cd %:h; npx prettier --write %:t<cr>:e<cr>
autocmd FileType markdown   nnoremap <buffer> <a-f> :!cd %:h; npx prettier --write %:t<cr>:e<cr>
autocmd FileType python     nnoremap <buffer> <a-f> :!cd %:h; python3 -m black %:t<cr>:e<cr>
autocmd FileType rust       nnoremap <buffer> <a-f> :!rustfmt +nightly %<cr>:e<cr>
autocmd FileType svg        nnoremap <buffer> <a-f> :!cd %:h; npx prettier --write %:t<cr>:e<cr>
autocmd FileType vue        nnoremap <buffer> <a-f> :!cd %:h; npx prettier --write %:t<cr>:e<cr>
autocmd FileType terraform  nnoremap <buffer> <a-f> :!cd %:h; terraform fmt %:t -no-color<cr>:e<cr>
autocmd FileType typescript nnoremap <buffer> <a-f> :!cd %:h; npx prettier --write %:t<cr>:e<cr>
autocmd FileType yaml       nnoremap <buffer> <a-f> :!cd %:h; npx prettier --write %:t<cr>:e<cr>

" linter
autocmd FileType python     nnoremap <buffer> <a-c> :!cd %:h; python3 -m flake8 %:t<cr>
autocmd FileType sh         nnoremap <buffer> <a-c> :!shellcheck %<cr>
autocmd FileType rust       nnoremap <buffer> <a-c> :!cargo clippy -- -W clippy::all<cr>
autocmd FileType javascript nnoremap <buffer> <a-c> :!cd %:h; npx eslint %:t<cr>
autocmd FileType terraform  nnoremap <buffer> <a-c> :!cd %:h; terraform validate -no-color<cr>

"""""""""
" Other "
"""""""""

set listchars=trail:·,extends:>,precedes:<,tab:→→
set list
set signcolumn=yes
set wildmenu
set showcmd
set scrolloff=2
set laststatus=2
set number
set colorcolumn=80
set hidden
set title
set titlestring=nvim\ \|\ %f
let g:markdown_folding = 1

" show cursorline only in active window
augroup BgHighlight
    autocmd!
    autocmd WinEnter * set cursorline
    autocmd WinLeave * set nocursorline
augroup END

" disable mouse
set mouse=

" code completion
set completeopt=menuone,noselect

" search
set incsearch
set hlsearch
set ignorecase
set smartcase

" autosave
set updatetime=200
autocmd CursorHold * :wa

" hide / unlist terminal buffer
autocmd TermOpen * if bufwinnr('') > 0 | setlocal nobuflisted | endif

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

" splits
set splitbelow
set splitright

" indent
filetype plugin indent on
set expandtab
set shiftwidth=4
set softtabstop=4

" indent / tab width based on file type (prettier defaults to 2)
autocmd FileType javascript setlocal shiftwidth=2 softtabstop=2 expandtab
autocmd FileType json       setlocal shiftwidth=2 softtabstop=2 expandtab
autocmd FileType markdown   setlocal shiftwidth=2 softtabstop=2 expandtab
autocmd FileType typescript setlocal shiftwidth=2 softtabstop=2 expandtab

" use the clipboard as the only register
set clipboard=unnamedplus

" filetypes
autocmd BufEnter * if &filetype == "" | setlocal ft=unknown | endif
autocmd TermOpen * set ft=terminal
autocmd BufNewFile,BufRead *.vue set filetype=html
autocmd BufNewFile,BufRead *. set filetype=sh
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" prevent automatic comments when pressing 'o' or 'O'
" this needs to be set after plugins set their options
autocmd FileType * setlocal formatoptions-=c formatoptions-=o
