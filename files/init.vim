let mapleader = ","

if !exists('g:vscode')
    " Load optional vim plugins
    packadd! \*

    set modeline
    set number
    set relativenumber
    let g:strip_whitespace_on_save = 1

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
        \ 'component_function': {
        \   'fugitive': 'FugitiveHead'
        \ },
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
let g:terminal_scrollback_buffer_size = 100000

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

" Beautify JSON
map <Leader>j :%!python -m json.tool<CR>

" Confirm quit rather than :q!
map ZQ :q<CR>

" Disable Ex mode
map Q <Nop>

if exists('g:vscode')
    autocmd CmdwinEnter * quit
endif

nnoremap <silent> <Leader>a :ArgWrap<CR>

set undofile
set undodir=~/.config/nvim/undo
