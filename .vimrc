set nocompatible
filetype off

syntax on
filetype plugin indent on
let mapleader = "'"

set number
set relativenumber

set modelines=0

nnoremap <Enter> o<Esc>

set hlsearch
set incsearch
set ignorecase
set showmatch
map <leader>h :let @/=""<cr> " clear search

set showmode
set showcmd
set ttyfast
set hidden

nnoremap j gj
nnoremap k gk

set wrap
set textwidth=80
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround

set scrolloff=6
set matchpairs+=<:> " use % to jump between pairs
