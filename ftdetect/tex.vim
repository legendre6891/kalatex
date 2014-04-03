autocmd BufNewFile,BufRead *.tex setlocal magic
autocmd BufNewFile,BufRead *.tex exec 'iu ' g:tab_key
autocmd BufNewFile,BufRead *.tex call kalatex#setup_keybinds()

" UNCOMENT THE NEXT SEVERAL LINES IF YOU WANT ULTISNIPS SUPPORT
" =======================
"let g:ulti_expand_res = 0
"function! Ulti_ExpandOrJump_and_getRes()
	"call UltiSnips#ExpandSnippet()
	"return g:ulti_expand_res
"endfunction
"
"autocmd BufNewFile,BufRead *.tex exec 'inoremap <buffer> <silent> ' . g:tab_key ' <C-R>=(Ulti_ExpandOrJump_and_getRes() > 0)?"":kalatex#clean_and_jump()<CR>'
" =======================



" COMMENT OUT THE NEXT LINE IF YOU WANT ULTISNIPS SUPPORT
autocmd BufNewFile,BufRead *.tex exec 'inoremap <buffer> <silent> ' . g:tab_key ' <C-R>=kalatex#clean_and_jump()<CR>'
" COMMENT OUT THE PREVIOUS LINE IF YOU WANT ULTISNIPS SUPPORT

autocmd BufNewFile,BufRead *.tex exec 'inoremap <buffer> <silent> ' . g:backtick_key ' <C-R>=kalatex#get_backtick_string(0)<cr>'
autocmd BufNewFile,BufRead *.tex exec 'inoremap <buffer> <silent> ' . g:quote_key ' <C-R>=kalatex#get_quote_string(0)<cr>'
autocmd BufNewFile,BufRead *.tex exec 'inoremap <buffer> <silent> ' . g:semicolon_key ' <C-R>=kalatex#get_semicolon_string(0)<cr>'
