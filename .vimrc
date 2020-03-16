" Basic keybindings:
" crtl + n      - opens nerd tree. Opening files from tree:
"                o - opens file
"                i - open vertically
"                s - opens horizontally
" crtl + hjkl   - split navigation
" space         - folds level
" :sp || :vs    - open in layout (vert and horizon) 
" ls            - list buffers
" b             - switch to buffer
" bd            - delete buffer
" crtl + g      - goto definition
" v             - select
" V             - select lines
" crtl - v      - select rectangles
" d             - cut
" y             - copy
" P             - paste before cursor
" p             - paste after cursor


set nocompatible              " required
set encoding=utf-8
set number relativenumber
set clipboard=unnamedplus
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)
Plugin 'tmhedberg/SimpylFold'
Plugin 'sainnhe/edge'
Plugin 'preservim/nerdtree'
Plugin 'dense-analysis/ale'
Plugin 'chriskempson/base16-vim'
" ...

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Specify areas where screen splits
set splitbelow
set splitright

" Moving between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

" PEP8 indent
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=119 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

" frontend indent etc
au BufNewFile,BufRead *.js, *.html, *.css, *.scss
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2

au BufRead, BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" better fold and ALE config

let g:SimpylFold_docstring_preview=1

let g:ale_linters = {
			\ 'python': ['pyls', 'flake8'],
			\}

let g:ale_fixers = {
			\ '*': ['trim_whitespace'],
			\ 'python': ['black'],
			\ 'css': ['prettier'],
			\ 'scss': ['prettier'],
			\ 'html': ['prettier'],
			\ 'javascript': ['prettier'],
			\ 'json': ['prettier'],
			\ 'php': ['prettier'],
			\ 'yaml': ['prettier'],
			\}

let g:ale_completion_enabled = 1
let g:ale_completion_tsserver_autoimport = 1

nmap <silent> <F5> <Plug>(ale_previous_wrap)
nmap <silent> <C-F5> <Plug>(ale_next_wrap)
map <C-G> :ALEGoToDefinition<CR>
map <C-F11> :ALEGoToDefinitionInSplit<CR>
map <C-F12> :ALEGoToDefinitionInVSplit<CR>
set omnifunc=ale#completion#OmniFunc

" Python syntax

let python_highlight_all=1
syntax on

" Theme config
" set termguicolors
" set background=dark
" set t_Co=256
" let g:edge_style = 'proton'
"   
" colorscheme edge

set termguicolors
colorscheme base16-ocean

map <C-n> :NERDTreeToggle<CR>
 
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree
