# putter.nvim
Install the plugin with [packer](https://github.com/wbthomason/packer.nvim)
```lua
use("Runeword/putter.nvim")
```
### Put charwise, linewise

Functions that take as first argument any normal command that contains `p` such as

`]p` to put under the current indentation level  
``p`]`` to put and move cursor to end of the text  
`"+p` to put contents of the clipboard register

```lua
vim.keymap.set({'n', 'x'}, 'p', require('putter').putCharwise('p'))
vim.keymap.set({'n', 'x'}, 'P', require('putter').putCharwise('P'))
vim.keymap.set({'n','x'}, 'glp', require('putter').putLinewise(']p`]'))
vim.keymap.set({'n','x'}, 'glP', require('putter').putLinewise(']P`]'))
```
