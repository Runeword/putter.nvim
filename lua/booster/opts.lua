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

return  {
  ['putLinewiseSurround'] = { chars = surround },
  ['putCharwiseSurround'] = { chars = surround },
  ['putLinewisePrefix'] = { chars = prefix },
  ['putCharwisePrefix'] = { chars = prefix },
  ['putLinewiseSuffix'] = { chars = suffix },
  ['putCharwiseSuffix'] = { chars = suffix },
}
