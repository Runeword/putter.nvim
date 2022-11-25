# putter.nvim
## Installation

Install the plugin with [packer](https://github.com/wbthomason/packer.nvim)
```lua
use("Runeword/booster.nvim")
```
### Put charwise, linewise

Functions that take as first argument any normal command that contains `p` such as

`]p` to put under the current indentation level  
``p`]`` to put and move cursor to end of the text  
`"+p` to put contents of the clipboard register

```lua
vim.keymap.set({'n', 'x'}, 'p', require('booster').putCharwise('p'))
vim.keymap.set({'n', 'x'}, 'P', require('booster').putCharwise('P'))
vim.keymap.set({'n','x'}, 'glp', require('booster').putLinewise(']p`]'))
vim.keymap.set({'n','x'}, 'glP', require('booster').putLinewise(']P`]'))
```

Accept a callback as second argument to format the register contents in a personalized way
```lua
vim.keymap.set({ 'n', 'x' }, 'gp', require('booster').putCharwise('p', function(chars)
  return 'format' .. chars .. 'as you like'
end))
vim.keymap.set({ 'n', 'x' }, 'glp', require('booster').putLinewise('p', function(line)
  return 'format' .. line .. 'as you like'
end))
```

### Put with prefix, suffix, or surround

Like `putCharwise()` or `putLinewise()` + ask you for a key that determines which prefix, suffix, or surround is added to the putted text
```lua
vim.keymap.set({'n','x'}, 'gllp', require('booster').putLinewiseSuffix(']p`]'))
vim.keymap.set({'n','x'}, 'gllP', require('booster').putLinewiseSuffix(']P`]'))
vim.keymap.set({'n','x'}, 'glLp', require('booster').putLinewisePrefix(']p`]'))
vim.keymap.set({'n','x'}, 'glLP', require('booster').putLinewisePrefix(']P`]'))
vim.keymap.set({'n','x'}, 'glsp', require('booster').putLinewiseSurround(']p`]'))
vim.keymap.set({'n','x'}, 'glsP', require('booster').putLinewiseSurround(']P`]'))
vim.keymap.set({'n', 'x'}, 'gp', require('booster').putCharwisePrefix('p'))
vim.keymap.set({'n', 'x'}, 'gP', require('booster').putCharwiseSuffix('P'))
vim.keymap.set({'n', 'x'}, 'gsp', require('booster').putCharwiseSurround('p'))
vim.keymap.set({'n', 'x'}, 'gsP', require('booster').putCharwiseSurround('P'))
```
Each function has its own table where entries consists of characters associated with a key  
If there's no value associated with the key you pressed, then the key is used as a character instead  

You can extend or overwrite the [default config](https://github.com/Runeword/booster.nvim/blob/main/lua/booster/opts.lua)  

```lua
require("booster").setup({
  putLinewiseSurround = {
    chars = {
      ['('] = { 'prefix chars', 'suffix chars' },
      ['q'] = { '\' ', ' \'' }
    }
  },
  putCharwisePrefix = {
    chars = {
      ['.'] = 'prefix chars'
    }
  },
  putLinewiseSuffix = {
    chars = {
      [','] = nil
    }
  }
})
```
