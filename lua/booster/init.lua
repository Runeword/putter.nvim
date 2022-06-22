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

local function getPrefixSuffix(optsKey)
  local key = fn.getcharstr() -- Prompt for user input

  local exitKeys = { [''] = true }
  if exitKeys[key] then error() end

  local chars = opts[optsKey].chars[key]

  if type(chars) == 'string' then return chars
  elseif type(chars) == 'table' then return unpack(chars)
  else return key, key end
end

local function appendPrefixSuffix(prefix, suffix)
  return function(chars)
    return (prefix or '') .. chars .. (suffix or '')
  end
end

local function formatLines(str, callback)
  local lines = ''

  for line in str:gmatch("[^\r\n]+") do
    local spacesStart, chars, spacesEnd = line:match("^(%s*)(.-)(%s*)$")
    lines = lines .. spacesStart .. callback(chars) .. spacesEnd .. '\n'
  end
  return lines
end

local function putLinewise(command, callback)
  local register = getRegister(command)
  local str = register.contents

  if callback then
    local status
    status, str = pcall(callback, str)
    if not status then print(str) end
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
    local status
    status, str = pcall(callback, str)
    if not status then print(str) end
  end

  fn.setreg(register.name, str, "v") -- Set register charwise
  fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command) -- Paste register
  fn.setreg(register.name, register.contents, register.type) -- Restore register
end

local function formatCharsPrefix(str)
  return getPrefixSuffix('putCharwisePrefix') .. str
end

local function formatCharsSuffix(str)
  return str .. getPrefixSuffix('putCharwiseSuffix')
end

local function formatCharsSurround(str)
  local prefix, suffix = getPrefixSuffix('putCharwiseSurround')
  return (prefix or '') .. str .. (suffix or '')
end

local function formatLinesPrefix(str)
  return formatLines(str, appendPrefixSuffix(getPrefixSuffix('putLinewisePrefix')))
end

local function formatLinesSuffix(str)
  return formatLines(str, appendPrefixSuffix(nil, getPrefixSuffix('putLinewiseSuffix')))
end

local function formatLinesSurround(str)
  return formatLines(str, appendPrefixSuffix(getPrefixSuffix('putLinewiseSurround')))
end

function M.putCharwise(command, callback)
  return function() putCharwise(command, callback) end
end

function M.putCharwisePrefix(command)
  return function() putCharwise(command, formatCharsPrefix) end
end

function M.putCharwiseSuffix(command)
  return function() putCharwise(command, formatCharsSuffix) end
end

function M.putCharwiseSurround(command)
  return function() putCharwise(command, formatCharsSurround) end
end

function M.putLinewise(command, callback)
  return function() putLinewise(command, callback) end
end

function M.putLinewisePrefix(command)
  return function() putLinewise(command, formatLinesPrefix) end
end

function M.putLinewiseSuffix(command)
  return function() putLinewise(command, formatLinesSuffix) end
end

function M.putLinewiseSurround(command)
  return function() putLinewise(command, formatLinesSurround) end
end

function M.addBuffersToQfList()
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

function M.cycleNextQfItem()
  cycleQfItem("cnext", "cfirst")
end

function M.cyclePrevQfItem()
  cycleQfItem("cprev", "clast")
end

return M
