" Prep things on first run.
let firstrun=0
if !filereadable(expand("~/.vim/autoload/plug.vim"))
    let firstrun=1
    silent !mkdir -p ~/.vim/{autoload,undo,backups}
    silent !curl https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim > ~/.vim/autoload/plug.vim
endif

" Buffers
set autoread
set autochdir
set hidden
set switchbuf=usetab

" History
set backup
set backupdir=~/.vim/backups
set history=10000
set modeline
set undodir=~/.vim/undo
set undofile
set viminfo='1000,%

" Indentation
set autoindent
set expandtab
set shiftround
set shiftwidth=4
set softtabstop=4
set tabstop=4

" General behavior
set backspace=indent,eol,start
set isfname-=\=
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" Search
set incsearch
set ignorecase
set smartcase

" Completion
set completeopt=longest,menuone,preview
set omnifunc=syntaxcomplete#Complete
set wildignorecase
set wildmenu
set wildmode=longest:full,full
set wildoptions=pum

" Display
set breakindent
set colorcolumn=81
set conceallevel=1
set cursorcolumn
set cursorline
set hlsearch
set laststatus=1
set linebreak
set list listchars=tab:»\ ,trail:•,extends:↜,precedes:↜,nbsp:°
set number
set ruler
set scrolloff=999
set shortmess=aoTW
set showbreak=↳
set showcmd
set showmode
set wrap

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
    hi Comment guifg=orange
    hi Conceal guibg=#1d1f21
    hi ExtraWhitespace ctermbg=1
    hi NonAnsii ctermbg=1
    hi LspPopup ctermfg=red
    hi LspSigActiveParameter ctermfg=green

    call matchadd('ExtraWhitespace', '\s\+$\| \+\ze\t')
    call matchadd('NonAnsii', '[^\d0-\d127]')
    if &keymap == 'hebrew'
        hi NonAnsii ctermbg=0
        setlocal nospell
    endif
endfunction

" Commands
command! Q q
command! Heb setlocal rightleft | setlocal rightleftcmd | setlocal keymap=hebrew | call Pretty(0)
command! Noheb setlocal norightleft | setlocal rightleftcmd= | setlocal keymap= | call Pretty(0)
command! UnwrittenDiff vert new | set bt=nofile | r ++edit

" Mappings
nnoremap Y y$
nnoremap <expr> 0 col('.') - 1 == match(getline('.'), '\S') ? '0' : '^'
nnoremap <Space> <PageDown>
nnoremap <Backspace> <PageUp>
nnoremap <Leader>b <Cmd>b#<CR>
nnoremap <Leader>B <Cmd>Buffers<CR>
nnoremap gf <Cmd>e <cfile><CR>
nnoremap <Leader>gf <Cmd>split <cfile><CR>
nnoremap <Leader>f <Cmd>set foldexpr=getline(v:lnum)!~@/<CR>:set foldmethod=expr<CR><Bar>zM
nnoremap <Leader>F :grep! <C-r>=substitute("<C-r>/", "[><]", "", "g")<CR><CR><Cmd>copen<CR>
nnoremap <CR> <Cmd>nohlsearch<CR><CR>
nnoremap <expr> <Leader>n &nu == &rnu ? '<Cmd>setlocal nu!<CR>' : '<Cmd>setlocal rnu!<CR>'
nnoremap <expr> <Leader>z 0 == &scrolloff ? '<Cmd>setlocal scrolloff=999<CR>' : '<Cmd>setlocal scrolloff=0<CR>'
nnoremap <expr> <Leader>h "hebrew" == &keymap ? '<Cmd>Noheb<CR>' : '<Cmd>Heb<CR>'
nnoremap <Leader>s <Cmd>setlocal spell!<CR>
nnoremap <Leader>r <Cmd>w<CR>:! <C-r>=expand("%:p")<CR><CR>

inoremap jj <ESC>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-g>u\<Tab>"
inoremap <C-j> <Esc>:move +1<CR>a
inoremap <C-k> <Esc>:move -2<CR>a

vnoremap <C-j> :move '>+1<CR>gv
vnoremap <C-k> :move '<-2<CR>gv
vnoremap <Right> >gv
vnoremap <Left> <gv
vnoremap . <Cmd>normal .<CR>
vnoremap ` <Cmd>normal @a<CR>

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap %% <C-r>=expand("%:p:h") . '/' <CR>

" autocommands
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

    " Pretty diff view
    au OptionSet diff call timer_start(0, 'Pretty')

    " Equal size windows upon resize
    au VimResized * wincmd =

    " cursor line and column for focused windows only
    au WinEnter * setlocal cursorline | setlocal cursorcolumn
    au WinLeave * setlocal nocursorline | setlocal nocursorcolumn

    " Source vimrc when written
    au BufWritePost ~/.vimrc nested source % | redraw! | echomsg "sourced"
augroup END

"Plugins
call plug#begin('~/.vim/plugged')
Plug 'dense-analysis/ale'
Plug 'tpope/vim-apathy'
Plug 'PeterRincker/vim-argumentative'
Plug 'github/copilot.vim'
Plug 'will133/vim-dirdiff'
Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
Plug 'junegunn/fzf.vim'
Plug 'yegappan/lsp'
Plug 'vim-utils/vim-husk'
Plug 'michaeljsmith/vim-indent-object'
Plug 'lfv89/vim-interestingwords'
Plug 'andymass/vim-matchup'
Plug 'junegunn/vim-peekaboo'
Plug 'zweifisch/pipe2eval'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'tpope/vim-surround'
Plug 'florentc/vim-tla'
Plug 'puremourning/vimspector'
Plug 'jasonccox/vim-wayland-clipboard'
Plug 'mbbill/undotree'
Plug 'maxbrunsfeld/vim-yankstack'

" Colorschemes
Plug 'w0ng/vim-hybrid'
Plug 'sudorook/colorific.vim'

" Auto install plugins on first run
call plug#end()
if 1 == firstrun
    :PlugInstall
endif
filetype plugin indent on

" Plugin configurations
let g:matchparen_disable_cursor_hl = 0

let g:ale_linters = {'python': ['ruff']}
let g:ale_linters_ignore = {'html': ['eslint']}
let g:ale_python_pycodestyle_options = '--max-line-length=120'
let g:ale_python_pylint_options = '--max-line-length=120'
nnoremap <expr> <C-j> pumvisible() ? "\<C-e>" : (&diff ? ']c' : '<Cmd>ALENext<CR>')
nnoremap <expr> <C-k> pumvisible() ? "\<C-y>" : (&diff ? '[c' : '<Cmd>ALEPrevious<CR>')

let lspOpts = #{
\    aleSupport: v:true,
\    autoComplete: v:true,
\    autoHighlightDiags: v:true,
\    autoPopulateDiags: v:true,
\    completionMatcher: 'fuzzy',
\    filterCompletionDuplicates: v:true,
\    hoverFallback: v:true,
\    noNewlineInCompletion: v:true,
\    usePopupInCodeAction: v:true,
\    useBufferCompletion: v:true,
\}

autocmd User LspSetup call LspOptionsSet(lspOpts)
let lspServers = [#{
\    name: 'bashls',
\    filetype: 'sh',
\    path: $HOME . '/bin/node/node_modules/.bin/bash-language-server',
\    args: ['start'],
\ }, #{
\    name: 'pylsp',
\    filetype: 'python',
\    path: $HOME . '/bin/python/bin/pylsp',
\    args: [],
\    initializationOptions: {
\        'pylsp': {
\           'plugins': {
\               'ruff': {
\                   'lineLength': 120,
\               },
\           },
\        },
\    },
\ }, #{
\    name: 'basedpyright',
\    filetype: 'python',
\    path: $HOME . '/bin/python/bin/basedpyright-langserver',
\    args: ['--stdio'],
\ }, #{
\    name: 'ruff-lsp',
\    filetype: 'python',
\    path: $HOME . '/bin/python/bin/ruff',
\    args: ['server'],
\ }, #{
\    name: 'rust',
\    filetype: 'rust',
\    path: $HOME . '/bin/cargo/bin/rust-analyzer',
\    args: [],
\    syncInit: v:true,
\ }]

if !executable(lspServers[0].path)
    let lspServers = []
endif

autocmd User LspSetup call LspAddServer(lspServers)
setlocal tagfunc=lsp#lsp#TagFunc

nnoremap gd <Cmd>LspGotoDefinition<CR>
nnoremap gD <Cmd>LspGotoImpl<CR>
nnoremap K <Cmd>silent LspHover<CR>

nmap <leader>db <Plug>VimspectorToggleBreakpoint
nmap <leader>dB <Plug>VimspectorToggleConditionalBreakpoint
nmap <leader>dc <Plug>VimspectorContinue
nmap <leader>de <Plug>VimspectorBalloonEval
nmap <leader>dF <Plug>VimspectorAddFunctionBreakpoint
nmap <leader>di <Plug>VimspectorStepInto
nmap <leader>dl <Plug>VimspectorLaunch
nmap <leader>dO <Plug>VimspectorStepOut
nmap <leader>do <Plug>VimspectorStepOver
nmap <leader>dp <Plug>VimspectorPause
nmap <leader>dr <Plug>VimspectorRestart
nmap <leader>ds <Plug>VimspectorStop
nmap <leader>dw <Plug>VimspectorWatch
nmap <leader>dx <Plug>VimspectorRunToCursor

let g:yankstack_map_keys = 0
call yankstack#setup()
nmap <C-p> <Plug>yankstack_substitute_older_paste
nmap <C-n> <Plug>yankstack_substitute_newer_paste
