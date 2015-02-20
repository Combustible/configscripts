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

	" Fix whitespace on saving
	autocmd BufWritePre * :%s/\s\+$//e

	set tabstop=4
	set shiftwidth=4
	set list listchars=tab:\>\ ,trail:-

	" More info here: http://vim.wikia.com/wiki/Highlight_unwanted_spaces
	" Show tabs that are not at the start of a line:
	" Show spaces used for indenting from the start of a line, unless the next
	" immediate character is a *
	highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
	autocmd Filetype c match ExtraWhitespace /^[^/].*[^\t]\zs\t\+\|^\zs \+\ze[^\*]/

	command -nargs=0 Cscope cs add $VIMSRC/src/cscope.out $VIMSRC/src

	function! LoadCscope()
		let db = findfile("cscope.out", ".;")
		if (!empty(db))
			let path = strpart(db, 0, match(db, "/cscope.out$"))
			set nocscopeverbose " suppress 'duplicate connection' error
			exe "cs add " . db . " " . path
			set cscopeverbose
		endif
	endfunction
	au BufEnter /* call LoadCscope()

endif

set mouse=r
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

