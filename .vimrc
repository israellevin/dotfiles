if has("autocmd")
    autocmd!
    filetype plugin indent on
    set ofu=syntaxcomplete#Complete

    au FileType python noremap <f5> :w<CR>:! ipython -noconfirm_exit %<CR>
    au FileType python inoremap <f5> <Esc>:w<CR>:! ipython -noconfirm_exit %<CR>
    au BufRead,BufNewFile *.js set ft=javascript.jquery
    au BufRead,BufNewFile ~/work/bildad/* set rightleft | set rightleftcmd | set keymap=hebrew

    " Open other filetypes in RO
    autocmd BufReadPre *.doc silent set ro
    autocmd BufReadPost *.doc silent %!antiword "%"
    autocmd BufReadPre *.odt,*.odp silent set ro
    autocmd BufReadPost *.odt,*.odp silent %!odt2txt "%"
    autocmd BufReadPre *.sxw silent set ro
    autocmd BufReadPost *.sxw silent %!sxw2txt "%"
    autocmd BufReadPre *.pdf silent set ro
    autocmd BufReadPost *.pdf silent %!pdftotext -nopgbrk -layout -q -eol unix "%" - | fmt -w78
    autocmd BufReadPre *.rtf silent set ro
    autocmd BufReadPost *.rtf silent %!unrtf --text "%"

    " Wrap diffs
    au FilterWritePre * if &diff | windo set wrap

    " Equal size windows upon resize
    autocmd VimResized * wincmd =

    " Chmod +x shabanged files on save
    au BufWritePost * if getline(1) =~ "^#!" | silent !chmod +x <afile>

    " Source vimrc when changed
    autocmd! bufwritepost .vimrc source ~/.vimrc
endif

set nocompatible
set history=99999
set viminfo='100,%
set autoread
set showmode
set showcmd
set mouse=a
set incsearch
set hlsearch
set ignorecase
set smartcase
set ruler
set shortmess=aTW
set scrolloff=3
set wildmenu
set wildmode=full
set completeopt=longest,menuone,preview
set autoindent
set smartindent
set sw=4
set ts=4
set et
set backspace=indent,eol,start
set smarttab
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autochdir
set backup
set writebackup
set backupdir=~/.vim/backups
set undofile
set undodir=~/.vim/undo
set t_ti= t_te=

" Pretty
syntax enable
set encoding=utf-8
set t_Co=256
set background=dark
colorscheme xoria256
set cursorline
set cursorcolumn
hi Pmenu ctermbg=white ctermfg=black
hi PMenuSel ctermbg=black ctermfg=green
hi clear CursorLine
hi CursorLine guibg=#121212 cterm=BOLD
hi clear CursorColumn
hi CursorColumn guibg=#121212 cterm=BOLD
hi ExtraWhitespace ctermbg=red guibg=red
hi SpellBad cterm=underline ctermfg=red ctermbg=black
match ExtraWhitespace /\s\+$/
match ExtraWhitespace /\s\+$\| \+\ze\t/

"Abrvs and maps
noremap <F5> :w<CR>:! %<CR>
noremap <Space> <PageDown>
noremap <kPlus> :cn<CR>
noremap <kMinus> :cp<CR>
noremap Y y$
noremap <down> gj
noremap <up> gk
inoremap <down> <C-o>gj
inoremap <up> <C-o>gk
inoremap <expr> <Tab> pumvisible() ? "<Tab>" : "<Tab><Down>"
inoremap __ ־
inoremap ___ –
vnoremap . :normal .<CR>
vnoremap ` :normal @a<CR>
vnoremap <Right> >gv
vnoremap <Left> <gv
cnorea heb set rightleft \| set rightleftcmd \| set keymap=hebrew
cnorea noheb set norightleft \| set rightleftcmd= \| set keymap=
cnorea lowtag %s/<\/\?\u\+/\L&/g
cnorea clstag source ~/.vim/scripts/closetag.vim
cnorea mks :wa <cr>:mksession! ~/.vim/.session<cr>
cnorea lds :source ~/.vim/.session <cr>

" Supertab
let g:SuperTabDefaultCompletionType="<c-p>"
let g:SuperTabContextDefaultCompletionType="<c-p>"

" Bufferlist
map <silent> <F3> :call BufferList()<CR>
map <silent> <F4> :NERDTreeToggle<CR>

" NERDTree
let g:NERDChristmasTree=0
let g:NERDTreeAutoCenter=1
