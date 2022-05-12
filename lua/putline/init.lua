local v = vim.v
local f = vim.fn
-- local map = vim.keymap.set

local M = {}

local function put(keys)
	local count = v.count
	local name = v.register
	local contents = f.getreg(name)
	local type = f.getregtype(name)
	local linewise = "V"

	-- print('normal! ' .. count .. '"' .. name .. keys .. '`]')

	if type == linewise then
		f.execute("normal! " .. count .. '"' .. name .. keys .. "`]")
	else
		f.setreg(name, contents, linewise)
		f.execute("normal! " .. count .. '"' .. name .. keys .. "`]")
	end
end

M.above = function()
	put("]P")
end
M.below = function()
	put("]p")
end
M.setup = function(opts) end

-- map("n", "S", function() require('putline').below() end)

return M
