local v = vim.v
local f = vim.fn

local M = {}

local function put(keys)
	local name = v.register
	local contents = f.getreg(name)
	local type = f.getregtype(name)
	local linewise = "l"
	local isLinewise = type == "V"

	if isLinewise then
		print('normal! "' .. name .. keys)
		f.execute('normal! "' .. name .. keys)
	else
		f.setreg(name, contents, linewise)
		f.execute('normal! "' .. name .. keys)
		f.setreg(name, contents, type)
	end
end

M.above = function() put("]P") end
M.below = function() put("]p") end

M.setup = function(opts)
	-- nnoremap <silent> <Plug>(unimpaired-put-above-reformat)  :<C-U>call <SID>putline(v:count1 . 'gP', 'Above')<CR>=']
	-- nnoremap <silent> <Plug>(unimpaired-put-below-reformat)  :<C-U>call <SID>putline(v:count1 . 'gp', 'Below')<CR>=']
	--   ]])
	-- map("n", "gP", "<Plug>(unimpaired-put-above-reformat)g$:set virtualedit= virtualedit=all<CR>")
	-- map("n", "gp", "<Plug>(unimpaired-put-below-reformat)g$:set virtualedit= virtualedit=all<CR>")
end

return M
