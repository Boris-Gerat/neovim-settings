vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.ipynb",
  callback = function()
    vim.bo.filetype = "jupyter"
  end,
})



-- ============================================================
-- KEYMAPS.LUA (clean + conflict-free + working)
-- ============================================================

  
-- Small helper
local function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ============================================================
-- BASIC EDITING / MOTION
-- ============================================================

map("n", "<leader>h", "^", { desc = "Start of line" })

map("n", "<leader><leader>l", "$", { nowait = true, desc = "End of line (double leader)" })
map("v", "<leader><leader>l", "$", { nowait = true, desc = "End of line (double leader)" })

map("n", "<leader>a", "ggVG", { desc = "Select all" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

map("n", "<leader>n", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>p", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

map("n", "<D-a>", "ggVG", { desc = "Select all (GUI)" })

map({ "n", "v" }, "J", "10j", { desc = "Down 10" })
map({ "n", "v" }, "K", "10k", { desc = "Up 10" })

-- ============================================================
-- TOGGLETERM
-- ============================================================

map("n", "<leader>t", function()
  require("toggleterm").toggle(2, nil, nil, "horizontal")
end, { desc = "Toggle terminal (#2)" })

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
    require("toggleterm").exec("python " .. vim.fn.fnameescape(file), 2)

  elseif ext == "r" or ext == "R" then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Plug>RSendFile", true, false, true),
      "n",
      false
    )

  else
    vim.notify("No runner for this filetype: " .. ext, vim.log.levels.WARN)
  end
end

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
      pcall(vim.keymap.del, "i", "<Space>,", { buffer = ev.buf })

      vim.keymap.set("i", "\\.", " <- ", {
        buffer = ev.buf,
        silent = true,
        desc = "Insert <-",
      })

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
-- R FILETYPE: kill plugin <Space> mappings + force <leader>l
-- ============================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "R", "rmd", "quarto" },
  callback = function(ev)
    vim.schedule(function()
      pcall(vim.keymap.del, "n", "<Space>", { buffer = ev.buf })
      pcall(vim.keymap.del, "v", "<Space>", { buffer = ev.buf })
      pcall(vim.keymap.del, "i", "<Space>,", { buffer = ev.buf })

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

    vim.keymap.set("n", "<leader>r", "<cmd>VimtexCompile<CR>",
      vim.tbl_extend("force", opts, { desc = "VimTeX Compile" })
    )
    vim.keymap.set("n", "<leader>v", "<cmd>VimtexView<CR>",
      vim.tbl_extend("force", opts, { desc = "View PDF" })
    )
    vim.keymap.set("n", "<leader>k", "<cmd>VimtexStop<CR>",
      vim.tbl_extend("force", opts, { desc = "Stop compile" })
    )
    vim.keymap.set({ "n", "v" }, "<leader>l", "$",
      vim.tbl_extend("force", opts, { nowait = true, desc = "End of line" })
    )
  end,
})

-- ============================================================
-- R.nvim: start/show/close console
-- ============================================================

local function r_cmd(cmd)
  return pcall(vim.cmd, cmd)
end

local function r_start_and_focus()
  if not (r_cmd("RStart") or r_cmd("R")) then
    vim.notify("R.nvim: can't start R (no :RStart / :R).", vim.log.levels.ERROR)
    return
  end
  vim.defer_fn(function()
    if not r_cmd("RFocus") then
      if not r_cmd("RShow") then
        r_cmd("RConsole")
      end
    end
  end, 120)
end

map("n", "<leader>rr", r_start_and_focus, { desc = "R: Start + show console" })
map("n", "<leader>rq", "<cmd>RKill<cr>", { desc = "R: Kill" })

vim.keymap.set("n", "<leader>rc", function()
  require("r.run").start_R("R")
end, { desc = "R: Start console" })

vim.keymap.set("t", "<leader>cl", function()
  local keys = vim.api.nvim_replace_termcodes(
    'system("clear")\r',
    true,
    false,
    true
  )
  vim.api.nvim_feedkeys(keys, "t", false)
end, { desc = "Clear R console" })

-- ============================================================
-- LSP: prevent K being stolen by hover
-- ============================================================

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.keymap.set("n", "K", "10k", { buffer = ev.buf, noremap = true, silent = true, desc = "Up 10" })
    vim.keymap.set("n", "J", "10j", { buffer = ev.buf, noremap = true, silent = true, desc = "Down 10" })
    vim.keymap.set("n", "gK", vim.lsp.buf.hover, { buffer = ev.buf, desc = "LSP Hover" })
  end,
})

-- ============================================================
-- FORCE: jj, <leader>l (global, set last so nothing overrides)
-- ============================================================

vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Exit insert" })
vim.keymap.set("n", "<leader>l", "$", { noremap = true, silent = true, nowait = true, desc = "End of line" })
vim.keymap.set("v", "<leader>l", "$", { noremap = true, silent = true, nowait = true, desc = "End of line" })

-- ============================================================
-- FORCE: Enter = newline, Tab = accept completion
-- ============================================================

local function force_pum_keys()
  vim.keymap.set("i", "<CR>", function()
    if vim.fn.pumvisible() == 1 then
      return vim.api.nvim_replace_termcodes("<C-e><CR>", true, false, true)
    end
    return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
  end, { expr = true, noremap = true, silent = true })

  vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
      return vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
    end
    return vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
  end, { expr = true, noremap = true, silent = true })
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(force_pum_keys, 50)
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = force_pum_keys,
})

-- R pipe shortcut: \= → %>%
vim.keymap.set("i", "\\=", " %>% ", { noremap = true, silent = true })

-- ============================================================
-- MOLTEN: global output settings
-- ============================================================

vim.g.molten_output_win_max_height = 20
vim.g.molten_auto_open_output = true
vim.g.molten_output_show_more = true
vim.g.molten_virt_text_output = true
vim.g.molten_virt_lines_off_by_1 = false

-- ============================================================
-- JUPYTER / MOLTEN
-- Keymaps attached via BufEnter on *.ipynb so they work
-- regardless of whether filetype ends up as "jupyter" or "python"
-- ============================================================

local function setup_molten_keymaps(buf)
  -- Guard: only set up once per buffer
  if vim.b[buf].molten_keymaps_set then return end
  vim.b[buf].molten_keymaps_set = true

  local opts = { buffer = buf, silent = true }

  vim.keymap.set("n", "<leader>ji", "<cmd>MoltenInit python3<CR>",
    vim.tbl_extend("force", opts, { desc = "Jupyter: Init kernel" }))

  vim.keymap.set("n", "<S-CR>", "<cmd>MoltenEvaluateLine<CR>",
    vim.tbl_extend("force", opts, { desc = "Jupyter: Run line" }))

  vim.keymap.set("v", "<S-CR>", function()
    vim.cmd("noautocmd normal! \27")
    vim.cmd("MoltenEvaluateVisual")
  end, vim.tbl_extend("force", opts, { desc = "Jupyter: Run selection" }))

  vim.keymap.set("n", "<leader>r", function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("normal! ggVG")
    vim.cmd("MoltenEvaluateVisual")
    vim.api.nvim_win_set_cursor(0, pos)
  end, vim.tbl_extend("force", opts, { desc = "Jupyter: Run all" }))

  vim.keymap.set("n", "<leader>jl", "<cmd>MoltenReevaluateCell<CR>",
    vim.tbl_extend("force", opts, { desc = "Jupyter: Re-run cell" }))
  vim.keymap.set("n", "<leader>jq", "<cmd>MoltenDeinit<CR>",
    vim.tbl_extend("force", opts, { desc = "Jupyter: Close kernel" }))
  vim.keymap.set("n", "<leader>jk", "<cmd>MoltenInterrupt<CR>",
    vim.tbl_extend("force", opts, { desc = "Jupyter: Interrupt kernel" }))
  vim.keymap.set("n", "<leader>jo", "<cmd>MoltenShowOutput<CR>",
    vim.tbl_extend("force", opts, { desc = "Jupyter: Show output" }))
  vim.keymap.set("n", "<leader>jh", "<cmd>MoltenHideOutput<CR>",
    vim.tbl_extend("force", opts, { desc = "Jupyter: Hide output" }))
end

-- Attach keymaps + auto-init kernel based on FILENAME, not filetype.
-- This fires after jupytext (or any conversion plugin) has done its thing.
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.ipynb",
  callback = function(ev)
    vim.defer_fn(function()
      -- Ensure buffer is still valid (user might have closed it)
      if not vim.api.nvim_buf_is_valid(ev.buf) then return end

      -- Set up keymaps for this buffer
      setup_molten_keymaps(ev.buf)

      -- Auto-init kernel if not already done
      if not vim.b[ev.buf].molten_initialized then
        vim.cmd("MoltenInit python3")
        vim.b[ev.buf].molten_initialized = true
      end
    end, 200) -- 200ms delay to let jupytext finish converting
  end,
})

-- ============================================================
-- MOLTEN: highlights
-- ============================================================

local function set_molten_highlights()
  vim.api.nvim_set_hl(0, "MoltenCell",                { bg = "#1e2030" })
  vim.api.nvim_set_hl(0, "MoltenOutputText",          { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "MoltenVirtualText",         { fg = "#f38ba8", italic = true })
  vim.api.nvim_set_hl(0, "MoltenOutputSuccess",       { fg = "#f38ba8", italic = true })
  vim.api.nvim_set_hl(0, "MoltenOutputFail",          { fg = "#f38ba8", italic = true })
  vim.api.nvim_set_hl(0, "MoltenOutputBorder",        { fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "MoltenOutputBorderSuccess", { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "MoltenOutputBorderFail",    { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "MoltenOutputWin",           { bg = "#1e2030", fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "MoltenOutputWinNC",         { bg = "#1e2030", fg = "#6c7086" })
  vim.api.nvim_set_hl(0, "MoltenOutputFooter",        { fg = "#6c7086", italic = true })
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(set_molten_highlights, 500)
  end,
})
vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = set_molten_highlights })

-- ============================================================
-- MISC
-- ============================================================

vim.o.maxfuncdepth = 200

vim.keymap.set("n", "<leader>Q", function()
  local tw = vim.opt.textwidth:get()
  if tw == 0 then tw = 80 end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  -- Iterate in reverse so line-number shifts from gqq don't affect us
  for i = #lines, 1, -1 do
    if #lines[i] > tw then
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      vim.cmd("normal! gqq")
    end
  end
end, { silent = true, desc = "Wrap only long lines" })


-- R TERMINAL TOGGLE
map("n", "<leader>rt", function()
  local r_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("term://") and name:match(":R") then
      r_win = win
      break
    end
  end

  if r_win then
    vim.api.nvim_win_hide(r_win)
  else
    pcall(vim.cmd, "RShow")
  end
end, { desc = "R: Toggle console visibility" })




-- Terminal Limitations 
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(ev)
    vim.keymap.set("n", "<leader>n", "<Nop>", { buffer = ev.buf, silent = true })
    vim.keymap.set("n", "<leader>p", "<Nop>", { buffer = ev.buf, silent = true })
  end,
})


local obsidian_vault = "/Users/borisgerat/Documents/Obsidian"


-- Global <leader>on that works everywhere
vim.keymap.set("n", "<leader>on", function()
  local ft = vim.bo.filetype
  if ft == "NvimTree" or ft == "netrw" or ft == "" then
    vim.ui.input({ prompt = "New note name: " }, function(name)
      if name and name ~= "" then
        name = name:gsub("%.md$", "")
        local path = "/Users/borisgerat/Documents/Obsidian/main/" .. name .. ".md"
        vim.cmd("edit " .. vim.fn.fnameescape(path))
      end
    end)
  else
    vim.cmd("ObsidianNew")
  end
end, { silent = true, desc = "Obsidian: New note" })

-- All other Obsidian keymaps only for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set("n", "<CR>", "<cmd>ObsidianFollowLink<CR>",
      vim.tbl_extend("force", opts, { desc = "Obsidian: Follow link" }))
    vim.keymap.set("n", "<leader>oB", "<cmd>ObsidianBacklinks<CR>",
      vim.tbl_extend("force", opts, { desc = "Obsidian: Backlinks" }))
    vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianOpen<CR>",
      vim.tbl_extend("force", opts, { desc = "Obsidian: Open in app" }))
    vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTemplate<CR>",
      vim.tbl_extend("force", opts, { desc = "Obsidian: Insert template" }))
    vim.keymap.set("n", "<leader>od", function()
      local file = vim.fn.expand("%:p")
      vim.ui.input({ prompt = "Delete " .. vim.fn.expand("%:t") .. "? (y/n): " }, function(input)
        if input == "y" then
          vim.cmd("bdelete!")
          vim.fn.delete(file)
          vim.notify("Deleted: " .. file)
        end
      end)
    end, vim.tbl_extend("force", opts, { desc = "Obsidian: Delete note" }))
    vim.keymap.set("n", "<leader>oj", function()
      require("telescope.builtin").find_files({
        prompt_title = "Tags",
        cwd = "/Users/borisgerat/Documents/Obsidian/main/2-Tags",
        attach_mappings = function(_, map)
          map("i", "<CR>", function(prompt_bufnr)
            local selection = require("telescope.actions.state").get_selected_entry()
            require("telescope.actions").close(prompt_bufnr)
            local tag_name = vim.fn.fnamemodify(selection.value, ":t:r")
            vim.api.nvim_put({ "[[" .. tag_name .. "]]" }, "c", true, true)
          end)
          return true
        end,
      })
    end, vim.tbl_extend("force", opts, { desc = "Obsidian: Insert tag link" }))
    vim.keymap.set("n", "<leader>og", function()
      vim.ui.input({ prompt = "Tag name: " }, function(name)
        if name and name ~= "" then
          local path = "/Users/borisgerat/Documents/Obsidian/main/2-Tags/" .. name .. ".md"
          vim.cmd("edit " .. path)
        end
      end)
    end, vim.tbl_extend("force", opts, { desc = "Obsidian: New tag note" }))
    vim.keymap.set("v", "<leader>ob", function()
      vim.cmd("normal! \27")
      local s_start = vim.fn.getpos("'<")
      local s_end   = vim.fn.getpos("'>")
      local s_row, s_col = s_start[2] - 1, s_start[3] - 1
      local e_row         = s_end[2] - 1
      local line_len = #vim.api.nvim_buf_get_lines(0, e_row, e_row + 1, false)[1]
      local e_col = math.min(s_end[3], line_len)
      local lines = vim.api.nvim_buf_get_text(0, s_row, s_col, e_row, e_col, {})
      lines[1]      = "**" .. lines[1]
      lines[#lines] = lines[#lines] .. "**"
      vim.api.nvim_buf_set_text(0, s_row, s_col, e_row, e_col, lines)
    end, vim.tbl_extend("force", opts, { desc = "Obsidian: Bold selection" }))
  end,
})

