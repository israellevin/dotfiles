set nocompatible
set history=99999
set viminfo='100,%
set backup
set writebackup
set backupdir=~/.vim/backups
set undofile
set undodir=~/.vim/undo

set hidden
set autoread
set autochdir
set tabpagemax=32

set smarttab
set expandtab
set autoindent
set smartindent
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
set t_ti= t_te=
set mouse=a

set incsearch
set hlsearch
set ignorecase
set smartcase

set wildmenu
set wildmode=longest:full,full
set completeopt=longest,menuone,preview

"Plugins
filetype off

set runtimepath+=/usr/share/vim/addons/
let g:notmuch_initial_search_words = [ 'folder:INBOX and tag:unread' ]
let s:notmuch_signature_defaults = [ ]
let g:notmuch_folders = [
        \ [ 'new', 'tag:unread and folder:INBOX' ],
        \ [ 'important', 'tag:flagged and folder:INBOX' ],
        \ [ 'starred', 'tag:flagged' ],
        \ [ 'inbox', 'folder:INBOX' ],
        \ [ 'unread', 'tag:unread and not folder:spam' ],
        \ ]

set runtimepath+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

Bundle 'ervandew/supertab'
let g:SuperTabDefaultCompletionType="context"
let g:SuperTabContextDefaultCompletionType="<c-x><c-p>"
let g:SuperTabLongestEnhanced=1
let g:SuperTabLongestHighlight=1

Bundle 'YankRing.vim'
let g:yankring_history_dir = '$VIM'
let g:yankring_zap_keys = 'f F t T / ?'
function! YRRunAfterMaps()
    nnoremap Y   :<C-U>YRYankCount 'y$'<CR>
endfunction

Bundle 'xmledit'
let xml_use_xhtml = 1

Bundle 'L9'
Bundle 'FuzzyFinder'
Bundle 'Gundo'
Bundle 'thinca/vim-visualstar'
Bundle 'vim-orgmode'
Bundle 'tpope/vim-fugitive'
Bundle 'Lokaltog/vim-easymotion'

Bundle 'jQuery'
Bundle 'molokai'

"Maps and abrvs
nnoremap Y y$
nnoremap <Space> <PageDown>
nnoremap <S-Space> <PageUp>
nnoremap <CR> :nohlsearch<CR>
nnoremap <Leader>s :setlocal spell!<CR>
nnoremap <expr> <Leader>d 0 == &scrolloff ? ':setlocal scrolloff=999<CR>' : ':setlocal scrolloff=0<CR>'
nnoremap <expr> <Leader>h "hebrew" == &keymap ? ':setlocal norightleft \| setlocal rightleftcmd= \| setlocal keymap=<CR>' : ':setlocal rightleft \| setlocal rightleftcmd \| setlocal keymap=hebrew<CR>'

nnoremap <Up> gk
nnoremap <Down> gj
nnoremap <kPlus> :cn<CR>
nnoremap <kMinus> :cp<CR>
nnoremap <F5> :w<CR>:! ./%<CR>
nnoremap <F4> :FufBuffer<CR>
nnoremap <F3> :execute 'vimgrep /'.@/.'/g *'<CR>:copen<CR>
nnoremap <F2> :FufCoverageFile<CR>

inoremap <Up> <C-o>gk
inoremap <Down> <C-o>gj
inoremap <kPlus> <Esc>:cn<CR>i
inoremap <kMinus> <Esc>:cp<CR>i
inoremap <F5> <Esc>:w<CR>:! ./%<CR>
inoremap <F4> <Esc>:NERDTreeToggle<CR>
inoremap <F3> <Esc>:execute 'vimgrep /'.@/.'/g *'<CR>:copen<CR>
inoremap <F2> <Esc>:FufCoverageFile<CR>

vnoremap <Right> >gv
vnoremap <Left> <gv
vnoremap . :normal .<CR>
vnoremap ` :normal @a<CR>

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

cnorea Q :q<CR>
cnorea mks :wa<CR>:mksession! ~/.vim/.session<CR>
cnorea lds :source ~/.vim/.session<CR>
cnorea heb setlocal rightleft \| setlocal rightleftcmd \| setlocal keymap=hebrew
cnorea noheb setlocal norightleft \| setlocal rightleftcmd= \| setlocal keymap=
cnorea lowtag %s/<\/\?\u\+/\L&/g

if has("autocmd")
    au!
    filetype plugin indent on
    set ofu=syntaxcomplete#Complete
    au BufWrite * mkview
    au BufRead * loadview

    au BufRead,BufNewFile *.js set ft=javascript.jquery
    au BufRead,BufNewFile *.htm* set ft=xml
    au BufRead,BufNewFile ~/work/heb/* set rightleft | set rightleftcmd | set keymap=hebrew | inoremap -- ־| inoremap --- –

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

    " Wrap diffs
    au FilterWritePre * if &diff | windo set wrap | windo set virtualedit=all

    " Equal size windows upon resize
    au VimResized * wincmd =

    " Source vimrc written
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
    colorscheme elflord
    hi SpellBad ctermbg=red ctermfg=black
else
    set t_Co=256
    colorscheme molokai
    hi SpellBad cterm=underline ctermfg=red ctermbg=black
endif

set cursorline
set cursorcolumn
hi ExtraWhitespace ctermbg=1
match ExtraWhitespace /\s\+$/
match ExtraWhitespace /\s\+$\| \+\ze\t/
