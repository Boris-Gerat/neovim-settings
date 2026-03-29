local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

------------------------------------------------------------
-- ASCII art section
------------------------------------------------------------
local alpha = require("alpha")

------------------------------------------------------------
-- ASCII art (TOP)
------------------------------------------------------------
local ascii = {
  type = "text",
  val = {
"        .                                    .       . .                       .",
"    .   .                                ::+==*#*+#+%@**#%%%**==*=.",
"                  .  .     .   #*: *%=.+%@##%@%##=#+%#%#%-.:%.=-==-%%@*:.",
"  .                           =@==%*@@@*:+++#%%@%@@%%@@@%##*+:@#*===-  .               .",
" .                         .-+=:+*=*=@#*-=%+*@#@@#@#%=#@%**=%@%*+%@%*.  .          ..",
"                .   +%*+%#++*@@@%@#=+@#=*%@#+%%%*@%#@.  *##+**%*#+*=+#=%##=            .",
"               . :=%%%%#@%@@@@@@@%%%@%%@@%@#   %@@#=-*+ *@%##%#+:*@@**#*-=++...",
"        =#==+*.*#%%%#@%@%%@+=#@@@=%@*@%*+%+@@@%@%     -@*===#++#%%=#*@%%#+#%#++##%+-",
"       .:#**++*+#@@@%*%%+#@@@@*#%@*@#@@@#%.*@@#@%+*=.+@@@#%+#+%@@+#*#%%+*- *:-==. . @#.",
"         .    ::+=-+%*#@@%*+###*%#=    ##*=%%=*%    -+:-+:+%#+#@=#+%.#%%%%*#+*@%##%+-=....  .",
"      .           +***=  :#%%::##-  +    .*+@%-:-:- :%**++%#*%+*+=-#-#######=%@%@*@+=*#*#::-.",
"   .            .           .                 =%%%*@@@@:          ..#.+-*###*.#%#-@%#%%@*+**+=+",
"                .                               =%*=:@=-           ..     :::-*:=+-+=::..",
"                                       .+==#+#==...**:+                           .",
"            .             .       .:#=+=:..:*@@%##=+   .                  .",
"       .               .      .::=:-@@+--*@@#  .       .           .",
"                          -.::. .:+#=@@%%%#%+                                   .       .  .",
"   .                      -##+... ... .=%-. .=@@+:+       .               .           .",
"                            :-=@@@@@@@@@#%##+=%%#=%%*%@%@%=:.       .                        .",
"               .+:-++++=**%#*%@@@@#@@%@#*#@#%*%%@%%#+***#*#==%@#%-==--..          .",
"                ..........       .      . .....::.......                       .",
"                 .  ---:::.......",
"                        .  :-=+*%@@@@@@@@@@@@@@@@@@@%%@@@%%%%%%*:                  . .",
"  .                          .       .                  .  .         .",
  },
  opts = {
    position = "center",
    hl = "AlphaArt",
  },
}

------------------------------------------------------------
-- Header text
------------------------------------------------------------
local header = {
  type = "text",
  val = {
    "",
    "NVIM v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
  },
  opts = {
    position = "center",
    hl = "AlphaHeader",
  },
}

------------------------------------------------------------
-- Highlights
------------------------------------------------------------
vim.api.nvim_set_hl(0, "AlphaHeader", { link = "Normal" })
vim.api.nvim_set_hl(0, "AlphaArt", { fg = "#6c7086" })

------------------------------------------------------------
-- Layout (ASCII at TOP)
------------------------------------------------------------
alpha.setup({
  layout = {
    { type = "padding", val = 0 },
    ascii,
    { type = "padding", val = 1 },
    header,
  },
  opts = {
    margin = 2,
  },
})

------------------------------------------------------------
-- Classic nvim text section
------------------------------------------------------------
local header = {
  type = "text",
  val = {
    "",
    "                 NVIM v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch .. "                ",
    "",
    "   Nvim is open source and freely distributable",
    "         https://neovim.io/#chat             ",
    "",
    "   type  :help nvim<Enter>       if you are new!",
    "   type  :checkhealth<Enter>     to optimize Nvim",
    "   type  :q<Enter>               to exit",
    "   type  :help<Enter>            for help",
    "",
    "   type  :help news<Enter>  to see changes in v" .. vim.version().major .. "." .. vim.version().minor,
    "",
  },
  opts = {
    position = "center",
    hl = "AlphaHeader",
  },
}

------------------------------------------------------------
-- Highlights
------------------------------------------------------------
vim.api.nvim_set_hl(0, "AlphaHeader", { link = "Normal" })
vim.api.nvim_set_hl(0, "AlphaArt",    { link = "Comment" })  -- dimmer color for art

alpha.setup({
  layout = {
    { type = "padding", val = 10 },   -- 🔥 TOP spacing (adjust this)
    ascii,
    { type = "padding", val = 1 },
    header,
  },
  opts = {
    margin = 3,  -- 🔥 horizontal centering tweak
  },
})
