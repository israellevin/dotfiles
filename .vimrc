set nocompatible
set history=99999
set viminfo='100,%
set backup
set writebackup
set backupdir=~/.vim/backups
set undofile
set undodir=~/.vim/undo
set path+=.*

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
set list listchars=tab:\ \ ,trail:·

set wrap
set linebreak
set scrolloff=999
set backspace=indent,eol,start

set ruler
set showcmd
set showmode
set shortmess=aTW
set laststatus=1
set t_ti= t_te=
set mouse=a

set incsearch
set hlsearch
set ignorecase
set smartcase

set wildmenu
set wildmode=list:longest,full
set completeopt=longest,menuone,preview

"Plugins
filetype off

" Remember to git clone http://github.com/gmarik/vundle
set runtimepath+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

Bundle 'YankRing.vim'
nnoremap <Leader>yd :YRMapsDelete<CR>
nnoremap <Leader>yc :YRMapsCreatMapsCreate<CR>
let g:yankring_history_dir = '$VIM'
function! YRRunAfterMaps()
    nnoremap Y   :<C-U>YRYankCount 'y$'<CR>
endfunction

Bundle 'ctrlp.vim'
let g:ctrlp_map = '<F10>'

Bundle 'Screen-vim---gnu-screentmux'
let g:ScreenImpl = 'Tmux'
let g:ScreenShellTerminal = 'urxvtcd'

Bundle 'Gundo'
Bundle 'fugitive.vim'
Bundle 'fuzzee.vim'
Bundle 'EasyMotion'

Bundle 'rainbow_parentheses.vim'
Bundle 'jellybeans.vim'

"Maps, abrvs, commands
nnoremap Y y$
nnoremap <Space> <PageDown>
nnoremap <S-Space> <PageUp>
nnoremap <CR> :nohlsearch<CR><CR>
nnoremap gf :e <cfile><CR>
nnoremap <Leader>gf :split <cfile><CR>
nnoremap <Leader>s :setlocal spell!<CR>
nnoremap <expr> <Leader>h "hebrew" == &keymap ? ':Noheb<CR>' : ':Heb<CR>'
nnoremap <expr> <Leader>n &nu == &rnu ? ':setlocal nu!<CR>' : ':setlocal rnu!<CR>'
nnoremap <expr> <Leader>z 0 == &scrolloff ? ':setlocal scrolloff=999<CR>' : ':setlocal scrolloff=0<CR>'

nnoremap <Up> gk
nnoremap <Down> gj
nnoremap <kPlus> :cn<CR>
nnoremap <kMinus> :cp<CR>
nnoremap <F5> :w<CR>:! <C-r>=expand("%:p")<CR><CR>
nnoremap <F4> :b#<CR>
nnoremap <F3> :execute 'vimgrep /'.@/.'/g *'<CR>:copen<CR>
nnoremap <F2> :CtrlPBuffer<CR>

inoremap <Up> <C-o>gk
inoremap <Down> <C-o>gj
inoremap <kPlus> <Esc>:cn<CR>i
inoremap <kMinus> <Esc>:cp<CR>i
inoremap <F5> <Esc>:w<CR>:! <C-r>=expand("%:p")<CR><CR>
inoremap <F4> <Esc>:b#<CR>
inoremap <F3> <Esc>:execute 'vimgrep /'.@/.'/g *'<CR>:copen<CR>
inoremap <F2> <Esc>:CtrlPBuffer<CR>

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

if has("autocmd")
    au!
    filetype plugin indent on
    set omnifunc=syntaxcomplete#Complete

    " Return to last position
    au BufReadPost * normal `"

    " Hebrew
    au BufRead,BufNewFile ~/bildad/* Heb

    " Convert certain filetypes and open in read only
    au BufReadPre *.doc silent set ro
    au BufReadPost *.doc silent %!antiword "%"
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
    au BufWritePost * if getline(1) =~ "^#!" | silent !chmod +x <afile>
endif

" Pretty
set encoding=utf-8
set background=dark
syntax enable

if '' == $DISPLAY
    set t_Co=16
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
