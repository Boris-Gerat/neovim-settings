-- Leader keys (set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- small helper
local function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("keep", opts or {}, { noremap = true, silent = true })
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ---------- BUFFER MOTION ----------
map("n", "<leader>l", "$")
map("n", "<leader>h", "^")
map("v", "<leader>l", "$")

-- ---------- FILE ACTIONS ----------
map("n", "<leader>w", "<cmd>w<cr>")
map("n", "<leader>q", "<cmd>q<cr>")
-- ---------- SELECT ALL ----------
map("n", "<leader>a", "ggVG", { desc = "Select all" })

-- ---------- RUN CURRENT FILE (auto-detect interpreter) ----------
local function run_current()
  local ok, runner = pcall(require, "utils.runner")
  if ok and runner.run_current_file then
    runner.run_current_file()
  else
    vim.notify("utils.runner not found", vim.log.levels.WARN)
  end
end
map("n", "<leader>r", run_current, { desc = "Run current file (auto-detected)" })

-- ---------- INSERT MODE QoL ----------
map("i", "jj", "<esc>")

-- ---------- CLIPBOARD ----------
map({ "n", "v" }, "<leader>y", [["+y]])

-- ---------- FORMAT WITH BLACK (Python only) ----------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(ev)
    vim.keymap.set("n", "<leader>fmp", function()
      if vim.fn.executable("black") == 1 then
        vim.cmd("silent !black %")
      else
        vim.notify("black not found in PATH", vim.log.levels.WARN)
      end
    end, { buffer = ev.buf, desc = "Format with black", silent = true })
  end,
})

-- ---------- BUFFER NAV ----------
map("n", "<leader>n", "<cmd>bn<cr>")
map("n", "<leader>p", "<cmd>bp<cr>")
map("n", "<leader>x", "<cmd>bd<cr>")

-- ---------- SELECT ALL (GUI/macOS capable terminals only) ----------
-- Note: many terminals don't pass <d-…> to Neovim; harmless if it doesn't work.
map("n", "<d-a>", "ggvg")

-- ---------- BASIC TERMINAL (split) ----------
-- ---------- TERMINAL (ToggleTerm, horizontal) ----------
map("n", "<leader>t", function()
  require("toggleterm").toggle(1, nil, nil, "horizontal")
end, { desc = "Toggle horizontal terminal" })

-- ---------- FAST JUMPS ----------
map("n", "H", "H")
map("n", "L", "L")
map("n", "J", "10j")
map("n", "K", "10k")
map("v", "J", "10j")
map("v", "K", "10k")

-- ---------- RUN CURRENT FILE (Python / R) ----------
local function run_current_file()
  local file = vim.fn.expand("%:p")
  local ext  = vim.fn.expand("%:e")

  if ext == "py" then
    -- Python: run whole file in ToggleTerm
    require("toggleterm").exec("python " .. vim.fn.fnameescape(file))

  elseif ext == "r" or ext == "R" then
    -- R: send whole file to R.nvim
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Plug>RSendFile", true, false, true),
      "n",
      false
    )

  else
    vim.notify("No runner for this filetype: " .. ext, vim.log.levels.WARN)
  end
end

vim.keymap.set("n", "<leader>r", run_current_file, { desc = "Run current file" })

-- ---------- R: Shift+Enter runs current line ----------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "R" },
  callback = function(ev)
    vim.keymap.set(
      "n",
      "<S-CR>",
      "<Plug>RDSendLine",
      { buffer = ev.buf, silent = true, desc = "Send line to R" }
    )
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    local opts = { buffer = true, silent = true, desc = "VimTeX Compile" }

    -- Compile LaTeX with latexmk
    vim.keymap.set("n", "<leader>r", "<cmd>VimtexCompile<CR>", opts)

    -- (optional but very useful)
    vim.keymap.set("n", "<leader>v", "<cmd>VimtexView<CR>", { buffer = true, desc = "View PDF" })
    vim.keymap.set("n", "<leader>k", "<cmd>VimtexStop<CR>", { buffer = true, desc = "Stop compile" })
  end,
})

local opts = { noremap = true, silent = true }

-- Exit terminal-mode quickly
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)

-- Optional: window navigation directly from terminal-mode
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)



