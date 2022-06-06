Put linewise
```lua
-- Put linewise below
map({"n","x"}, "glp", require("booster").putLinewise("]p`]"))
-- Put linewise above
map({"n","x"}, "glP", require("booster").putLinewise("]P`]"))
```

Put charwise
```lua
-- Put charwise after
map({"n", "x"}, "p", require("booster").putCharwise("p"))
-- Put charwise after + prefix
map({"n", "x"}, "gp", require("booster").putCharwise("p", true))
-- Put charwise after + prefix and suffix 
map({"n", "x"}, "gsp", require("booster").putCharwise("p", true, true))
-- Put charwise before
map({"n", "x"}, "P", require("booster").putCharwise("P"))
-- Put charwise before + suffix
map({"n", "x"}, "gP", require("booster").putCharwise("P", nil, true))
-- Put charwise before + prefix and suffix
map({"n", "x"}, "gsP", require("booster").putCharwise("P", true, true))
```
