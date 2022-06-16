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

local function getPrefixSuffix(char, addPrefix, addSuffix)
  local prefix, suffix = '', ''

  if addPrefix and addSuffix then prefix, suffix = getMatchingChars(char)
  elseif addPrefix then prefix = char
  elseif addSuffix then suffix = char
  end

  return prefix, suffix
end

M.putLinewise = function(command, addPrefix, addSuffix)
  return function()
    local register = getRegister(command)
    local linewise = "V"
    local count = v.count1
    local str = register.contents

    -- if register.type ~= linewise then
    -- print('register.contents', register.contents)
    -- print('register.type', register.type)
    -- print('register.name', register.name)
    -- print('register', v.register)

    if addPrefix or addSuffix then
      -- Prompt for user input
      local status, inputChar = pcall(fn.getcharstr)
      local exitKeys = { [''] = true }
      if not status or exitKeys[inputChar] then return status end

      -- Add prefix and suffix
      local prefix, suffix = getPrefixSuffix(inputChar, addPrefix, addSuffix)
      if prefix == ',' then prefix = ', ' end

      local lines = ''

      for line in str:gmatch("[^\r\n]+") do
        local spacesStart, chars, spacesEnd = line:match("^(%s*)(.-)(%s*)$")
        lines = lines .. spacesStart .. prefix .. chars .. suffix .. spacesEnd .. '\n'
      end

      str = lines
    end


    fn.setreg(register.name, str, linewise)
    fn.execute("normal! " .. count .. '"' .. register.name .. command)
    fn.setreg(register.name, register.contents, register.type)
  end
end

M.putCharwise = function(command, addPrefix, addSuffix)
  return function()
    local register = getRegister(command)
    local linewise = "V"
    local charwise = "v"
    local count = v.count1
    local str = ''

    -- Remove spaces at both extremities
    if register.type == linewise then str = register.contents:gsub("^%s*(.-)%s*$", "%1")
    else str = register.contents
    end

    -- print('register.name', register.name)
    -- print('register.type', register.type)
    -- print('register.content', register.contents)

    if addPrefix or addSuffix then
      -- Prompt for user input
      local status, inputChar = pcall(fn.getcharstr)
      local exitKeys = { [''] = true }
      if not status or exitKeys[inputChar] then return status end

      -- Add prefix and suffix
      local prefix, suffix = getPrefixSuffix(inputChar, addPrefix, addSuffix)
      if prefix == ',' then prefix = ', ' end
      if suffix == ',' then suffix = ', ' end
      str = (prefix or '') .. str .. (suffix or '')
    end

    -- Set register, put, reset register
    fn.setreg(register.name, str, charwise)
    fn.execute("normal! " .. count .. '"' .. register.name .. command)
    fn.setreg(register.name, register.contents, register.type)
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
