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
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup()
      vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
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
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        view = {
          width = 32,
          side = "left",
        },
      })

      vim.keymap.set(
        "n",
        "<leader>e",
        "<cmd>NvimTreeToggle<CR>",
        { desc = "Toggle file explorer" }
      )
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
    -- Neovim 0.11 native LSP config API
    -- (removes the deprecated require('lspconfig') framework usage)

    -- Capabilities (optional; safe even without cmp)
    local capabilities = vim.lsp.protocol.make_client_capabilities()

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
-- ────────────────────── R.nvim ──────────────────────
{
  "R-nvim/R.nvim",
  lazy = false,
  config = function()
    ---@type RConfigUserOpts
    local opts = {
      R_args = { "--quiet", "--no-save" },

      -- Auto-start R when opening an R file
      auto_start = "on startup",

      hook = {
        on_filetype = function()
          local b = { buffer = true, silent = true }

          -- ▶ Run entire file: <leader>r
          vim.keymap.set("n", "<leader>r", "<Plug>RSendFile", b)

          -- ▶ Run current line: Shift + Enter
          vim.keymap.set("n", "<S-CR>", "<Plug>RDSendLine", b)

          -- (optional but useful)
          -- Visual selection: run selection
          vim.keymap.set("v", "<leader>r", "<Plug>RSendSelection", b)
        end,
      },
    }

    require("r").setup(opts)
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



}

