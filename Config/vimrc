set background=dark
syntax on
filetype plugin indent on
colorscheme dante
set hls
set nu
set rtp+=~/src/powerline/powerline/bindings/vim
set laststatus=2
set t_Co=256
let g:Powerline_symbols="fancy"

if has("autocmd")
	augroup C
		autocmd!
		autocmd FileType c,cpp set textwidth=80
		autocmd BufRead,BufNewFile *[c|h] setlocal tabstop=8
		autocmd BufRead,BufNewFile *[c|h] setlocal shiftwidth=8
		autocmd BufRead,BufNewFile *[c|h] setlocal tags+=~/src/linux/tags
		if has("syntax")
			highlight WhiteSpace ctermbg=red guibg=red
			autocmd Syntax c,cpp syn match WhiteSpace /\s\+$/
		endif
	augroup END

	augroup Python
		autocmd!
		autocmd FileType py set textwidth=80
		autocmd BufRead,BufNewFile *.py setlocal tabstop=4
		autocmd BufRead,BufNewFile *.py setlocal shiftwidth=4
		autocmd BufRead,BufNewFile *.py setlocal expandtab
		if has("syntax")
			highlight WhiteSpace ctermbg=red guibg=red
			autocmd Syntax python syn match WhiteSpace /\s\+$/
		endif
	augroup END

	augroup Markdown
		autocmd BufNewFile,BufRead *.md,*.markdown,*.mdown setl filetype=markdown
		autocmd BufNewFile,BufRead *.md,*.markdown,*.mdown setlocal textwidth=80 tabstop=2 shiftwidth=2
		if has("syntax")
			highlight WhiteSpace ctermbg=red guibg=red
			autocmd Syntax markdown syn match WhiteSpace /\s\+$/
		endif
	augroup END
endif

autocmd BufNewFile,BufRead Vagrantfile setl filetype=ruby
