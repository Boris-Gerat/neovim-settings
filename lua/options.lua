-- ============================================================
-- LINE NUMBERS & NAVIGATION
-- ============================================================
vim.opt.number = true
vim.opt.relativenumber = true

vim.keymap.set({ "n", "v" }, "j", "gj", { silent = true })
vim.keymap.set({ "n", "v" }, "k", "gk", { silent = true })

-- ============================================================
-- RULER & HARD WRAPPING
-- ============================================================
vim.g.my_colorcolumn = 100
vim.opt.colorcolumn = tostring(vim.g.my_colorcolumn)
vim.opt.textwidth = vim.g.my_colorcolumn
vim.opt.formatoptions = "tcqnj"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

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

vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#44475a" })
vim.opt.scrolloff = 10

-- ============================================================
-- JUPYTER / MOLTEN
-- ============================================================

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.ipynb",
  callback = function()
    local py_file = vim.fn.expand("%:r") .. ".py"
    if vim.fn.filereadable(py_file) == 1 then
      vim.fn.delete(py_file)
    end
  end,
})

vim.o.conceallevel = 2

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "tex", "text" },
  callback = function()
    vim.opt_local.textwidth = 0
    vim.opt_local.formatoptions:remove("t")
    vim.opt_local.colorcolumn = tostring(vim.g.my_colorcolumn)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

-- ============================================================
-- TERMINAL: unlist + lock window
-- ============================================================

-- 1. Unlist terminal buffers so bnext/bprevious never visits them,
--    and mark their window as the R console (locked)
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.api.nvim_win_set_var(0, "_is_r_console", true)
  end,
})

-- 2. If a normal buffer somehow enters the R console window, kick it out
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then return end
    local win = vim.api.nvim_get_current_win()
    local ok, is_console = pcall(vim.api.nvim_win_get_var, win, "_is_r_console")
    if not (ok and is_console) then return end

    vim.schedule(function()
      if not vim.api.nvim_win_is_valid(win) then return end

      local r_buf = nil
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
          r_buf = buf
          break
        end
      end

      local target_win = nil
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        local ok2, is_c = pcall(vim.api.nvim_win_get_var, w, "_is_r_console")
        if not (ok2 and is_c) then
          target_win = w
          break
        end
      end

      if r_buf then
        vim.api.nvim_win_set_buf(win, r_buf)
      end
      if target_win then
        vim.api.nvim_set_current_win(target_win)
        vim.api.nvim_win_set_buf(target_win, ev.buf)
      end
    end)
  end,
})
