local v = vim.v
local f = vim.fn
-- local map = vim.keymap.set

local M = {}

local function putLinewise(keys)
	local count = v.count1
	local name = v.register
	local contents = f.getreg(name)
	local type = f.getregtype(name)
	local linewise = "V"
	local motion = "`]"

	if type ~= linewise then
		f.setreg(name, contents, linewise)
  end
		f.execute("normal! " .. count .. '"' .. name .. keys .. motion)
end

local function putCharwise(keys)
	local count = v.count1
	local name = v.register
	local contents = f.getreg(name)
	local type = f.getregtype(name)
	local linewise = "V"
	local charwise = "v"

	if type == linewise then
		-- Remove spaces at both extremities
		local str = string.gsub(contents, "^%s*(.-)%s*$", "%1")
		f.setreg(name, str, charwise)
	end
  f.execute("normal! " .. count .. '"' .. name .. keys)
end

M.charwiseAfter = function()
  putCharwise("p")
end
M.charwiseBefore = function()
  putCharwise("P")
end
M.above = function()
	putLinewise("]P")
end
M.below = function()
	putLinewise("]p")
end
M.setup = function(opts) end

-- map("n", "S", function() require('putline').below() end)

return M
