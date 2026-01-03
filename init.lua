-- ~/.config/nvim/init.lua

------------------------------------------------------------
-- 1) Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.g.python3_host_prog = "/opt/homebrew/Caskroom/miniforge/base/bin/python"
------------------------------------------------------------
-- 2) Leaders (must be BEFORE plugins)
------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = ","

------------------------------------------------------------
-- 3) Plugins (plugins.lua returns a table)
------------------------------------------------------------
require("lazy").setup(require("plugins"))

------------------------------------------------------------
-- 4) Keymaps
------------------------------------------------------------
require("keymaps")
require("options")

