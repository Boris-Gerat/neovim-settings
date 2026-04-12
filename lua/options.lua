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

-- MINIMUM LINES BELLOW 
vim.opt.scrolloff = 10

-- ============================================================
-- JUPYTER / MOLTEN
-- ...existing BufEnter autocmd...
-- ============================================================

-- Clean up the .py file that jupytext creates on disk
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

-- Fix to markdown hard breaks
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "tex", "text" },
  callback = function()
    vim.opt_local.textwidth = 0
    vim.opt_local.formatoptions:remove("t")
    vim.opt_local.colorcolumn = tostring(vim.g.my_colorcolumn)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true      -- break at word boundaries, not mid-word
    vim.opt_local.breakindent = true
  end,
})

-- Persistent bottom terminal
local term_buf = nil
local term_win = nil

local function open_term()
  -- reuse existing buffer if alive
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    if not (term_win and vim.api.nvim_win_is_valid(term_win)) then
      vim.cmd("botright 15split")
      term_win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(term_win, term_buf)
    end
    return
  end
  -- fresh terminal
  vim.cmd("botright 15split")
  term_win = vim.api.nvim_get_current_win()
  vim.cmd("terminal")
  term_buf = vim.api.nvim_get_current_buf()
  vim.cmd("wincmd p") -- jump back to code
end

local function close_term()
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.cmd("bwipeout! " .. term_buf)
    term_buf = nil
    term_win = nil
  end
end

-- When deleting a buffer, if any window would end up showing the R terminal
-- (because the deleted buffer was its previous occupant), swap it for a normal buffer
vim.api.nvim_create_autocmd("BufWinLeave", {
  callback = function(ev)
    -- Only care when a NORMAL file buffer is leaving a window
    if vim.bo[ev.buf].buftype ~= "" then return end

    vim.schedule(function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" then
          -- This window now shows a terminal — was it the one we just left?
          -- Find a replacement normal buffer
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if b ~= buf
              and vim.api.nvim_buf_is_loaded(b)
              and vim.bo[b].buflisted
              and vim.bo[b].buftype == ""
            then
              -- Only swap windows that weren't ALREADY showing the terminal before
              -- (i.e. the R console's own dedicated window should be left alone)
              local ok, was_term = pcall(vim.api.nvim_win_get_var, win, "_is_r_console")
              if not (ok and was_term) then
                pcall(vim.api.nvim_win_set_buf, win, b)
              end
              break
            end
          end
        end
      end
    end)
  end,
})

-- Mark the R console window so we never swap its contents
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.api.nvim_win_set_var(0, "_is_r_console", true)
  end,
})
