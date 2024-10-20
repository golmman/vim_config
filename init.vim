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
    Plug 'golmman/hurl_vim'

    Plug 'joshdick/onedark.vim'
    "Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'pangloss/vim-javascript'
    Plug 'preservim/nerdtree'
    Plug 'terryma/vim-expand-region'

    Plug 'vim-airline/vim-airline'
    "Plug 'nvim-lualine/lualine.nvim'

    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()

" Colors / onedark
set termguicolors
syntax on
colorscheme onedark
"colorscheme tokyonight

" Background colors for active vs inactive windows
" with ideas from https://caleb89taylor.medium.com/customizing-individual-neovim-windows-4a08f2d02b4e
" Normal bg color is #282c34
hi ActiveWindow guibg=#1e2127
let inactive_window_color = synIDattr(synIDtrans(hlID('Normal')), 'bg')
execute 'hi InactiveWindow guibg=' . inactive_window_color

augroup WindowManagement
  autocmd!
  autocmd WinEnter * call HandleWinEnter()
augroup END

function! HandleWinEnter()
  "setlocal winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow
endfunction

" Background color for todo repo
let g:todo_repo_url = 'github.com/golmman/todo'
let g:todo_repo_bg_color = '#13011e'
let g:todo_repo_sync_timer_interval = 30000
let g:todo_repo_init = '' "'call SetupIde()'

let g:todo_repo_insert_mode = 0

function! SyncTodoRepo(timer_id)
    if g:todo_repo_insert_mode
        return
    endif

    let a = system('git pull')
    let a = system('git add .')
    let a = system('git commit -m "auto update via vim"')
    let a = system('git push')

    " refresh all buffers which have a file name
    let old_confirm = &confirm
    set noconfirm
    let current_buffer = bufnr('%')
    bufdo! if expand('%:p') != '' | edit | endif
    execute 'buffer ' . current_buffer
    redraw
    let &confirm = old_confirm
    unlet old_confirm

    echo 'synced at ' . strftime("%H:%M:%S")
endfunction

function! PauseTodoTimer()
    let g:todo_timer_pause = 1
    call StopTodoTimer()
    call SyncTodoRepo(0)
    echo 'sync paused at ' . strftime("%H:%M:%S")
endfunction

function! UnpauseTodoTimer()
    let g:todo_timer_pause = 0
    call SyncTodoRepo(0)
    call RestartTodoTimer()
endfunction

function StopTodoTimer()
    if exists('g:todo_timer')
        call timer_stop(g:todo_timer)
    endif
endfunction

function! RestartTodoTimer()
    if exists('g:todo_timer_pause') && g:todo_timer_pause
        return
    endif

    call StopTodoTimer()

    let g:todo_timer = timer_start(g:todo_repo_sync_timer_interval, 'SyncTodoRepo', {'repeat': -1})
endfunction

function! SetTodoRepoIntegration()
    let is_git_root = system('git rev-parse --show-toplevel 2>/dev/null') =~ system('pwd')
    if is_git_root
        let is_todo_repo = system('git config --get remote.origin.url') =~ g:todo_repo_url
        if is_todo_repo
            execute 'highlight Normal guibg=' . g:todo_repo_bg_color

            autocmd InsertEnter * let g:todo_repo_insert_mode = 1
            autocmd InsertLeave * let g:todo_repo_insert_mode = 0

            autocmd CursorHold * call RestartTodoTimer()
            autocmd CursorHoldI * call RestartTodoTimer()

            autocmd FocusLost * call PauseTodoTimer()
            autocmd FocusGained * call UnpauseTodoTimer()

            autocmd VimLeavePre * call SyncTodoRepo(0)

            call SyncTodoRepo(0)

            execute g:todo_repo_init
        endif
    endif
endfunction

autocmd VimEnter * call SetTodoRepoIntegration()

"
" LSP Config
"
" see https://github.com/neovim/nvim-lspconfig for general configuration

" Treesitter
lua << EOF
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = {
      "c",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "markdown",
      "markdown_inline",
      "html",
      "css",
      "javascript",
      "typescript",
      "rust",
      "svelte",
      "bash",
      "dockerfile",
      "graphql",
      "hurl",
      "json",
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  ignore_install = { "" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { "" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF

" Typescript
lua require('lspconfig').tsserver.setup {}

" Rust
" neovim 0.9.0 introduces 'semantic token' handling in lsp, which seems not to be compatible with onedark colorscheme
" on_attach solution as documenten, but throws an error...: https://github.com/neovim/neovim/issues/23061
" on_init solution/workaround: https://github.com/neovim/nvim-lspconfig/issues/2542
lua require('lspconfig').rust_analyzer.setup { settings = { ['rust-analyzer'] = {}, }, on_init=function(client) client.server_capabilities.semanticTokensProvider = false end, }

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
"let g:airline_theme='tokyonight-night'

"
" Lualine
"

" see bottom


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

function SetTerminalSize()
    let termids = filter(range(1, bufnr('$')), 'bufexists(v:val) && getbufvar(v:val, "my_term", 0)')
    let termid = termids[0]
    let winids = win_findbuf(termid)
    let winid = winids[0]
    call win_execute(winid, "res 15")
    redraw!
endfunction

function SetupIde()
    " show directory name as title
    set titlestring=nvim\ \|\ %{fnamemodify(getcwd(),\":t\")}\/

    " TODO: work with 'buftype' instead, e.g. https://stackoverflow.com/a/57904110
    below 15sp term://bash | setlocal filetype=terminal | let b:my_term = 1
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

" improve movement in wrapped lines, see https://stackoverflow.com/a/21000307
noremap <expr> j v:count ? 'j' : 'gj'
noremap <expr> k v:count ? 'k' : 'gk'

" global search
autocmd Filetype * nnoremap <buffer> <leader>f :Rg<cr>
autocmd Filetype nerdtree unmap <buffer> <leader>f
autocmd Filetype terminal unmap <buffer> <leader>f

" add terminal buffer
"nnoremap <leader>ht :split 10sp <bar> term<cr>
nnoremap <leader>t :vsplit <bar> term<cr>

" browse terminal command history
tnoremap <a-k> <up>
tnoremap <a-j> <down>
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
vnoremap x "_x
nnoremap c "_c
vnoremap c "_c
nnoremap C "_C
vnoremap C "_C
nnoremap D "_D
vnoremap D "_D
nnoremap d "_d
vnoremap d "_d
vnoremap p pgvy

" cut
nnoremap <leader>x "+x
vnoremap <leader>x "+x
nnoremap <leader>c "+c
vnoremap <leader>c "+c
nnoremap <leader>C "+C
vnoremap <leader>C "+C
nnoremap <leader>d "+d
vnoremap <leader>d "+d
nnoremap <leader>D "+D
vnoremap <leader>D "+D

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
autocmd FileType svelte     nnoremap <buffer> <a-f> :!cd %:h; npx prettier --write %:t<cr>:e<cr>
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

set listchars=trail:·,extends:>,precedes:<,tab:▸\ 
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

" wrap and linebreak
set wrap
set linebreak

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
set autoindent
set expandtab
set shiftwidth=0
set softtabstop=4
set tabstop=4
set smarttab

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

" set size of terminal to a fixed size after window resize
autocmd VimResized * exe ":call SetTerminalSize()"


" Lua hightlighting is broken, so we have to put this at the end of the file for now
" https://github.com/neovim/neovim/issues/20456

"
" Lualine
"

"lua << EOF
"require('lualine').setup(
"{
"    options = {
"        icons_enabled = false,
"        theme = 'auto',
"        component_separators = { left = '', right = ''},
"        section_separators = { left = '', right = ''},
"        disabled_filetypes = {
"            'nerdtree',
"        },
"        ignore_focus = {'nerdtree'},
"        always_divide_middle = true,
"        globalstatus = false,
"        refresh = {
"            statusline = 1000,
"            tabline = 1000,
"            winbar = 1000,
"        }
"    },
"    sections = {
"        lualine_a = {'mode'},
"        lualine_b = {'branch', 'diff', 'diagnostics'},
"        lualine_c = {'filename'},
"        lualine_x = {'encoding', 'fileformat', 'filetype'},
"        lualine_y = {'progress'},
"        lualine_z = {'location'}
"    },
"    inactive_sections = {
"        lualine_a = {},
"        lualine_b = {},
"        lualine_c = {'filename'},
"        lualine_x = {'location'},
"        lualine_y = {},
"        lualine_z = {}
"    },
"    tabline = {
"        lualine_a = {'buffers'},
"        lualine_b = {},
"        lualine_c = {},
"        lualine_x = {},
"        lualine_y = {},
"        lualine_z = {'tabs'},
"    },
"    winbar = {},
"    inactive_winbar = {},
"    extensions = {}
"}
")
"EOF
