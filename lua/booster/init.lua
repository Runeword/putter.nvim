local v = vim.v
local fn = vim.fn
local cmd = vim.cmd
-- local map = vim.keymap.set
-- vim.pretty_print(buffers)

local M = {}

local function getRegister(command)
  local register = {}
  register.name = command:match('^"(.)') or v.register
  register.contents = fn.getreg(register.name)
  register.type = fn.getregtype(register.name)
  return register
end

local function getMatchingChars(char)
  local openingChar = { ['('] = ')', ['['] = ']', ['{'] = '}', ['<'] = '>' }
  local closingChar = { [')'] = '(', [']'] = '[', ['}'] = '{', ['>'] = '<' }

  if openingChar[char] then return char, openingChar[char]
  elseif closingChar[char] then return closingChar[char], char
  else return char, char
  end
end

local function getLines(str, prefix, suffix)
  local lines = ''

  for line in str:gmatch("[^\r\n]+") do
    local spacesStart, chars, spacesEnd = line:match("^(%s*)(.-)(%s*)$")
    lines = lines .. spacesStart .. (prefix or '') .. chars .. (suffix or '') .. spacesEnd .. '\n'
  end
  return lines
end

local function getPrefixSuffix(char, addPrefix, addSuffix)
  local prefix, suffix = '', ''

  if addPrefix and addSuffix then prefix, suffix = getMatchingChars(char)
  elseif addPrefix then prefix = char
  elseif addSuffix then suffix = char
  end

  return prefix, suffix
end

local function pl(command, callback)
    local register = getRegister(command)
    local str = register.contents

    if callback then
      -- Prompt for user input
      local status, key = pcall(fn.getcharstr)
      local exitKeys = { [''] = true }
      if not status or exitKeys[key] then return status end

      str = callback(str, key)
    end

    fn.setreg(register.name, str, "V") -- Set register linewise
    fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command) -- Paste register
    fn.setreg(register.name, register.contents, register.type) -- Restore register
end

local function addPrefix(str, key) return getLines(str, key) end
local function addSuffix(str, key) return getLines(str, nil, key) end
local function addSurround(str, key) return getLines(str, getMatchingChars(key)) end

M.putLinewise = function(command)
  return function() pl(command) end
end

M.putLinewisePrefix = function(command)
  return function() pl(command, addPrefix) end
end

M.putLinewiseSuffix = function(command)
  return function() pl(command, addSuffix) end
end

M.putLinewiseSurround = function(command)
  return function() pl(command, addSurround) end
end

-- M.putLinewise = function(command, addPrefix, addSuffix)
--   return function()
--     local register = getRegister(command)
--     local str = register.contents
--
--     if addPrefix or addSuffix then
--       -- Prompt for user input
--       local status, key = pcall(fn.getcharstr)
--       local exitKeys = { [''] = true }
--       if not status or exitKeys[key] then return status end
--
--       -- Add prefix and suffix
--       local prefix, suffix = getPrefixSuffix(key, addPrefix, addSuffix)
--       if prefix == ',' then prefix = ', ' end
--       str = getLines(str, prefix, suffix)
--     end
--
--     fn.setreg(register.name, str, "V") -- Set register linewise
--     fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command) -- Paste register
--     fn.setreg(register.name, register.contents, register.type) -- Restore register
--   end
-- end

M.putCharwise = function(command, addPrefix, addSuffix)
  return function()
    local register = getRegister(command)
    local linewise = "V"
    local str = ''

    -- Remove spaces at both extremities
    if register.type == linewise then str = register.contents:gsub("^%s*(.-)%s*$", "%1")
    else str = register.contents
    end

    if addPrefix or addSuffix then
      -- Prompt for user input
      local status, key = pcall(fn.getcharstr)
      local exitKeys = { [''] = true }
      if not status or exitKeys[key] then return status end

      -- Add prefix and suffix
      local prefix, suffix = getPrefixSuffix(key, addPrefix, addSuffix)
      if prefix == ',' then prefix = ', ' end
      if suffix == ',' then suffix = ', ' end
      str = (prefix or '') .. str .. (suffix or '')
    end

    fn.setreg(register.name, str, "v") -- Set register charwise
    fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command) -- Paste register
    fn.setreg(register.name, register.contents, register.type) -- Restore register
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

M.setup = function(opts) end

return M
