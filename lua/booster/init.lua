local v = vim.v
local fn = vim.fn
local cmd = vim.cmd
-- local map = vim.keymap.set
-- vim.pretty_print(buffers)

local M = {}

M.putLinewise = function(command, surround)
  local register = {}
  register.name = v.register
  register.contents = fn.getreg(register.name)
  register.type = fn.getregtype(register.name)
  local linewise = "V"
  local count = v.count1
  local str = ''
  local prefix
  local suffix

  if (surround) then
    local input = fn.getcharstr()
    prefix = input
    suffix = input
  end

  -- if register.type ~= linewise then

  -- Add prefix and suffix
  str = (prefix or '') .. register.contents .. (suffix or '')

  fn.setreg(register.name, str, linewise)
  fn.execute("normal! " .. count .. '"' .. register.name .. command)
  fn.setreg(register.name, register.contents, register.type)
end

M.putCharwise = function(command, surround)
  local linewise = "V"
  local charwise = "v"
  local count = v.count1
  local register = {}
  local str = ''
  local prefix
  local suffix

  -- fn.inputsave()
  -- local input = fn.input('> ')
  -- prefix = input
  -- suffix = input
  -- fn.inputrestore()

  if (surround) then
    local input = fn.getcharstr()
    prefix = input
    suffix = input
  end

  register.name = v.register
  register.type = fn.getregtype(register.name)
  register.contents = fn.getreg(register.name)

  if register.type == linewise then
    -- Remove spaces at both extremities
    str = string.gsub(register.contents, "^%s*(.-)%s*$", "%1")
  else
    str = register.contents
  end

  -- Add prefix and suffix
  str = (prefix or '') .. str .. (suffix or '')

  fn.setreg(register.name, str, charwise)
  fn.execute("normal! " .. count .. '"' .. register.name .. command)
  fn.setreg(register.name, register.contents, register.type)
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

  if not pcall(cmd, a) then
    pcall(cmd, b)
  end

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

M.setup = function(opts) end

return M
