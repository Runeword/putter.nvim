local v = vim.v
local fn = vim.fn
local cmd = vim.cmd
-- local map = vim.keymap.set
-- vim.pretty_print(buffers)

local M = {}

local function putLinewise(keys)
  local register = {}
  register.name = v.register
  register.contents = fn.getreg(register.name)
  register.type = fn.getregtype(register.name)
  local linewise = "V"
  local motion = "`]"
  local count = v.count1

  if register.type ~= linewise then
    fn.setreg(register.name, register.contents, linewise)
  end
  fn.execute("normal! " .. count .. '"' .. register.name .. keys .. motion)
end

local function putCharwise(keys)
  local register = {}
  register.name = v.register
  register.contents = fn.getreg(register.name)
  register.type = fn.getregtype(register.name)
  local linewise = "V"
  local charwise = "v"
  local count = v.count1

  if register.type == linewise then
    -- Remove spaces at both extremities
    local str = string.gsub(register.contents, "^%s*(.-)%s*$", "%1")
    fn.setreg(register.name, str, charwise)
  end
  fn.execute("normal! " .. count .. '"' .. register.name .. keys)
end

M.addBuffersToQfList = function()
  local lastBuffer = fn.bufnr("$")
  local items = {}

  for i = 1, lastBuffer do
    if fn.buflisted(i) == 1 then
      table.insert(items, { bufnr = i })
    end
  end
  fn.setqflist(items)
end

local timer

local function cycleQfItem(a, b)
  local lastWindow = fn.winnr("$")

  for i = 1, lastWindow do
    if fn.getwinvar(i, "&syntax") == "qf" then
      break
    elseif i == lastWindow then
      cmd("silent copen")
    end
  end

  if timer then
    timer:close()
  end
  --
  if not pcall(cmd, a) then
    pcall(cmd, b)
  end
  --
  timer = vim.defer_fn(function()
    cmd("cclose")
    timer = nil
  end, 1000)
end

M.cycleNextQfItem = function()
  cycleQfItem("cnext", "cfirst")
end
M.cyclePrevQfItem = function()
  cycleQfItem("cprev", "clast")
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
