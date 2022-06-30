### Put linewise
```lua
vim.keymap.set({"n","x"}, "glp", require("booster").putLinewise(']p`]'))
vim.keymap.set({"n","x"}, "glP", require("booster").putLinewise(']P`]'))
vim.keymap.set({"n","x"}, "gllp", require("booster").putLinewiseSuffix(']p`]'))
vim.keymap.set({"n","x"}, "gllP", require("booster").putLinewiseSuffix(']P`]'))
vim.keymap.set({"n","x"}, "glLp", require("booster").putLinewisePrefix(']p`]'))
vim.keymap.set({"n","x"}, "glLP", require("booster").putLinewisePrefix(']P`]'))
vim.keymap.set({"n","x"}, "glsp", require("booster").putLinewiseSurround(']p`]'))
vim.keymap.set({"n","x"}, "glsP", require("booster").putLinewiseSurround(']P`]'))
```
### Put charwise
```lua
vim.keymap.set({"n", "x"}, "p", require("booster").putCharwise("p"))
vim.keymap.set({"n", "x"}, "P", require("booster").putCharwise("P"))
vim.keymap.set({"n", "x"}, "gp", require("booster").putCharwisePrefix("p"))
vim.keymap.set({"n", "x"}, "gP", require("booster").putCharwiseSuffix("P"))
vim.keymap.set({"n", "x"}, "gsp", require("booster").putCharwiseSurround("p"))
vim.keymap.set({"n", "x"}, "gsP", require("booster").putCharwiseSurround("P"))
```
First argument is any normal command that contains `p` such as
`]p` to put under the current indentation level
``p`]`` to put and move cursor to end of the text
`"+p` to put contents of the clipboard register
