-- ~/.config/nvim/lua/plugins.lua
return {

  -- ────────────────────── Noice (dependency) ──────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {},
  },

  -- ────────────────────── Auto-session ──────────────────────
  {
    "rmagatti/auto-session",
    dependencies = { "folke/noice.nvim" },
    config = function()
      require("auto-session").setup({
        log_level = "error",
        auto_session_suppress_dirs = { "~", "~/Downloads" },
        auto_session_enable_last_session = false,
        auto_restore_enabled = false,
        pre_save_cmds = {},
      })
    end,
  },

  -- ────────────────────── Colorscheme ──────────────────────
  -- ────────────────────── Colorscheme ──────────────────────
{
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      integrations = {
        native_lsp = { enabled = true },
      },
      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.overlay1 }, -- non-current lines
          CursorLineNr = { fg = colors.lavender, bold = true }, -- current line
        }
      end,
    })

    vim.cmd.colorscheme("catppuccin")
  end,
}, 
  -- ────────────────────── Telescope ──────────────────────
-- ────────────────────── Telescope ──────────────────────
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.setup()

    -- Always use Neovim's current cwd
    vim.keymap.set("n", "<leader>ff", function()
      builtin.find_files({ cwd = vim.fn.getcwd() })
    end, { desc = "Find files (cwd)" })

    vim.keymap.set("n", "<leader>fg", function()
      builtin.live_grep({ cwd = vim.fn.getcwd() })
    end, { desc = "Live grep (cwd)" })
  end,
},

-- ────────────────────── Nvim-Tree (FILE EXPLORER) ──────────────────────
{
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup({
      disable_netrw = true,
      hijack_netrw = true,

      sync_root_with_cwd = true,
      respect_buf_cwd = true,

      update_focused_file = {
        enable = true,
        update_root = true,
      },

      view = {
        width = 32,
        side = "left",
      },
    })

    -- Refresh tree when Neovim's cwd changes via :cd / :tcd / :lcd
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
          api.tree.change_root(vim.fn.getcwd())
          api.tree.reload()
        end
      end,
    })

    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
  end,
},



{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",  -- Add this to auto-install/update parsers
  opts = {
    ensure_installed = {
      "r",
      "markdown",
      "markdown_inline",
      "rnoweb",
      "yaml",
      "lua",      -- Recommended for Neovim Lua files
      "python",   -- Add if you work with Python (from your pyright LSP)
      -- Add others as needed, e.g., "vim", "bash"
    },
    highlight = {
      enable = true,  -- Enable syntax highlighting
      additional_vim_regex_highlighting = false,  -- Avoid conflicts
    },
    -- Optional: Enable other modules if needed (e.g., for indentation or textobjects)
    indent = { enable = true },
  },
},

  -- ────────────────────── QoL ──────────────────────
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    opts = { indent = { char = "│" } },
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        direction = "horizontal",
        open_mapping = [[<C-\>]],
        start_in_insert = true,
      })
    end,
  },

-- ────────────────────── LSP (Neovim 0.11+) ──────────────────────
{
  "neovim/nvim-lspconfig",
  lazy = false,
  config = function()
    -- Capabilities (for nvim-cmp)
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if ok_cmp then
      capabilities = cmp_lsp.default_capabilities(capabilities)
    end

    -- PYRIGHT
    vim.lsp.config("pyright", {
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
    })
    vim.lsp.enable("pyright")

    -- LUA (lua-language-server)
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
        },
      },
    })
    vim.lsp.enable("lua_ls")
  end,
},

  -- ────────────────────── R.nvim ──────────────────────
{
  "R-nvim/R.nvim",
  lazy = false,
  config = function()
    require("r").setup({
      R_args = { "--quiet", "--no-save" },

      -- DO NOT auto start
      auto_start = "no",
    })
  end,
},
-- ────────────────────── LaTeX (vimtex) ──────────────────────
{
  "lervag/vimtex",
  ft = { "tex", "plaintex", "latex" },
  init = function()
    -- Use latexmk
    vim.g.vimtex_compiler_method = "latexmk"

    -- Viewer (macOS)
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 1

    -- General behavior
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_fold_enabled = 0
    vim.g.vimtex_syntax_enabled = 1

    -- latexmk options
    vim.g.vimtex_compiler_latexmk = {
      build_dir = "build",
      callback = 1,
      continuous = 1,
      executable = "latexmk",
      options = {
        "-pdf",
        "-interaction=nonstopmode",
        "-synctex=1",
      },
    }
  end,
  config = function()
    -- Ensure build dir exists
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tex",
      callback = function()
        vim.fn.mkdir("build", "p")
      end,
    })
  end,
},

{
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",           -- buffers, not tabs
        diagnostics = "nvim_lsp",
        separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
        always_show_bufferline = true,
      },
    })
  end,
},

{
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
        { name = "luasnip" },
      }),
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
    })
  end,
},

{
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    format_on_save = function(bufnr)
      if vim.bo[bufnr].filetype == "python" then
        return {
          timeout_ms = 10000, -- ⬅️ 10 seconds
          lsp_fallback = true,
        }
      end
    end,
    formatters_by_ft = {
      python = { "black" },
    },
  },
},






}

