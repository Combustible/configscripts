


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Vundle stuff

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'Valloric/YouCompleteMe'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
"Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
"Plugin 'user/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


if has('cscope')
	set cscopetag cscopeverbose

	if has('quickfix')
		" set cscopequickfix=s-,c-,d-,i-,t-,e-
	endif

"cnoreabbrev csa cs add
"cnoreabbrev csf cs find
"cnoreabbrev csk cs kill
"cnoreabbrev csr cs reset
"cnoreabbrev css cs show
"cnoreabbrev csh cs help

	function! LoadCscope()
		let dbcount=1
		let l:db = "junk"
		while (!empty(l:db))
			let l:db = findfile("cscope.out", ".;", dbcount)
			if (!empty(l:db))
				let path = strpart(l:db, 0, match(l:db, "/cscope.out$"))
				set nocscopeverbose " suppress 'duplicate connection' error
				exe "cs add " . l:db . " " . path
				set cscopeverbose
				let dbcount = dbcount + 1
			endif
		endwhile
	endfunction

	au BufEnter /* call LoadCscope()

endif


function! Astylelinux()
	exe "write"
	set autoread
	exe "!astyle --style=linux --indent=tab=8 --convert-tabs --indent-preprocessor --min-conditional-indent=3 --max-instatement-indent=40 --pad-oper --unpad-paren --pad-header --align-pointer=name --indent-namespaces --add-one-line-brackets --max-code-length=100 %"
	set noautoread
endfunction
function! Astyleallman()
	exe "write"
	set autoread
	exe "!astyle --style=allman --indent=tab=4 --convert-tabs --indent-preprocessor --min-conditional-indent=3 --max-instatement-indent=40 --pad-oper --unpad-paren --pad-header --align-pointer=name --indent-namespaces --add-one-line-brackets --max-code-length=100 %"
	set noautoread
endfunction

function! TabsOn()
	set list listchars=tab:\>\ ,trail:-
endfunction
function! TabsOff()
	set nolist
endfunction

" More info here: http://vim.wikia.com/wiki/Highlight_unwanted_spaces
" Show tabs that are not at the start of a line:
" Show spaces used for indenting from the start of a line, unless the next
" immediate character is a *
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
autocmd Filetype c match ExtraWhitespace /^[^/].*[^\t]\zs\t\+\|^\zs \+\ze[^\*]/

" Fix whitespace on saving
autocmd BufWritePre * :%s/\s\+$//e


set tabstop=4
set shiftwidth=4

" Text files don't use tabs
autocmd FileType text setlocal expandtab

" allow backspacing over everything in insert mode
set bs=indent,eol,start
" always set autoindenting on
set ai
" keep lots of command line history
set history=1000
" show the cursor position all the time
set ruler

" If input is from stdin, assume it hasn't been modified (and thus will not require saving or ! to escape)
autocmd StdinReadPost * set nomodified

" Fix weird NERDTree characters
let g:NERDTreeDirArrows=0

" Open nerdtree with ,ne
let mapleader = ","
nmap <leader>ne :NERDTree<cr>

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Control + S saves current file
nmap <c-s> :w<CR>
imap <c-s> <Esc>:w<CR>a

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %
