" VIM_CDLATEX
"if exists('g:loaded_kalatex') || &cp
  "finish
"endif
let g:loaded_kalatex = 1

" GLOBAL OPTIONS 
let g:tab_key = "<Tab>"
let g:backtick_key = "`"
let g:quote_key = "'"
let g:semicolon_key = ";"
let g:max_level=3


let g:backtick_dictionary = {
			\ 'a' : ['\alpha'],
			\ 'b' : ['\beta'],
			\ 'c' : [],
			\ 'd' : ['\delta'],
			\ 'e' : ['\epsilon', '\varepsilon'],
			\ 'f' : ['\phi', '\varphi'],
			\ 'g' : ['\gamma'],
			\ 'h' : ['\eta'],
			\ 'i' : ['\in', '\iota'],
			\ 'j' : [],
			\ 'k' : ['\kappa'],
			\ 'l' : ['\lambda'],
			\ 'm' : ['\mu'],
			\ 'n' : ['\nu'],
			\ 'o' : ['\omega'],
			\ 'p' : ['\pi'],
			\ 'q' : ['\theta', '\vartheta'],
			\ 'r' : ['\rho'],
			\ 's' : ['\sigma'],
			\ 't' : ['\tau'],
			\ 'u' : ['\upsilon'],
			\ 'v' : ['\vee'],
			\ 'w' : ['\xi'],
			\ 'x' : ['\chi'],
			\ 'y' : ['\psi'],
			\ 'z' : ['\zeta'],
			\ '/' : ['\frac{@}{}'],
			\ 'I' : ['\int{@}{}'],
			\ '(' : ['\bigl( @ \bigr)', '\biggl( @ \biggr)', '\left( @ \right)'],
			\ '`' : ['`']}


let g:quote_dictionary = {
			\ 't' : ['\text{@}'],
			\ 'e' : ['\emph{@}'],
			\ 'b' : ['\textbf{@}'],
			\ 'i' : ['\textit{@}'],
			\ 'I' : ['\textit'],
			\ "'" : ["'"]}

let g:semicolon_dictionary = {
			\ ';' : [';'],
			\ '/' : ['\frac{@}{}'],
			\ 's' : ['\sum_{@}^{}'],
			\ 'p' : ['\product_{@}^{}'],
			\ 'i' : ['\int_{@}^{}']}



function! kalatex#setup_keybinds()
	inoremap <buffer> <silent> $ $$<Left>
	inoremap <buffer> <silent> ( ()<Left>
	inoremap <buffer> <silent> { {}<Left>
	inoremap <buffer> <silent> [ []<Left>
	inoremap <buffer> <silent> _ _{}<Left>
	inoremap <buffer> <silent> ^ ^{}<Left>
endfunction






" THE FOLLOWING FUNCTIONS 
" SUPPORT TAB ADVANCES
function! kalatex#before_closing()
	let l = line('.')
	let c = col('.')


	" We need to stop before any closing bracket that is preceded
	" by one of ([{}])
	let closing_brackets = '\])}'
	let required_preceding_char = '({[\]})'
	let before_closing_brackets = searchpos('\([' . required_preceding_char . ']\)\@<=\([' . closing_brackets . ']\)', 'nW')


	" If we get stuck at the current location
	" (e.g. the cursor is at (|)
	" then first exit the parantheses and do a search again
	if before_closing_brackets[0] == l && before_closing_brackets[1] == c
		call cursor(l,c+1)
		let before_closing_brackets = searchpos('\([' . required_preceding_char . ']\)\@<=\([' . closing_brackets . ']\)', 'nW')
		call cursor(l, c)
	endif

	return [before_closing_brackets]
endfunction


function! kalatex#after_closing()

	" We need to stop after any closign bracket that is NOT
	" followed by any of ({[_^
	let closing_brackets = '\])}'
	let required_not_match_following_char = '({[_^'
	let after_closing_brackets = searchpos('[' . closing_brackets . ']\([' . required_not_match_following_char . ']\)\@!','nWc')

	" If a match is actually found, we need to advance the cursor
	" one position (since we are positioning AFTER the cursor)
	if after_closing_brackets[0] > 0
		let after_closing_brackets[1] = after_closing_brackets[1] + 1
	endif

	return [after_closing_brackets]
endfunction

function! kalatex#dollar()
	" Search for any dollar signs after the cursor
	" and jump across it
	" Note the 'c' option is used so that 
	" we jump over the $ in |$, where |
	" is the current location of the cursor.
	let dollar_l = searchpos('\$','nWc')

	" If a dollar sign is found,
	" We need to jump AFTER the dollar sign
	if dollar_l[0] > 0
		let dollar_l[1] += 1
	endif
	return [dollar_l]
endfunction


function! kalatex#position_list_compare_after(l1,l2)
	let a = a:l1[0]
	let b = a:l1[1]
	let x = a:l2[0]
	let y = a:l2[1]
	return (a > x || (a == x && b > y))
endfunction

function! MyCompare(l1, l2)
	let one_after = kalatex#position_list_compare_after(a:l1, a:l2)
	let two_after = kalatex#position_list_compare_after(a:l2, a:l1)
	if (one_after != 1 && two_after != 1)
		return 0
	elseif a:l1 == [0,0] 
		return 1
	elseif a:l2 == [0,0]
		return -1
	elseif one_after == 1
		return 1
	else
		return -1
	endif
endfunction


" Generate a list of tabstops
function! kalatex#tab_stop()

	" Get a list of all tabstops as defined by the 
	" rules above. Sort them, so that we know where to jump next.
	let r = kalatex#before_closing() + kalatex#after_closing() + kalatex#dollar()
	call filter(r, 'v:val[0] > 0 && v:val[1] > 0')
	call sort(r, function("MyCompare"))

	" Append a [0,0] at the end,
	" so that if there is no place to jump
	" we stay where we are at now.
	call add(r, [0,0])
	return r
endfunction

function! kalatex#next_tab_stop()
	" Get the first location we need to jump to
	let r = kalatex#tab_stop()[0]
	return r
endfunction

function! kalatex#tab_advance_check()
	let r = kalatex#next_tab_stop()
	" Returns 1 if and only if we can
	" advance the tab from this position.
	return !(r[0] == 0 && r[1] == 0)
endfunction


function! kalatex#tab_advance_to(l,c)
	let r = [a:l, a:c]
	call cursor(r[0],r[1])
	startinsert

	" Return 1 if and only if we are able to jump
	return !(r[0] == 0 && r[1] == 0)
endfunction

function! kalatex#tab_advance()
	let r = kalatex#next_tab_stop()
	return kalatex#tab_advance_to(r[0], r[1])
	"call cursor(r[0],r[1])
	"startinsert

	" Return 1 if and only if we are able to jump
	"return !(r[0] == 0 && r[1] == 0)
endfunction

" THE FOLLOWING FUNCTIONS SUPPORT ABBREVIATIONS
" OBVIATED BY SNIPMATE

" THE FOLLOWING FUNCTIONS CLEAN UP SUB/SUPERSCRIPTS

" There are essentially two cases ^{|a} and ^{a|}

function! kalatex#script_chars(c)
	return a:c ==# '^' || a:c ==# '_'
endfunction

function! kalatex#need_cleanup()
	" returns 0 
	" if no cleanup needed
	"
	" returns -1 if we are in the first case
	" 1 in the second case.
	
	let c0 = getline('.')[col('.') - 1]
	let c1 = getline('.')[col('.')]
	let c2 = getline('.')[col('.') + 1]
	let b1 = getline('.')[col('.') - 2]
	let b2 = getline('.')[col('.') - 3]
	let b3 = getline('.')[col('.') - 4]

	" test for case 1
	" c0 = ?
	" c1 = }
	" b1 = {
	" b2 = _^
	if b1 ==# '{' && kalatex#script_chars(b2) && c1 ==# '}'
		return -1
	" test for case 2
	" c0 = }
	" b2 = {
	" b3 = _^
	elseif c0 ==# '}' && kalatex#script_chars(b3) && b2 ==# '{'
		return 1
	else
		return 0
	endif
endfunction


function! kalatex#perform_cleanup()
	let f = kalatex#need_cleanup()
	if f == 0
		return 0
	else
		let c0 = getline('.')[col('.') - 1]
		let c1 = getline('.')[col('.')]
		let c2 = getline('.')[col('.') + 1]
		let b1 = getline('.')[col('.') - 2]
		let b2 = getline('.')[col('.') - 3]
		let b3 = getline('.')[col('.') - 4]
		if f == -1
			execute "normal! hxlxa"
		elseif f == 1
			execute "normal! hhxlxa"
		endif
		return 1
	endif
endfunction

" THE FOLLOWING FUNCTION(S) TIE UP EVERYTHING TO
" DO WITH TAB
function! kalatex#clean_and_jump()
	let t = kalatex#next_tab_stop()
	let nc = kalatex#need_cleanup()

	
	call kalatex#perform_cleanup()

	if nc != 0
		let t[1] -= 2
	endif

	call kalatex#tab_advance_to(t[0],t[1])
	return ""
endfunction




" Primitive support for snippets


function! kalatex#end_of_line()
	let a = col('$')
	let b = col('.')
	return (a == b+1)
endfunction

function! kalatex#add_at_symbol(s)
	if strridx(a:s, '@') < 0
		return a:s . '@'
	else
		return a:s
	endif
endfunction

function! kalatex#execute_snippet_string(s)
	execute "normal! a" . a:s . "\<Esc>F@"
	execute "normal! x"

	if kalatex#end_of_line() && a:s[-1:]=='@'
		startinsert!
	else
		startinsert
	endif
	return ""
endfunction

" Handle backticks leveling
function! kalatex#get_backtick_string(index)
	let c = getchar()
	let s = nr2char(c)
	if s == '`'
		return kalatex#get_backtick_string((a:index + 1)%g:max_level)
	elseif s == "\<C-c>" " i.e. C-c
		return "" " i.e. quit
	else
		if has_key(g:backtick_dictionary, s)
			let l  = g:backtick_dictionary[s]
			if a:index < len(l)
				"return l[a:index]
				call kalatex#execute_snippet_string(kalatex#add_at_symbol(l[a:index]))
			endif
		endif
		return ""
	endif
endfunction


" aprostrophes
function! kalatex#get_quote_string(index)
	let c = getchar()
	let s = nr2char(c)
	if s == "'"
		return kalatex#get_quote_string((a:index + 1)%g:max_level)
	elseif s == "\<C-c>" " i.e. C-c
		return "" " i.e. quit
	else
		if has_key(g:quote_dictionary, s)
			let l  = g:quote_dictionary[s]
			if a:index < len(l)
				"return l[a:index]
				call kalatex#execute_snippet_string(kalatex#add_at_symbol(l[a:index]))
			endif
		endif
		return ""
	endif
endfunction


function! kalatex#get_semicolon_string(index)
	let c = getchar()
	let s = nr2char(c)
	if s == ';'
		return kalatex#get_semicolon_string((a:index + 1)%g:max_level)
	elseif s == "\<C-c>" " i.e. C-c
		return "" " i.e. quit
	else
		if has_key(g:semicolon_dictionary, s)
			let l = g:semicolon_dictionary[s]
			if a:index < len(l)
				"return l[a:index]
				call kalatex#execute_snippet_string(kalatex#add_at_symbol(l[a:index]))
			endif
		endif
		return ""
	endif
endfunction


"inoremap <Tab> <C-R>=(kalatex#tab_advance() > 0) ? "" : ""<cr>
"inoremap <C-d> <C-R>=(kalatex#perform_cleanup() > 0) ? "" : ""<cr>
