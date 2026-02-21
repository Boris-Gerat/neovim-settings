-- ============================================================
-- KEYMAPS.LUA (clean + conflict-free + working)
-- ============================================================

-- Leader keys (set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
  
-- Small helper
local function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ============================================================
-- BASIC EDITING / MOTION
-- ============================================================

-- Start of line
map("n", "<leader>h", "^", { desc = "Start of line" })

-- You asked specifically: <Space><Space>l -> end of line
map("n", "<leader><leader>l", "$", { nowait = true, desc = "End of line (double leader)" })
map("v", "<leader><leader>l", "$", { nowait = true, desc = "End of line (double leader)" })

-- Select all
map("n", "<leader>a", "ggVG", { desc = "Select all" })

-- Clipboard yank
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })

-- File actions
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Buffer nav (global)
map("n", "<leader>n", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>p", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- macOS GUI select-all (works only in some terminals)
map("n", "<D-a>", "ggVG", { desc = "Select all (GUI)" })

-- Fast jumps (J/K = 10 lines)
map({ "n", "v" }, "J", "10j", { desc = "Down 10" })
map({ "n", "v" }, "K", "10k", { desc = "Up 10" })

-- ============================================================
-- TOGGLETERM
-- ============================================================

-- Dedicated terminal (#2) so it doesn't conflict with R console
map("n", "<leader>t", function()
  require("toggleterm").toggle(2, nil, nil, "horizontal")
end, { desc = "Toggle terminal (#2)" })

-- Terminal-mode QoL
do
  local term_opts = { noremap = true, silent = true }
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], term_opts)
  vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], term_opts)
  vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], term_opts)
  vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], term_opts)
  vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], term_opts)
end

-- ============================================================
-- RUN CURRENT FILE (Python / R)
-- ============================================================

local function run_current_file()
  local file = vim.fn.expand("%:p")
  local ext  = vim.fn.expand("%:e")

  if ext == "py" then
    -- Python runs in ToggleTerm terminal #2 (real shell)
    require("toggleterm").exec("python " .. vim.fn.fnameescape(file), 2)

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

-- Global runner
map("n", "<leader>r", run_current_file, { desc = "Run current file" })

-- ============================================================
-- PYTHON: format with black (buffer-local)
-- ============================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(ev)
    vim.keymap.set("n", "<leader>fmp", function()
      if vim.fn.executable("black") == 1 then
        vim.cmd("silent !black %")
      else
        vim.notify("black not found in PATH", vim.log.levels.WARN)
      end
    end, { buffer = ev.buf, silent = true, desc = "Format with black" })
  end,
})

-- ============================================================
-- R FILETYPE: fix lag + assignment + send line/selection + alt buffer
-- ============================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "R", "rmd", "quarto" },
  callback = function(ev)
    vim.schedule(function()
      -- remove Nvim-R mapping that causes "space" delay (if present)
      pcall(vim.keymap.del, "i", "<Space>,", { buffer = ev.buf })

      -- assignment shortcut: \. -> " <- "
      vim.keymap.set("i", "\\.", " <- ", {
        buffer = ev.buf,
        silent = true,
        desc = "Insert <-",
      })

      -- Shift+Enter: run line / run selection
      vim.keymap.set("n", "<S-CR>", "<Plug>RDSendLine", {
        buffer = ev.buf,
        silent = true,
        desc = "Send line to R",
      })
      vim.keymap.set("v", "<S-CR>", "<Plug>RSendSelection", {
        buffer = ev.buf,
        silent = true,
        desc = "Send selection to R",
      })

      -- In R buffers: <leader>p toggles alternate buffer instantly
      vim.keymap.set("n", "<leader>p", "<cmd>b#<cr>", {
        buffer = ev.buf,
        nowait = true,
        silent = true,
        desc = "Previous (alternate) buffer",
      })
    end)
  end,
})

-- ============================================================
-- TEX: VimTeX (buffer-local overrides)
-- ============================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true, noremap = true }

    -- In tex: <leader>r compiles instead of run_current_file
    vim.keymap.set("n", "<leader>r", "<cmd>VimtexCompile<CR>",
      vim.tbl_extend("force", opts, { desc = "VimTeX Compile" })
    )
    vim.keymap.set("n", "<leader>v", "<cmd>VimtexView<CR>",
      vim.tbl_extend("force", opts, { desc = "View PDF" })
    )
    vim.keymap.set("n", "<leader>k", "<cmd>VimtexStop<CR>",
      vim.tbl_extend("force", opts, { desc = "Stop compile" })
    )
  end,
})

-- ============================================================
-- R.nvim: start/show/close console (FIXED: no invalid "or" statement)
-- ============================================================

local function r_cmd(cmd)
  return pcall(vim.cmd, cmd)
end

local function r_start_and_focus()
  -- Start R first
  if not (r_cmd("RStart") or r_cmd("R")) then
    vim.notify("R.nvim: can't start R (no :RStart / :R).", vim.log.levels.ERROR)
    return
  end

  -- Then try to focus/show the console (command name depends on version)
  vim.defer_fn(function()
    -- try focus, else show, else console
    if not r_cmd("RFocus") then
      if not r_cmd("RShow") then
        r_cmd("RConsole")
      end
    end
  end, 120)
end

map("n", "<leader>rr", r_start_and_focus, { desc = "R: Start + show console" })
map("n", "<leader>rq", "<cmd>RClose<cr>", { desc = "R: Close" })

-- ============================================================
-- LSP: prevent K being stolen by hover
-- ============================================================

-- Many setups map K -> hover. We keep YOUR K=10k and move hover to gK.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    -- Keep jump mappings in LSP buffers too
    vim.keymap.set("n", "K", "10k", { buffer = ev.buf, noremap = true, silent = true, desc = "Up 10" })
    vim.keymap.set("n", "J", "10j", { buffer = ev.buf, noremap = true, silent = true, desc = "Down 10" })

    -- Hover lives here instead
    vim.keymap.set("n", "gK", vim.lsp.buf.hover, { buffer = ev.buf, desc = "LSP Hover" })
  end,
})

-- ============================================================
-- FORCE jj at the VERY END so nothing overrides it
-- ============================================================

vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Exit insert" })
-- End of line (single leader)
vim.keymap.set("n", "<leader>l", "$", { noremap = true, silent = true, nowait = true, desc = "End of line" })
vim.keymap.set("v", "<leader>l", "$", { noremap = true, silent = true, nowait = true, desc = "End of line" })





vim.keymap.set("n", "<leader>rc", function()
  -- If R console exists → close
  if vim.fn.exists(":RClose") == 2 then
    pcall(vim.cmd, "RClose")
  end

  -- Try to start R
  if not pcall(vim.cmd, "RStart") then
    pcall(vim.cmd, "R")
  end
end, { desc = "R: Toggle console" })


vim.keymap.set("t", "<leader>cl", function()
  local keys = vim.api.nvim_replace_termcodes(
    'system("clear")\r',
    true,
    false,
    true
  )
  vim.api.nvim_feedkeys(keys, "t", false)
end, { desc = "Clear R console" })




vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "R", "rmd", "quarto" },
  callback = function(ev)
    vim.schedule(function()
      -- 1) KILL the plugin mapping that uses <Space> to send/run
      pcall(vim.keymap.del, "n", "<Space>", { buffer = ev.buf })
      pcall(vim.keymap.del, "v", "<Space>", { buffer = ev.buf })

      -- (you already have this; keep it)
      pcall(vim.keymap.del, "i", "<Space>,", { buffer = ev.buf })

      -- 2) Force your leader+l mapping in R buffers
      vim.keymap.set("n", "<leader>l", "$", {
        buffer = ev.buf,
        noremap = true,
        silent = true,
        nowait = true,
        desc = "End of line",
      })
      vim.keymap.set("v", "<leader>l", "$", {
        buffer = ev.buf,
        noremap = true,
        silent = true,
        nowait = true,
        desc = "End of line",
      })

      -- ...keep the rest of your R mappings (\\. , <S-CR>, etc.)
    end)
  end,
})
