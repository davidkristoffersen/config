fun! s:plugin()
	if !exists('g:vimpager')
		let g:vimpager = {}
	endif

	if !exists('g:less')
		let g:less	 = {}
	endif
	let g:less.enabled = 0
endfun
call s:plugin()
