local cmd = vim.cmd
local map = vim.keymap.set

local M = {}

M.setup = function(opts)
	-- print("lua/putline.lua")
	cmd([[
	 function! s:putline(how, map) abort
	  let [body, type] = [getreg(v:register), getregtype(v:register)]
	  if type ==# 'V'
	    exe 'normal! "'.v:register.a:how
	  else
	    call setreg(v:register, body, 'l')
	    exe 'normal! "'.v:register.a:how
	    call setreg(v:register, body, type)
	  endif
	  silent! call repeat#set("\<Plug>(unimpaired-put-".a:map.")")
	endfunction

	nnoremap <silent> <Plug>(unimpaired-put-above-reformat)  :<C-U>call <SID>putline(v:count1 . 'gP', 'Above')<CR>=']
	nnoremap <silent> <Plug>(unimpaired-put-below-reformat)  :<C-U>call <SID>putline(v:count1 . 'gp', 'Below')<CR>=']
	  ]])
	map("n", "gP", "<Plug>(unimpaired-put-above-reformat)g$:set ve= ve=all<CR>")
	map("n", "gp", "<Plug>(unimpaired-put-below-reformat)g$:set ve= ve=all<CR>")
end

return M
