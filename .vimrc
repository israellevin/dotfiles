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
set wildmode=longest:full,full
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

"Abrvs and maps
noremap <F5> :w<CR>:! %<CR>
noremap <Space> <PageDown>
noremap <kPlus> :cn<CR>
noremap <kMinus> :cp<CR>
noremap Y y$
noremap <down> gj
noremap <up> gk
nnoremap <silent> <leader>g :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>
inoremap <down> <C-o>gj
inoremap <up> <C-o>gk
inoremap <expr> <Tab> pumvisible() ? "<Tab>" : "<Tab><Down>"
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

" Bufferlist
map <silent> <F3> :call BufferList()<CR>
map <silent> <F4> :NERDTreeToggle<CR>

" NERDTree
let g:NERDChristmasTree=0
let g:NERDTreeAutoCenter=1

" Supertab
let g:SuperTabDefaultCompletionType="<c-p>"
let g:SuperTabContextDefaultCompletionType="<c-p>"

if has("autocmd")
    au!
    filetype plugin indent on
    set ofu=syntaxcomplete#Complete

    au FileType python noremap <f5> :w<CR>:! ipython -noconfirm_exit %<CR>
    au FileType python inoremap <f5> <Esc>:w<CR>:! ipython -noconfirm_exit %<CR>
    au BufRead,BufNewFile *.js set ft=javascript.jquery
    au BufRead,BufNewFile ~/work/heb/* set rightleft | set rightleftcmd | set keymap=hebrew | inoremap __ ־ | inoremap ___ –

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

    " Chmod +x shabanged files on save
    au BufWritePost * if getline(1) =~ "^#!" | silent !chmod +x <afile>

    " Source vimrc and bashrc when changed
    augroup myvimrc
        au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
    augroup END
endif

" Pretty
set encoding=utf-8
set t_Co=256
set background=dark
colorscheme solarized
syntax enable
set cursorline
set cursorcolumn
hi Pmenu ctermbg=white ctermfg=black
hi PMenuSel ctermbg=black ctermfg=green
hi clear CursorLine
hi CursorLine ctermbg=black guibg=#121212
hi clear CursorColumn
hi CursorColumn ctermbg=black guibg=#121212
hi ExtraWhitespace ctermbg=red guibg=red
hi SpellBad cterm=underline ctermfg=red ctermbg=black
match ExtraWhitespace /\s\+$/
match ExtraWhitespace /\s\+$\| \+\ze\t/
