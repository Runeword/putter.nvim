local v = vim.v
local fn = vim.fn
local cmd = vim.cmd
-- local map = vim.keymap.set
-- vim.pretty_print(buffers)

local M = {}

-- M.setup = function(opts) end

local function getRegister(command)
  local register = {}
  register.name = command:match('^"(.)') or v.register
  register.contents = fn.getreg(register.name)
  register.type = fn.getregtype(register.name)
  return register
end

local surround = {
  [')'] = { '(', ')' },
  ['('] = { '(', ')' },
  [']'] = { '[', ']' },
  ['['] = { '[', ']' },
  ['}'] = { '{', '}' },
  ['{'] = { '{', '}' },
  ['>'] = { '<', '>' },
  ['<'] = { '<', '>' },
  [','] = { ', ', ',' }
}

local prefix = {
  [','] = ', '
}

local suffix = {
  [','] = ', '
}

local opts = {
  ['putLinewiseSurround'] = { chars = surround },
  ['putCharwiseSurround'] = { chars = surround },
  ['putLinewisePrefix'] = { chars = prefix },
  ['putCharwisePrefix'] = { chars = prefix },
  ['putLinewiseSuffix'] = { chars = suffix },
  ['putCharwiseSuffix'] = { chars = suffix },
}

local function getPrefixSuffix(optKey)
  local key = fn.getcharstr() -- Prompt for user input
  local exitKeys = { [''] = true }
  if exitKeys[key] then error() end
  return unpack(opts[optKey].chars[key] or { key, key })
end

local function getLines(str, prefix, suffix)
  local lines = ''

  for line in str:gmatch("[^\r\n]+") do
    local spacesStart, chars, spacesEnd = line:match("^(%s*)(.-)(%s*)$")
    lines = lines .. spacesStart .. (prefix or '') .. chars .. (suffix or '') .. spacesEnd .. '\n'
  end
  return lines
end

local function putLinewise(command, callback)
  local register = getRegister(command)
  local str = register.contents

  if callback then
    -- Add prefix and suffix
    local status
    status, str = pcall(callback, str)
    if not status then print('str', str) end
  end

  fn.setreg(register.name, str, "V") -- Set register linewise
  fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command) -- Paste register
  fn.setreg(register.name, register.contents, register.type) -- Restore register
end

local function putCharwise(command, callback)
  local register = getRegister(command)
  local linewise = "V"
  local str = ''

  -- Remove spaces at both extremities
  if register.type == linewise then str = register.contents:gsub("^%s*(.-)%s*$", "%1")
  else str = register.contents
  end

  if callback then
    -- Add prefix and suffix
    local status
    status, str = pcall(callback, str)
    if not status then return end
  end

  fn.setreg(register.name, str, "v") -- Set register charwise
  fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command) -- Paste register
  fn.setreg(register.name, register.contents, register.type) -- Restore register
end

M.putCharwise = function(command)
  return function() putCharwise(command) end
end

M.putCharwisePrefix = function(command)
  return function()
    putCharwise(command, function(str)
      return getPrefixSuffix('putCharwisePrefix') .. str
    end)
  end
end

M.putCharwiseSuffix = function(command)
  return function()
    putCharwise(command, function(str)
      return str .. getPrefixSuffix('putCharwiseSuffix')
    end)
  end
end

M.putCharwiseSurround = function(command)
  return function()
    putCharwise(command, function(str)
      local prefix, suffix = getPrefixSuffix('putCharwiseSurround')
      return (prefix or '') .. str .. (suffix or '')
    end)
  end
end

M.putLinewise = function(command)
  return function() putLinewise(command) end
end

M.putLinewisePrefix = function(command)
  return function()
    putLinewise(command, function(str)
      local prefix = getPrefixSuffix('putLinewisePrefix')
      return getLines(str, prefix)
    end)
  end
end

M.putLinewiseSuffix = function(command)
  return function()
    putLinewise(command, function(str)
      local suffix = getPrefixSuffix('putLinewiseSuffix')
      return getLines(str, nil, suffix)
    end)
  end
end

M.putLinewiseSurround = function(command)
  return function()
    putLinewise(command, function(str)
      return getLines(str, getPrefixSuffix('putLinewiseSurround'))
    end)
  end
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
    if fn.getwinvar(i, "&syntax") == "qf" then break
    elseif i == lastWindow then cmd("silent copen") end
  end

  if timer then timer:close() end

  if not pcall(cmd, a) then pcall(cmd, b) end

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

return M
