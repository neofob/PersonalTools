set autoindent
set background=dark
set hlsearch
set incsearch
set laststatus=2
set nocompatible
set showmatch
set formatoptions=tcroql

map <c-n> :bnext<cr>
map <c-p> :bprevious<cr>
map <m-n> :cnext<cr>
map <m-p> :cprevious<cr>
map <c-j> gqap

abbreviate _time <c-r>=strftime("%H:%M")<cr>
abbreviate _date <c-r>=strftime("%a %b %d %T %Z %Y")<cr>

filetype plugin indent on

if has("viminfo")
	set viminfo=""
endif

if has("smartindent")
	set smartindent
endif

if has("wildmenu")
	set wildmenu
endif

if has("syntax")
	syntax on
endif

if has("windows")
	set hidden
endif

if has("gui_running")
	colorscheme koehler
	set guioptions=aci
endif

if has("spell")
	set spelllang=en_us
endif

if has("cscope")
	set cscopetag
	set nocscopeverbose
	if filereadable("cscope.out")
		cscope add cscope.out
	elseif $CSCOPE_DB != ""
		cscope add $CSCOPE_DB
	endif
	set cscopeverbose
endif

if has("autocmd")
	augroup C
		autocmd!
		autocmd FileType c,cpp set textwidth=80
		if has("cindent")
			autocmd FileType c,cpp set cindent
			autocmd FileType c,cpp set sw=2
			autocmd FileType c,cpp set cinoptions=t0,(0
		endif
		if has("syntax")
			highlight WhiteSpace ctermbg=red guibg=red
			autocmd Syntax c,cpp syn match WhiteSpace /\s\+$/
		endif
		autocmd FileType c,cpp set tabstop=2
		autocmd FileType c,cpp set expandtab
	augroup END

	augroup Python
		autocmd!
		autocmd FileType python set tabstop=4
		autocmd FileType python set softtabstop=4
		autocmd FileType python set shiftwidth=4
		autocmd FileType python set expandtab
		autocmd FileType python set autoindent
		if has("smartindent")
			autocmd FileType python set smartindent
		endif
	augroup END

	augroup Shell
		autocmd!
		autocmd FileType sh set tabstop=4
		autocmd FileType sh set softtabstop=4
		autocmd FileType sh set shiftwidth=4
		autocmd FileType sh set expandtab
		autocmd FileType sh set autoindent
		if has("smartindent")
			autocmd FileType sh set smartindent
		endif
	augroup END

	augroup Subversion
		autocmd!
		autocmd FileType svn set textwidth=72
	augroup END

	augroup Mail
		autocmd!
		autocmd FileType mail set textwidth=72
		"if has("spell")
		"	autocmd Filetype mail set spell
		"endif
	augroup END

	augroup Tex
		autocmd!
		if has("spell")
			autocmd Filetype tex set spell
		endif
	augroup END

	augroup Xml
		autocmd!
		autocmd FileType xml set tabstop=4
		autocmd FileType xml set softtabstop=4
		autocmd FileType xml set shiftwidth=4
		autocmd FileType xml set autoindent
		if has("smartindent")
			autocmd FileType xml set smartindent
		endif
	augroup END
endif

"if $TERM == 'screen'
"	exe "set title titlestring=vim:%f"
"	exe "set title t_ts=\<ESC>k t_fs=\<ESC>\\"
"endif

nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>

" Using 'CTRL-spacebar' then a search type makes the vim window
" split horizontally, with search result displayed in
" the new window.

nmap <C-Space>s :scs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>g :scs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>c :scs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>t :scs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>e :scs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-Space>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-Space>d :scs find d <C-R>=expand("<cword>")<CR><CR>

" Hitting CTRL-space *twice* before the search type does a vertical
" split instead of a horizontal one

nmap <C-Space><C-Space>s \:vert scs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>g \:vert scs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>c \:vert scs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>t \:vert scs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>e \:vert scs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>i \:vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-Space><C-Space>d \:vert scs find d <C-R>=expand("<cword>")<CR><CR>
