" Prep things on first run.
let firstrun=0
if !filereadable(expand("~/.vim/autoload/plug.vim"))
    let firstrun=1
    silent !mkdir -p ~/.vim/{autoload,undo,backups}
    silent !wget -O ~/.vim/autoload/plug.vim
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

"Plugins
call plug#begin('~/.vim/plugged')
Plug 'PeterRincker/vim-argumentative'
Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'vim-utils/vim-husk'
Plug 'michaeljsmith/vim-indent-object'
Plug 'vasconcelloslf/vim-interestingwords'
Plug 'nanotech/jellybeans.vim'
Plug 'junegunn/limelight.vim'
Plug 'andymass/vim-matchup'
Plug 'junegunn/vim-peekaboo'
Plug 'zweifisch/pipe2eval'
Plug 'unblevable/quick-scope'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'github/copilot.vim'

" Auto install plugins on first run
call plug#end()
if 1 == firstrun
    :PlugInstall
endif

" Plugin configurations
let g:ale_linters = {'python': ['pycodestyle', 'flake8', 'mypy', 'pylint']}
let g:ale_python_pycodestyle_options = '--max-line-length=120'
let g:ale_python_pylint_options = '--max-line-length=120'
nmap <expr> <C-j> &diff ? ']c' : ':ALENext<cr>'
nmap <expr> <C-k> &diff ? '[c' : ':ALEPrevious<cr>'

inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

nnoremap <Leader>( :RainbowParentheses!!<CR>
let g:acp_behaviorKeywordLength = 2

let g:yankstack_map_keys = 0
call yankstack#setup()
nmap <C-p> <Plug>yankstack_substitute_older_paste
nmap <C-n> <Plug>yankstack_substitute_newer_paste

" Buffers
set hidden
set path+=**
set autoread
set autochdir
set tabpagemax=32
set switchbuf=usetab

" History
set history=10000
set viminfo='100,%
set backup
set writebackup
set backupdir=~/.vim/backups
set undofile
set undodir=~/.vim/undo
set modeline

" Format
set smarttab
set expandtab
set shiftround
set shiftwidth=4
set softtabstop=4
set tabstop=4
set autoindent
set nosmartindent
set indentkeys-=-<Return>
set backspace=indent,eol,start
set formatoptions=tcqnj
set wrap
set linebreak
set showbreak=↳
set breakindent
set isfname-=\=
set cursorline
set cursorcolumn

" UI
set ignorecase
set smartcase
set wildmenu
set wildmode=longest:full,full
set wildignorecase
set completeopt=longest,menu
set omnifunc=syntaxcomplete#Complete
set incsearch
set hlsearch
set ruler
set number
set showcmd
set showmode
set scrolloff=999
set shortmess=aoTW
set laststatus=1
set list listchars=tab:»\ ,trail:•,extends:↜,precedes:↜,nbsp:°

" Use ag if available
if executable('ag')
    set grepprg=ag\ --vimgrep
endif

"Maps, abrvs, commands
nnoremap Y y$
nnoremap <Space> <PageDown>
nnoremap <Backspace> <PageUp>
nnoremap <CR> :nohlsearch<CR><CR>
nnoremap gf :e <cfile><CR>
nnoremap <Leader>gf :split <cfile><CR>
nnoremap <Leader>s :setlocal spell!<CR>
nnoremap <Leader>b :b#<CR>
nnoremap <Leader>B :Buffers<CR>
nnoremap <Leader>f :set foldexpr=getline(v:lnum)!~@/<CR>:set foldmethod=expr<CR><Bar>zM
nnoremap <Leader>F :grep! <C-r>=substitute("<C-r>/", "[><]", "", "g")<CR><CR>:copen<CR>
nnoremap <Leader>r :w<CR>:! <C-r>=expand("%:p")<CR><CR>
nnoremap <expr> <Leader>h "hebrew" == &keymap ? ':Noheb<CR>' : ':Heb<CR>'
nnoremap <expr> <Leader>n &nu == &rnu ? ':setlocal nu!<CR>' : ':setlocal rnu!<CR>'
nnoremap <expr> <Leader>z 0 == &scrolloff ? ':setlocal scrolloff=999<CR>' : ':setlocal scrolloff=0<CR>'
nnoremap ?? o<Esc>:.!howdoi <c-r>=expand(&filetype)<CR><Space>

inoremap jj <ESC>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-g>u\<Tab>"
inoremap <F5> <Esc>:w<CR>:! <C-r>=expand("%:p")<CR><CR>

vnoremap <Right> >gv
vnoremap <Left> <gv
vnoremap . :normal .<CR>
vnoremap ` :normal @a<CR>

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap %% <C-r>=expand("%:p:h") . '/' <CR>

command! Q q
command! Mks wa | mksession! ~/.vim/.session
command! Lds source ~/.vim/.session
command! Heb setlocal rightleft | setlocal rightleftcmd | setlocal keymap=hebrew | inoremap -- ־| inoremap --- –| call matchdelete(nonansi)
command! Noheb setlocal norightleft | setlocal rightleftcmd= | setlocal keymap= | let nonansi = matchadd('Error', '[^\d0-\d127]')
command! Lowtag %s/<\/\?\u\+/\L&/g
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis

" Enable arrows for visitors
nnoremap <Up> gk
nnoremap <Down> gj
inoremap <Up> <C-o>gk
inoremap <Down> <C-o>gj

" autocommands
filetype plugin indent on
augroup mine
    au!

    " Return to last position
    au BufReadPost * normal `"

    " Folding
    au BufReadPost * set foldmethod=indent
    au BufReadPost * normal zR
    au InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
    au InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif


    " Many ftplugins override formatoptions, so override them back
    au BufReadPost,BufNewFile * setlocal formatoptions=tcqnj

    " Hebrew
    au BufReadPost,BufNewFile ~/heb/* silent Heb

    " Convert certain filetypes and open in read only
    au BufReadPre *.doc silent set ro
    au BufReadPost *.doc silent %!catdoc "%"
    au BufReadPre *.odt,*.odp silent set ro
    au BufReadPost *.odt,*.odp silent %!odt2txt "%"
    au BufReadPre *.sxw silent set ro
    au BufReadPost *.sxw silent %!sxw2txt "%"
    au BufReadPre *.pdf silent set ro
    au BufReadPost *.pdf silent %!pdftotext -nopgbrk -layout -q -eol unix "%" - | fmt -w78
    au BufReadPre *.rtf silent set ro
    au BufReadPost *.rtf silent %!unrtf --text "%"

    " Diff view
    au FilterWritePre * if &diff | setlocal wrap< | setlocal virtualedit=all | endif

    " Equal size windows upon resize
    au VimResized * wincmd =

    " cursor line and column for focused windows only
    au WinEnter * setlocal cursorline | setlocal cursorcolumn
    au WinLeave * setlocal nocursorline | setlocal nocursorcolumn

    " Source vimrc when written
    au BufWritePost $MYVIMRC nested source %
augroup END

" Tags
silent !ctags -Ro ~/src/ctags --exclude=.git --exclude=venv /mnt/home/i/contracts-solidity &> /dev/null &
set tags=~/src/ctags

" Pretty
if has("gui_running") || $DISPLAY != 'no'
    set t_Co=256
    setg termguicolors
    colorscheme jellybeans
else
    colorscheme desert
endif

set encoding=utf-8
set colorcolumn=121
hi ExtraWhitespace ctermbg=1
call matchadd('Error', '\s\+$\| \+\ze\t')
let nonansi = matchadd('Error', '[^\d0-\d127]')
syntax enable
