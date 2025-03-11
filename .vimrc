" Prep things on first run.
let firstrun=0
if !filereadable(expand("~/.vim/autoload/plug.vim"))
    let firstrun=1
    silent !mkdir -p ~/.vim/{autoload,undo,backups}
    silent !curl https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim > ~/.vim/autoload/plug.vim
endif

"Plugins
call plug#begin('~/.vim/plugged')
Plug 'dense-analysis/ale'
Plug 'PeterRincker/vim-argumentative'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'github/copilot.vim'
Plug 'will133/vim-dirdiff'
Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/gv.vim'
Plug 'vim-utils/vim-husk'
Plug 'michaeljsmith/vim-indent-object'
Plug 'lfv89/vim-interestingwords'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'andymass/vim-matchup'
Plug 'junegunn/vim-peekaboo'
Plug 'zweifisch/pipe2eval'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'tpope/vim-surround'
Plug 'florentc/vim-tla'
Plug 'puremourning/vimspector'
Plug 'maxbrunsfeld/vim-yankstack'

Plug 'w0ng/vim-hybrid'
Plug 'sudorook/colorific.vim'

" Auto install plugins on first run
call plug#end()
if 1 == firstrun
    :PlugInstall
endif

" Plugin configurations
let g:ale_linters = {'python': ['pycodestyle', 'flake8', 'mypy', 'pylint']}
let g:ale_python_pycodestyle_options = '--max-line-length=120'
let g:ale_python_pylint_options = '--max-line-length=120'
let g:ale_linters_ignore = {'html': ['eslint']}
nmap <expr> <C-j> &diff ? ']c' : ':ALENext<CR>'
nmap <expr> <C-k> &diff ? '[c' : ':ALEPrevious<CR>'

imap <silent><script><expr> <C-j> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

let g:lsp_diagnostics_enabled = 0
let g:lsp_preview_float = 0
let g:lsp_signature_help_enabled = 0
let g:lsp_document_code_action_signs_enabled = 0
let g:python3_host_prog = '~/.local/share/vim-lsp-settings/servers/pylsp-all/venv/bin/python3'
nnoremap gd <Plug>(lsp-definition)

nmap <leader>dc <Plug>VimspectorContinue
nmap <leader>dl <Plug>VimspectorLaunch
nmap <leader>ds <Plug>VimspectorStop
nmap <leader>dr <Plug>VimspectorRestart
nmap <leader>dp <Plug>VimspectorPause
nmap <leader>db <Plug>VimspectorToggleBreakpoint
nmap <leader>dB <Plug>VimspectorToggleConditionalBreakpoint
nmap <leader>dF <Plug>VimspectorAddFunctionBreakpoint
nmap <leader>dx <Plug>VimspectorRunToCursor
nmap <leader>do <Plug>VimspectorStepOver
nmap <leader>di <Plug>VimspectorStepInto
nmap <leader>dO <Plug>VimspectorStepOut
nmap <leader>dw <Plug>VimspectorBalloonEval

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
set wildoptions=pum
set wildignorecase
set completeopt=longest,menuone,preview
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
nnoremap <expr> 0 col('.') - 1 == match(getline('.'), '\S') ? '0' : '^'
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
nnoremap <C-b>c :silent !tmux new-window<CR>
nnoremap <C-b>" :silent !tmux split-window -v<CR>
nnoremap <C-b>% :silent !tmux split-window -h<CR>

inoremap jj <ESC>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-g>u\<Tab>"
nnoremap <C-M-j> :move +1<CR>
nnoremap <C-M-k> :move -2<CR>
vnoremap <C-M-j> :move '>+1<CR>gv
vnoremap <C-M-k> :move '<-2<CR>gv
inoremap <C-M-j> <Esc>:move +1<CR>a
inoremap <C-M-k> <Esc>:move -2<CR>a

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
command! Heb setlocal rightleft | setlocal rightleftcmd | setlocal keymap=hebrew | inoremap -- ־| inoremap --- –| call Pretty(0)
command! Noheb setlocal norightleft | setlocal rightleftcmd= | setlocal keymap= | call Pretty(0)
command! UnwrittenDiff vert new | set bt=nofile | r ++edit

" autocommands
filetype plugin indent on
augroup mine
    au!
    au VimEnter * call Pretty(0)

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
    au OptionSet diff call timer_start(0, 'Pretty')

    " Equal size windows upon resize
    au VimResized * wincmd =

    " cursor line and column for focused windows only
    au WinEnter * setlocal cursorline | setlocal cursorcolumn
    au WinLeave * setlocal nocursorline | setlocal nocursorcolumn

    " Source vimrc when written
    au BufWritePost ~/.vimrc nested source % | redraw! | echomsg "sourced"
augroup END

" Tags
silent !ctags -Ro ~/src/ctags --exclude=.git ~/src ~/bin &> /dev/null &
set tags=~/src/ctags

" Pretty
" Accepts an argument so it can be called from a timer (in some autocommands)
function! Pretty(_)
    if has("gui_running") || $DISPLAY != 'no'
        set t_Co=256
        set termguicolors
        set background=dark
        colorscheme hybrid
    else
        colorscheme colorific
        set notermguicolors
    endif

    if &diff
        windo set virtualedit=all
        windo set wrap<
        if !exists('g:colors_name') || g:colors_name == 'hybrid'
            colorscheme colorific
        endif
    else
        set virtualedit=
    endif

    syntax enable
    set encoding=utf-8
    set colorcolumn=121
    hi Comment guifg=orange
    hi Conceal guibg=#1d1f21
    hi ExtraWhitespace ctermbg=1
    hi NonAnsii ctermbg=1
    call matchadd('ExtraWhitespace', '\s\+$\| \+\ze\t')
    call matchadd('NonAnsii', '[^\d0-\d127]')
    if &keymap == 'hebrew'
        hi NonAnsii ctermbg=0
        setlocal nospell
    endif
endfunction
