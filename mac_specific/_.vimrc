" Use Vim settings, rather then Vi settings (much better!).
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" I like 4 spaces for indenting
set shiftwidth=4

" I like 4 stops
set tabstop=4

" Always  set auto indenting on
set autoindent

" mouse drag doesn't put you in visual mode
set mouse-=a

" do not keep a backup files 
set nobackup
set nowritebackup

" show the cursor position all the time
set ruler

" show (partial) commands
set showcmd

" Set ignorecase on
set ignorecase

" smart search (override 'ic' when pattern has uppers)
set scs

" showmatch: Show the matching bracket for the last ')'?
set showmatch

syntax enable

" comando per scrivere un file usando sudo. uso: :Sudow
command -bar -nargs=0 Sudow :silent execute "w !sudo tee % " | edit!
