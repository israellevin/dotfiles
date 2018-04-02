" Buffers
set hidden
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

" UI
set ignorecase
set smartcase
set wildmenu
set wildmode=longest:full,full
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
set mouse=

" Tags
silent !ctags -Ro ~/src/ctags ~/src &> /dev/null &
set tags=~/src/ctags

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
nnoremap <Leader>F :grep! "\b<C-R><C-W>\b"<CR>:copen<CR>
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

" Enable arrows for visitors
nnoremap <Up> gk
nnoremap <Down> gj
inoremap <Up> <C-o>gk
inoremap <Down> <C-o>gj

"Plugins

" Prep things on first run.
let firstrun=0
if !filereadable(expand("~/.vim/autoload/plug.vim"))
    let firstrun=1
    silent !mkdir -p ~/.vim/{autoload,undo,backups}
    silent !wget -O ~/.vim/autoload/plug.vim
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
call plug#begin('~/.vim/plugged')

Plug 'vim-utils/vim-husk'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'vim-scripts/AutoComplPop'
Plug 'tommcdo/vim-exchange'
Plug 'Konfekt/FastFold'
Plug 'scrooloose/syntastic'
Plug 'zweifisch/pipe2eval'
Plug 'tpope/vim-fugitive'
Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'tmhedberg/matchit', { 'for': 'html' }
Plug 'vasconcelloslf/vim-interestingwords'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'
Plug 'kien/rainbow_parentheses.vim'
Plug 'nanotech/jellybeans.vim'
Plug 'unblevable/quick-scope'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
Plug 'junegunn/fzf.vim'
Plug 'wellle/targets.vim'
Plug 'PeterRincker/vim-argumentative'

" Auto install plugins on first run
call plug#end()
if 1 == firstrun
    :PlugInstall
endif

" Plugin configurations
call yankstack#setup()
nmap <C-p> <Plug>yankstack_substitute_older_paste
nmap <C-n> <Plug>yankstack_substitute_newer_paste
nnoremap Y y$

let g:acp_behaviorKeywordLength = 2

let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_html_checkers = ['jshint']
let g:syntastic_html_validator_api='http://validator.nu/'
let g:yankstack_map_keys = 0

let g:limelight_conceal_ctermfg = 240

nnoremap <Leader>( :RainbowParenthesesToggleAll<CR>

" quickscope fix: https://gist.github.com/cszentkiralyi/dc61ee28ab81d23a67aa
let g:qs_enable = 0
let g:qs_enable_char_list = [ 'f', 'F', 't', 'T' ]
function! Quick_scope_selective(movement)
    let needs_disabling = 0
    if !g:qs_enable
        QuickScopeToggle
        redraw
        let needs_disabling = 1
    endif
    let letter = nr2char(getchar())
    if needs_disabling
        QuickScopeToggle
    endif
    return a:movement . letter
endfunction
for i in g:qs_enable_char_list
	execute 'noremap <expr> <silent>' . i . " Quick_scope_selective('". i . "')"
endfor

" autocommands
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
    au FilterWritePre * if &diff | windo set wrap | windo set virtualedit=all

    " Equal size windows upon resize
    au VimResized * wincmd =

    " cursor line and column for focused windows only
    au WinEnter * setlocal cursorline | setlocal cursorcolumn
    au WinLeave * setlocal nocursorline | setlocal nocursorcolumn

    " Source vimrc when written
    au BufWritePost $MYVIMRC nested source %

    " Chmod +x shabanged files on save
    au BufWritePost * SyntasticCheck | if getline(1) =~ "^#!" | silent !chmod u+x <afile>
augroup END

" Pretty
if 'no' == $DISPLAY
    set t_Co=8
    colorscheme desert
else
    set t_Co=256
    colorscheme jellybeans
    hi CursorLine ctermbg=234
    hi CursorColumn ctermbg=234
    hi Todo cterm=bold ctermfg=231 ctermbg=1
endif

set encoding=utf-8
set colorcolumn=81
hi ExtraWhitespace ctermbg=1
call matchadd('Error', '\s\+$\| \+\ze\t')
let nonansi = matchadd('Error', '[^\d0-\d127]')
syntax enable
