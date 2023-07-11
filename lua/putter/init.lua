local v = vim.v
local o = vim.o
local fn = vim.fn
local cmd = vim.cmd
local tbl_deep_extend = vim.tbl_deep_extend
-- vim.pretty_print(buffers)

-------------------- Put
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

local function putLinewise(command)
  local register = getRegister(command)
  local str = register.contents

  fn.setreg(register.name, str, "V")                                    -- Set register linewise
  fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command) -- Put register
  fn.setreg(register.name, register.contents, register.type)            -- Restore register
end

local function putCharwise(command)
  local register = getRegister(command)
  local str

  -- If register type is blockwise-visual then put as usual
  if register.type ~= "V" and register.type ~= "v" then
    fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command)
    return
  end

  -- If register type is linewise then remove spaces at both extremities
  if register.type == "V" then
    str = register.contents:gsub("^%s*(.-)%s*$", "%1")
  else
    str = register.contents
  end

  fn.setreg(register.name, str, "v")                                    -- Set register charwise
  fn.execute("normal! " .. v.count1 .. '"' .. register.name .. command) -- Put register
  fn.setreg(register.name, register.contents, register.type)            -- Restore register
end

function M.putCharwise(command)
  return function() putCharwise(command) end
end

function M.putLinewise(command)
  return function() putLinewise(command) end
end

-------------------- Snap

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

-------------------- Jump

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

return M
