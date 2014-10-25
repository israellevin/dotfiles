" History
set history=10000
set viminfo='100,%
set backup
set writebackup
set backupdir=~/.vim/backups
set undofile
set undodir=~/.vim/undo
set modeline

" Buffers
set hidden
set autoread
set autochdir
set tabpagemax=32
set switchbuf=usetab

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

" UI
set ignorecase
set smartcase
set wildmenu
set wildmode=longest:full,full
set completeopt=longest,menu
set incsearch
set hlsearch
set ruler
set relativenumber
set number
set showcmd
set showmode
set scrolloff=999
set shortmess=aoTW
set laststatus=1
set list listchars=tab:»\ ,trail:•,extends:↜,precedes:↜,nbsp:°
set mouse=

"Maps, abrvs, commands
nnoremap Y y$
nnoremap <Space> <PageDown>
nnoremap <Backspace> <PageUp>
nnoremap <CR> :nohlsearch<CR><CR>
nnoremap gf :e <cfile><CR>
nnoremap <Leader>gf :split <cfile><CR>
nnoremap <Leader>s :setlocal spell!<CR>
nnoremap <Leader>b :b#<CR>
nnoremap <Leader>f :set foldexpr=getline(v:lnum)!~@/<CR>:set foldmethod=expr<CR><Bar>zM
nnoremap <Leader>F :execute 'vimgrep /'.@/.'/g *'<CR>:copen<CR>
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
command! Heb setlocal rightleft | setlocal rightleftcmd | setlocal keymap=hebrew | inoremap -- ־| inoremap --- –
command! Noheb setlocal norightleft | setlocal rightleftcmd= | setlocal keymap=
command! Lowtag %s/<\/\?\u\+/\L&/g

" Enable arrows for visitors
nnoremap <Up> gk
nnoremap <Down> gj
inoremap <Up> <C-o>gk
inoremap <Down> <C-o>gj

"Plugins
let firstrun=0
if !filereadable(expand("~/.vim/autoload/plug.vim"))

    let firstrun=1
    silent !mkdir -p ~/.vim/{autoload,undo,backups}
    silent !curl -fLo ~/.vim/autoload/plug.vim
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
call plug#begin('~/.vim/plugged')

Plug 'maxbrunsfeld/vim-yankstack'
Plug 'AutoComplPop'
Plug 'ctrlp.vim'
Plug 'rainbow_parentheses.vim'
Plug 'tommcdo/vim-exchange'
Plug 'mmedvede/w3m.vim'
Plug 'zweifisch/pipe2eval'
Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'matchit.zip', { 'for': 'html' }
Plug 'jellybeans.vim'

call plug#end()
if 1 == firstrun
    :PlugInstall
endif

let g:yankstack_map_keys = 0
call yankstack#setup()
nmap <C-p> <Plug>yankstack_substitute_older_paste
nmap <C-n> <Plug>yankstack_substitute_newer_paste
nnoremap Y y$
let g:acp_behaviorKeywordLength = 2
let g:ctrlp_map = '<F10>'
nnoremap <Leader>B :CtrlPBuffer<CR>
nnoremap <Leader>( :RainbowParenthesesToggleAll<CR>

" autocommands
au!
set omnifunc=syntaxcomplete#Complete

" Return to last position
au BufReadPost * normal `"

" Folding
au BufReadPost * set foldmethod=indent
au BufReadPost * normal zR

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
au FilterWritePre * if &diff | windo set wrap | windo set virtualedit=all

" Equal size windows upon resize
au VimResized * wincmd =

" cursor line and column for focused windows only
au WinEnter * setlocal cursorline | setlocal cursorcolumn
au WinLeave * setlocal nocursorline | setlocal nocursorcolumn

" Chmod +x shabanged files on save
au BufWritePost * if getline(1) =~ "^#!" | silent !chmod u+x <afile>

" Source vimrc when written
au! BufWritePost $MYVIMRC source $MYVIMRC

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
set colorcolumn=81
hi ExtraWhitespace ctermbg=1
match ExtraWhitespace /\s\+$/
match ExtraWhitespace /\s\+$\| \+\ze\t/
