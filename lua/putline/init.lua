local v = vim.v
local f = vim.fn
local c = vim.cmd
-- local map = vim.keymap.set
-- vim.pretty_print(buffers)

local M = {}

local function putLinewise(keys)
	local register = {}
	register.name = v.register
	register.contents = f.getreg(register.name)
	register.type = f.getregtype(register.name)
	local linewise = "V"
	local motion = "`]"
	local count = v.count1

	if register.type ~= linewise then
		f.setreg(register.name, register.contents, linewise)
	end
	f.execute("normal! " .. count .. '"' .. register.name .. keys .. motion)
end

local function putCharwise(keys)
	local register = {}
	register.name = v.register
	register.contents = f.getreg(register.name)
	register.type = f.getregtype(register.name)
	local linewise = "V"
	local charwise = "v"
	local count = v.count1

	if register.type == linewise then
		-- Remove spaces at both extremities
		local str = string.gsub(register.contents, "^%s*(.-)%s*$", "%1")
		f.setreg(register.name, str, charwise)
	end
	f.execute("normal! " .. count .. '"' .. register.name .. keys)
end

M.buffersToQfWindow = function()
	local lastBuffer = f.bufnr("$")
	local items = {}

	for i = 1, lastBuffer do
		if f.buflisted(i) == 1 then
			table.insert(items, { bufnr = i })
		end
	end
	f.setqflist(items)
end

M.nextQfItem = function()
  if not pcall(c, "cnext") then
    pcall(c, "cfirst")
  end
end

M.prevQfItem = function()
  if not pcall(c, "cprev") then
    pcall(c, "clast")
  end
end

M.putCharwiseAfter = function()
	putCharwise("p")
end
M.putCharwiseBefore = function()
	putCharwise("P")
end
M.putLinewiseAbove = function()
	putLinewise("]P")
end
M.putLinewiseBelow = function()
	putLinewise("]p")
end
M.setup = function(opts) end

return M
