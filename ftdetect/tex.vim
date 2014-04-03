autocmd BufNewFile,BufRead *.tex setlocal magic
autocmd BufNewFile,BufRead *.tex exec 'iu ' g:tab_key

" UNCOMENT THE NEXT LINE IF YOU WANT ULTISNIPS SUPPORT
"autocmd BufNewFile,BufRead *.tex exec 'inoremap <buffer> <silent> ' . g:tab_key ' <C-R>=(Ulti_ExpandOrJump_and_getRes() > 0)?"":kalatex#clean_and_jump()<CR>'



" COMMENT THE NEXT LINE IF YOU WANT ULTISNIPS SUPPORT
autocmd BufNewFile,BufRead *.tex exec 'inoremap <buffer> <silent> ' . g:tab_key ' kalatex#clean_and_jump()<CR>'

autocmd BufNewFile,BufRead *.tex exec 'inoremap <buffer> <silent> ' . g:backtick_key ' <C-R>=kalatex#get_backtick_string(0)<cr>'
autocmd BufNewFile,BufRead *.tex exec 'inoremap <buffer> <silent> ' . g:quote_key ' <C-R>=kalatex#get_quote_string(0)<cr>'
autocmd BufNewFile,BufRead *.tex exec 'inoremap <buffer> <silent> ' . g:semicolon_key ' <C-R>=kalatex#get_semicolon_string(0)<cr>'
