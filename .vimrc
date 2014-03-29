set nocompatible
set history=99999
set viminfo='100,%
set backup
set writebackup
set backupdir=~/.vim/backups
set undofile
set undodir=~/.vim/undo
set path+=.*
set modeline

set hidden
set autoread
set autochdir
set tabpagemax=32
set switchbuf=usetab

set smarttab
set expandtab
set autoindent
set smartindent
set shiftround
set shiftwidth=4
set softtabstop=4
set tabstop=4
set list listchars=tab:»\ ,trail:•,extends:↜,precedes:↜,nbsp:°

set wrap
set linebreak
set scrolloff=999
set formatoptions=tcqw
set backspace=indent,eol,start
set indentkeys-=-<Return>

set ruler
set relativenumber
set number
set showcmd
set showmode
set shortmess=aoTW
set laststatus=1
set mouse=

set incsearch
set hlsearch
set ignorecase
set smartcase

set wildmenu
set wildmode=longest:full,full
set completeopt=longest,menu

"Plugins
filetype off

let firstrun=0
if !filereadable(expand("~/.vim/bundle/vundle/README.md"))
    let firstrun=1
    silent !mkdir -p ~/.vim/{bundle,undo,backups}
    silent !git clone http://github.com/gmarik/vundle ~/.vim/bundle/vundle
endif
set runtimepath+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

Bundle 'maxbrunsfeld/vim-yankstack'
let g:yankstack_map_keys = 0
call yankstack#setup()
nmap <C-p> <Plug>yankstack_substitute_older_paste
nmap <C-n> <Plug>yankstack_substitute_newer_paste
nnoremap Y y$

Bundle 'AutoComplPop'
let g:acp_behaviorKeywordLength = 2

Bundle 'ctrlp.vim'
let g:ctrlp_map = '<F10>'
nnoremap <Leader>B :CtrlPBuffer<CR>

Bundle 'mmedvede/w3m.vim'
Bundle 'zweifisch/pipe2eval'
Bundle 'mattn/emmet-vim'

Bundle 'jellybeans.vim'

"Bundle 'rainbow_parentheses.vim'
if 1 == firstrun
    :BundleInstall!
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
nnoremap <expr> <Leader>h "hebrew" == &keymap ? ':Noheb<CR>' : ':Heb<CR>'
nnoremap <expr> <Leader>n &nu == &rnu ? ':setlocal nu!<CR>' : ':setlocal rnu!<CR>'
nnoremap <expr> <Leader>z 0 == &scrolloff ? ':setlocal scrolloff=999<CR>' : ':setlocal scrolloff=0<CR>'

nnoremap <Up> gk
nnoremap <Down> gj
nnoremap <F5> :w<CR>:! <C-r>=expand("%:p")<CR><CR>

inoremap jj <ESC>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-g>u\<Tab>"
inoremap <Up> <C-o>gk
inoremap <Down> <C-o>gj
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
command! Heb setlocal rightleft | setlocal rightleftcmd | setlocal keymap=hebrew | inoremap -- ־| inoremap --- –
command! Noheb setlocal norightleft | setlocal rightleftcmd= | setlocal keymap=
command! Lowtag %s/<\/\?\u\+/\L&/g

" autocommands
au!
filetype plugin indent on
set omnifunc=syntaxcomplete#Complete

" Return to last position
au BufReadPost * normal `"

" Many ftplugins override formatoptions, so override them back
au BufReadPost,BufNewFile * setlocal formatoptions=tcqw

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
au FilterWritePre * if &diff | windo set wrap | windo set virtualedit=all

" Equal size windows upon resize
au VimResized * wincmd =

" cursor line and column for focused windows only
au WinEnter * setlocal cursorline | setlocal cursorcolumn
au WinLeave * setlocal nocursorline | setlocal nocursorcolumn

" Source vimrc when written
au! BufWritePost $MYVIMRC source $MYVIMRC

" Chmod +x shabanged files on save
au BufWritePost * if getline(1) =~ "^#!" | silent !chmod u+x <afile>

" Pretty
set encoding=utf-8
set background=dark
syntax enable

if '' == $DISPLAY
    set t_Co=8
    colorscheme desert
else
    set t_Co=256
    colorscheme jellybeans
    hi CursorLine ctermbg=234
    hi CursorColumn ctermbg=234
    hi Todo cterm=bold ctermfg=231 ctermbg=1
endif

set cursorline
set cursorcolumn
hi ExtraWhitespace ctermbg=1
match ExtraWhitespace /\s\+$/
match ExtraWhitespace /\s\+$\| \+\ze\t/
