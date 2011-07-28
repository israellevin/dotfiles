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

set wrap
set linebreak
set scrolloff=999
set backspace=indent,eol

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
call pathogen#runtime_append_all_bundles()

let g:SuperTabDefaultCompletionType="<c-p>"
let g:SuperTabContextDefaultCompletionType="<c-p>"

let g:NERDChristmasTree=0
let g:NERDTreeAutoCenter=1

"Abrvs and maps
cnorea Q :q<CR>
cnorea mks :wa<CR>:mksession! ~/.vim/.session<CR>
cnorea lds :source ~/.vim/.session<CR>
cnorea heb setlocal rightleft \| setlocal rightleftcmd \| setlocal keymap=hebrew
cnorea noheb setlocal norightleft \| setlocal rightleftcmd= \| setlocal keymap=
cnorea lowtag %s/<\/\?\u\+/\L&/g
cnorea clstag source ~/.vim/scripts/closetag.vim

noremap Y y$
noremap <Space> <PageDown>
noremap <Leader>ss :setlocal spell!<CR>
noremap <expr> <Leader>dd 0 == &scrolloff ? ':setlocal scrolloff=999<CR>' : ':setlocal scrolloff=0<CR>'

noremap <Up> gk
noremap <Down> gj
noremap <kPlus> :cn<CR>
noremap <kMinus> :cp<CR>
noremap <F5> :w<CR>:! ./%<CR>
noremap <F4> :NERDTreeToggle<CR>
noremap <F3> :execute 'vimgrep /'.@/.'/g *'<CR>:copen<CR>
noremap <F2> :FufCoverageFile<CR>

inoremap <Up> <C-o>gk
inoremap <Down> <C-o>gj
inoremap <kPlus> <Esc>:cn<CR>i
inoremap <kMinus> <Esc>:cp<CR>i
inoremap <F5> <Esc>:w<CR>:! ./%<CR>
inoremap <F4> <Esc>:NERDTreeToggle<CR>
inoremap <F3> <Esc>:execute 'vimgrep /'.@/.'/g *'<CR>:copen<CR>
inoremap <F2> <Esc>:FufCoverageFile<CR>

"inoremap <expr> <Tab> pumvisible() ? "<Tab>" : "<Tab><Down>"

vnoremap <Right> >gv
vnoremap <Left> <gv
vnoremap . :normal .<CR>
vnoremap ` :normal @a<CR>

if has("autocmd")
    au!
    filetype plugin indent on
    set ofu=syntaxcomplete#Complete

"    au FileType python noremap <F5> :w<CR>:! ipython -noconfirm_exit %<CR>
"    au FileType python inoremap <F5> <Esc>:w<CR>:! ipython -noconfirm_exit %<CR>
    au FileType python set omnifunc=pythoncomplete#Complete

    au BufRead,BufNewFile *.js set ft=javascript.jquery
    au BufRead,BufNewFile ~/work/heb/* set rightleft | set rightleftcmd | set keymap=hebrew | inoremap -- ־| inoremap --- –

    " Open other filetypes in RO
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
set t_Co=256
set background=dark
colorscheme solarized
syntax enable
set cursorline
set cursorcolumn
hi search ctermbg=black
hi Pmenu ctermbg=white ctermfg=black
hi PMenuSel ctermbg=black ctermfg=green
hi clear CursorLine
hi CursorLine ctermbg=black
hi clear CursorColumn
hi CursorColumn ctermbg=black
hi ExtraWhitespace ctermbg=red guibg=red
hi SpellBad cterm=underline ctermfg=red ctermbg=black
match ExtraWhitespace /\s\+$/
match ExtraWhitespace /\s\+$\| \+\ze\t/
