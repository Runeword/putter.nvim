Put linewise
```lua
-- Put linewise below
vim.keymap.set({"n","x"}, "glp", require("booster").putLinewise("]p`]"))
-- Put linewise above
vim.keymap.set({"n","x"}, "glP", require("booster").putLinewise("]P`]"))
```

Put charwise
```lua
-- Put charwise after
vim.keymap.set({"n", "x"}, "p", require("booster").putCharwise("p"))
-- Put charwise after + prefix
vim.keymap.set({"n", "x"}, "gp", require("booster").putCharwise("p", true))
-- Put charwise after + surround
vim.keymap.set({"n", "x"}, "gsp", require("booster").putCharwise("p", true, true))
-- Put charwise before
vim.keymap.set({"n", "x"}, "P", require("booster").putCharwise("P"))
-- Put charwise before + suffix
vim.keymap.set({"n", "x"}, "gP", require("booster").putCharwise("P", nil, true))
-- Put charwise before + surround
vim.keymap.set({"n", "x"}, "gsP", require("booster").putCharwise("P", true, true))
```
