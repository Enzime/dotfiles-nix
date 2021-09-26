function! Cond(cond, ...)
    let opts = get(a:000, 0, {})
    return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

function! DoRemote(arg)
    UpdateRemotePlugins
endfunction

function! PlugIf(cond, repo, ...)
    let opts = get(a:000, 0, {})
    let opts = a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
    Plug a:repo, opts
endfunction

command! -nargs=+ -bar PlugIf call PlugIf(<args>)

call plug#begin(stdpath('data') . '/plugged')

Plug 'airodactyl/hybrid-krompus.vim'
Plug 'airodactyl/neovim-ranger'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'rhysd/clever-f.vim'
Plug 'junegunn/vim-easy-align'
Plug 'will133/vim-dirdiff'

" Automatic indent settings
Plug 'tpope/vim-sleuth'

" Show yank visually
Plug 'kana/vim-operator-user'
Plug 'haya14busa/vim-operator-flashy'

" Add better search highlighting
Plug 'haya14busa/incsearch.vim'

" Highlight current word under cursor
Plug 'RRethy/vim-illuminate'

" Display colours inline
Plug 'ap/vim-css-color'

" Show marks on the sidebar
Plug 'kshenoy/vim-signature'

" Bracket wrapping
Plug 'FooSoft/vim-argwrap'

PlugIf !exists('g:vscode'), 'itchyny/lightline.vim'
PlugIf !exists('g:vscode'), 'Shougo/denite.nvim', { 'do': function('DoRemote') }
PlugIf !exists('g:vscode'), 'tpope/vim-fugitive'
PlugIf !exists('g:vscode'), 'tpope/vim-commentary'
PlugIf !exists('g:vscode'), 'mbbill/undotree'

PlugIf !exists('g:vscode'), 'octol/vim-cpp-enhanced-highlight'
PlugIf !exists('g:vscode'), 'pangloss/vim-javascript'
PlugIf !exists('g:vscode'), 'mxw/vim-jsx'
PlugIf !exists('g:vscode'), 'LnL7/vim-nix'
PlugIf !exists('g:vscode'), 'nathangrigg/vim-beancount'
PlugIf !exists('g:vscode'), 'tomlion/vim-solidity'

" Adds linting
PlugIf !exists('g:vscode'), 'w0rp/ale'

call plug#end()

let mapleader = ","

if !exists('g:vscode')
    set modeline
    set number
    set relativenumber

    " Support 24-bit colours in terminals
    set termguicolors

    " Lightline settings
    set noshowmode
    set laststatus=2

    " Show current git branch in lightline
    let g:lightline = {
        \ 'active': {
        \   'left': [ [ 'mode', 'paste'],
        \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
        \ },
        \ 'component': {
        \   'fugitive': '%{fugitive#head()}'
        \ },
        \ 'component_visible_condition': {
        \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
        \ }
    \ }

    call denite#custom#var('file/rec', 'command',
    \ ['rg', '--files', '--glob', '!.git', '--color', 'never'])

    call denite#custom#var('grep', 'command', ['rg'])
    call denite#custom#var('grep', 'default_opts',
                    \ ['--vimgrep', '--no-heading'])
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'final_opts', [])

    nnoremap <Leader>b :Denite -default-action=open buffer<CR>
    nnoremap <Leader>f :Denite -default-action=open file/rec<CR>
    nnoremap <Leader>F :Denite -default-action=tabopen file/rec<CR>
    nnoremap <Leader>s :Denite -default-action=split file/rec<CR>
    nnoremap <Leader>v :Denite -default-action=vsplit file/rec<CR>
    nnoremap <Leader>t :Denite -default-action=open tab<CR>
    nnoremap <Leader>/ :Denite -default-action=open -no-empty grep:.<CR>

    map <Leader>gs :Gstatus<CR>
    map <Leader>gd :Gdiff<CR>
    map <Leader>gb :Gblame<CR>
    map <Leader>g<SPACE> :Git<SPACE>

    nnoremap <Leader>pi :PlugInstall<CR>
    nnoremap <Leader>pu :PlugUpdate<CR>

    nnoremap <Leader>G :UndotreeToggle<CR>
endif

if !exists('g:vscode')
    nmap cm <Plug>Commentary
else
    nmap cm <Plug>VSCodeCommentary
endif

set background=dark
colorscheme hybrid-krompus

" Customize colour of vim-operator-flashy
hi Flashy ctermbg=5 guibg=#ff0084

" Illuminate matches like visual
hi link illuminatedWord Visual

syntax on
set mouse=a
set nowrap

" Defaults for if `sleuth.vim` fail
set expandtab
set softtabstop=4
set shiftwidth=0
set tabstop=4
set autoindent

" Show special whitespacing chars
set list
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮,trail:·

" Lines before page starts scrolling
set scrolloff=1
set sidescroll=1

" Remove find highlight
nnoremap <Leader>h :noh<CR>

" Edit/Reload nvimrc
nnoremap <Leader>e :edit $MYVIMRC<CR>
nnoremap <Leader>E :tabedit $MYVIMRC<CR>
nnoremap <Leader>R :source $MYVIMRC<CR>

" Operator remapping
map y <Plug>(operator-flashy)
map Y "+<Plug>(operator-flashy)

" Make terminal mode magical
let g:terminal_scrollback_buffer_size = 100000

map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" Beautify JSON
map <Leader>j :%!python -m json.tool<CR>

" Confirm quit rather than :q!
map ZQ :q<CR>

" Disable Ex mode
map Q <Nop>

if exists('g:vscode')
    noremap q: <Nop>
endif

nnoremap <silent> <Leader>a :ArgWrap<CR>

set undofile
set undodir=~/.config/nvim/undo