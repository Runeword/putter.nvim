local v = vim.v
local o = vim.o
local fn = vim.fn
local cmd = vim.cmd
local tbl_deep_extend = vim.tbl_deep_extend
-- vim.pretty_print(buffers)

local M = {}

local opts = require("putter.opts")

M.setup = function(userOpts)
  opts = tbl_deep_extend("force", opts, userOpts or {})
end

local function getRegister(command)
  local register = {}
  register.name = command:match('^"(.)') or v.register
  register.contents = fn.getreg(register.name)
  register.type = fn.getregtype(register.name)
  return register
end

local function getInputKey()
  local inputKey = fn.getcharstr() -- Prompt for user input

  local exitKeys = { [''] = true }
  if exitKeys[inputKey] then error() end
  return inputKey
end

local function getPrefixSuffix(optsKey, inputKey)
  local chars = opts[optsKey].chars[inputKey]

  if type(chars) == 'string' then return chars
  elseif type(chars) == 'table' then return unpack(chars)
  else return inputKey, inputKey end
end

local function appendPrefixSuffix(chars, prefix, suffix)
    return (prefix or '') .. chars .. (suffix or '')
end

local function formatLines(str, callback)
  if not callback then return str end

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

  -- Invoke the callback function to format the register contents
  if callback then
    -- formatLines(str, function(line) return appendPrefixSuffix(line, prefix, nil) end)
    local status
    status, str = pcall(callback, str)
    -- print('status', status, str)
    if not status then return end
  end

  fn.setreg(register.name, str, "V") -- Set register linewise
  fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command) -- Put register
  fn.setreg(register.name, register.contents, register.type) -- Restore register
end

local function putCharwise(command, callback)
  local register = getRegister(command)
  local str

  -- If register type is blockwise-visual then put as usual
  if register.type ~= "V" and register.type ~= "v" then
    fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command)
    return
  end

  -- If register type is linewise then remove spaces at both extremities
  if register.type == "V" then str = register.contents:gsub("^%s*(.-)%s*$", "%1")
  else str = register.contents
  end

  -- Invoke the callback function to format the register contents
  if callback then
    local status
    status, str = pcall(callback, str)
    if not status then return end
  end

  fn.setreg(register.name, str, "v") -- Set register charwise
  fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command) -- Put register
  fn.setreg(register.name, register.contents, register.type) -- Restore register
end

local function formatCharsPrefix(str)
  local prefix = getPrefixSuffix('putCharwisePrefix', getInputKey())
  return appendPrefixSuffix(str, prefix)
end

local function formatCharsSuffix(str)
  local _, suffix = getPrefixSuffix('putCharwiseSuffix', getInputKey())
  return appendPrefixSuffix(str, nil, suffix)
end

local function formatCharsSurround(str)
  local prefix, suffix = getPrefixSuffix('putCharwiseSurround', getInputKey())
  return appendPrefixSuffix(str, prefix, suffix)
end

local function formatLinesPrefix(str)
  local prefix = getPrefixSuffix('putLinewisePrefix', getInputKey())
  return formatLines(str, function(line) return appendPrefixSuffix(line, prefix, nil) end)
end

local function formatLinesSuffix(str)
  local _, suffix = getPrefixSuffix('putLinewiseSuffix', getInputKey())
  return formatLines(str, function(line) return appendPrefixSuffix(line, nil, suffix) end)
end

local function formatLinesSurround(str)
  local prefix, suffix = getPrefixSuffix('putLinewiseSurround', getInputKey())
  return formatLines(str, function(line) return appendPrefixSuffix(line, prefix, suffix) end)
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
  return function() putLinewise(command, function(str) return formatLines(str, callback) end) end
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

local function cycleQfItem(a, b, open, close)
  local lastWindow = fn.winnr("$")

  for i = 1, lastWindow do
    if fn.getwinvar(i, "&syntax") == "qf" then break
    elseif i == lastWindow then cmd("silent " .. open) end
  end

  if timer then timer:close() end

  if not pcall(cmd, a) then pcall(cmd, b) end

  timer = vim.defer_fn(function()
    cmd(close)
    timer = nil
  end, 10000)
end

local function isPastEndOfLine()
  return (o.virtualedit ~= '') and (fn.col('.') >= fn.col('$'))
end

local function isBeforeFirstNonBlank()
  return (o.virtualedit ~= '') and (fn.col(".") <= string.find(fn.getline(fn.line(".")), "(%S)") - 1)
end

function M.snapToLineStart(callback)
  return function()
    if isBeforeFirstNonBlank() then fn.execute('normal! ^') end
    if type(callback) == 'string' then fn.execute('normal! ' .. callback) else callback() end
  end
end

function M.snapToLineEnd(callback)
  return function()
    if isPastEndOfLine() then fn.execute('normal! $') end
    if type(callback) == 'string' then fn.execute('normal! ' .. callback) else callback() end
  end
end

local function jumpToLine(command, callback)
  if isPastEndOfLine() or isBeforeFirstNonBlank() then fn.execute('normal! ' .. command) end
  if type(callback) == 'string' then fn.execute('normal! ' .. callback) else callback() end
end

function M.jumpToLine(command, callback)
  return function() jumpToLine(command, callback) end
end

function M.jumpToLineStart(callback)
  return function() jumpToLine('^', callback) end
end

function M.jumpToLineEnd(callback)
  return function() jumpToLine('$', callback) end
end

function M.cycleNextLocItem()
  cycleQfItem("lnext", "lfirst", "lopen", "lclose")
end

function M.cyclePrevLocItem()
  cycleQfItem("lprev", "llast", "lopen", "lclose")
end

function M.cycleNextQfItem()
  cycleQfItem("cnext", "cfirst", "copen", "cclose")
end

function M.cyclePrevQfItem()
  cycleQfItem("cprev", "clast", "copen", "cclose")
end

return M
