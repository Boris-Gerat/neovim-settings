-- ============================================================
-- LINE NUMBERS & NAVIGATION
-- ============================================================
vim.opt.number = true
vim.opt.relativenumber = true

-- Move by visual lines (makes navigating wrapped text feel like normal lines)
vim.keymap.set({ "n", "v" }, "j", "gj", { silent = true })
vim.keymap.set({ "n", "v" }, "k", "gk", { silent = true })

-- ============================================================
-- THE RULER & HARD WRAPPING
-- ============================================================
vim.g.my_colorcolumn = 100
vim.opt.colorcolumn = tostring(vim.g.my_colorcolumn)
vim.opt.textwidth = vim.g.my_colorcolumn -- THE MAGIC SETTING

-- t: auto-wrap text, c: comments, q: allow gq, n: lists, j: join lines
vim.opt.formatoptions = "tcqnj"

-- Soft wrap as a fallback (keeps things inside the window if it's narrow)
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- TOGGLE RULER & BREAKING
vim.keymap.set("n", "<leader>cc", function()
  if vim.opt.colorcolumn:get()[1] ~= "" then
    vim.opt.colorcolumn = ""
    vim.opt.textwidth = 0
    vim.notify("Auto-Break OFF", vim.log.levels.INFO)
  else
    vim.opt.colorcolumn = tostring(vim.g.my_colorcolumn)
    vim.opt.textwidth = vim.g.my_colorcolumn
    vim.notify("Auto-Break ON (" .. vim.g.my_colorcolumn .. " cols)", vim.log.levels.INFO)
  end
end, { desc = "Toggle Ruler/Wrap" })

-- COLOR SCHEME FIX
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#44475a" })
