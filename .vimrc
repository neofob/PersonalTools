set background=dark
call pathogen#infect()
syntax on
filetype plugin indent on
colorscheme dante
set hls
set nu

if has("autocmd")
	augroup C
		autocmd!
		autocmd FileType c,cpp set textwidth=80
		autocmd BufRead,BufNewFile ~/src/*[c|h] setlocal tabstop=8
		autocmd BufRead,BufNewFile ~/src/*[c|h] setlocal tags+=~/src/linux/tags
		if has("syntax")
			highlight WhiteSpace ctermbg=red guibg=red
			autocmd Syntax c,cpp syn match WhiteSpace /\s\+$/
		endif
	augroup END
endif
