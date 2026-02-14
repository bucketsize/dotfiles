-- =========================
-- Leader & Globals
-- =========================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true


-- =========================
-- Editor Options
-- =========================
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hidden = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.inccommand = 'split'

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.fileencodings = 'utf-8'
vim.opt.fileformats = 'unix,dos,mac'

vim.opt.backspace = 'indent,eol,start'

vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.softtabstop = 0
vim.opt.expandtab = true


-- Clipboard (delayed)
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)


-- =========================
-- Command Abbreviations
-- =========================
local abbrev = vim.cmd

abbrev 'cnoreabbrev W! w!'
abbrev 'cnoreabbrev Q! q!'
abbrev 'cnoreabbrev Qall! qall!'
abbrev 'cnoreabbrev Wq wq'
abbrev 'cnoreabbrev Wa wa'
abbrev 'cnoreabbrev wQ wq'
abbrev 'cnoreabbrev WQ wq'
abbrev 'cnoreabbrev W w'
abbrev 'cnoreabbrev Q q'
abbrev 'cnoreabbrev Qall qall'


-- =========================
-- Keymaps
-- =========================
local map = vim.keymap.set

-- Clear search
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostics
map('n', '<leader>q', vim.diagnostic.setloclist)

-- Terminal
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal' })

-- Window navigation
map('n', '<C-h>', '<C-w><C-h>')
map('n', '<C-l>', '<C-w><C-l>')
map('n', '<C-j>', '<C-w><C-j>')
map('n', '<C-k>', '<C-w><C-k>')


-- =========================
-- Autocommands
-- =========================
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})


-- =========================
-- Lazy.nvim Bootstrap
-- =========================
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git', 'clone', '--filter=blob:none', '--branch=stable', repo, lazypath
  }

  if vim.v.shell_error ~= 0 then
    error(out)
  end
end

vim.opt.rtp:prepend(lazypath)


-- =========================
-- Plugins
-- =========================
require('lazy').setup({

  -- === Look & Feel ===
  { 'folke/tokyonight.nvim', priority = 1000, init = function()
      vim.cmd.colorscheme 'habamax'
      vim.cmd.hi 'Comment gui=none'
    end
  },
  { 'HiPhish/rainbow-delimiters.nvim' },

  -- Bufferline (tabs)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",

    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",

          diagnostics = "nvim_lsp",

          separator_style = "slant",

          offsets = {
            {
              filetype = "NvimTree",
              text = "Explorer",
              highlight = "Directory",
              separator = true,
            },
          },

          show_buffer_close_icons = false,
          show_close_icon = false,

          hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
          },
        },
      })
    end,
  },

  -- Lualine (statusline)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",

    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",

          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },

          globalstatus = true, -- single bar
          icons_enabled = true,
        },

        sections = {

          lualine_a = { "mode" },

          lualine_b = { "branch" },

          lualine_c = {
            {
              "filename",
              path = 1,
            },
            "diagnostics",
          },

          lualine_x = {
            "filetype",
          },

          lualine_y = { "progress" },

          lualine_z = { "location" },
        },

        inactive_sections = {
          lualine_c = { "filename" },
          lualine_x = { "location" },
        },
      })
    end,
  },

  -- === Search & Navigation ===
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')

      telescope.setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')

      vim.keymap.set('n', '<C-p>', builtin.find_files)
      vim.keymap.set('n', '<leader>sf', builtin.find_files)
      vim.keymap.set('n', '<leader>sg', builtin.live_grep)
      vim.keymap.set('n', '<leader>sb', builtin.buffers)
      vim.keymap.set('n', '<leader>sh', builtin.help_tags)
    end,
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '\\', ':Neotree toggle<CR>', silent = true },
    },
  },

  { 'nvim-pack/nvim-spectre', keys = {
      { '<leader>sS', vim.cmd.Spectre },
    },
  },

  -- === Editing & Productivity ===
  { 'tpope/vim-sleuth' },

  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      require('mini.align').setup()
      require('mini.comment').setup()
    end,
  },

  {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPost', 'BufNewFile' },

  opts = {
    ensure_installed = {
      'bash','c','html','lua','markdown','vim','java','python','rust'
    },

    auto_install = true,

    highlight = {
      enable = true,
    },

    indent = {
      enable = true,
    },
  },
},



  { 'windwp/nvim-autopairs', event = 'InsertEnter', config = true },

  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    keys = {
      { '<leader>f', function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end
      },
    },
    opts = {
      notify_on_error = false,
      formatters_by_ft = {
        lua = { 'stylua' },
      },
    },
  },

  -- === Git & VCS ===
  {
    'lewis6991/gitsigns.nvim',
    event = 'VimEnter',
    opts = {},
  },

  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>hf', '<cmd>Git<cr>' },
    },
  },

  { 'airblade/vim-gitgutter' },

  {
    'kdheepak/lazygit.nvim',
    cmd = 'LazyGit',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>hl', '<cmd>LazyGit<cr>' },
    },
  },

  {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },

  keys = {
    -- Floating terminal
    {
      "<leader>tf",
      function()
        require("user.toggleterm").float_term:toggle()
      end,
      desc = "Toggle Floating Terminal",
    },

    -- Right vertical terminal
    {
      "<leader>tr",
      function()
        require("user.toggleterm").right_term:toggle()
      end,
      desc = "Toggle Vertical Terminal (Right)",
    },
    {
      "<Esc>",
      [[<C-\><C-n>]],
      mode = "t",
      desc = "Exit Terminal Mode",
    },
  },

  opts = {
    --open_mapping = [[<leader>tt]], -- fallback mapping
    open_mapping = [[<C-t>]],
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = true,
    close_on_exit = true,
    shade_terminals = true,
    direction = "float",
    float_opts = {
      border = "rounded",
    },
  },

  -- Create terminal objects and store them in a module
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal

    -- stores instances in a module table
    package.loaded["user.toggleterm"] = {
      float_term = Terminal:new({ direction = "float", hidden = true }),
      right_term = Terminal:new({ direction = "vertical", size = 80, hidden = true }),
    }
  end,
},


  -- === Errors, Diagnostics & Debug ===
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {},
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>' },
    },
  },

  { 'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- === LSP Core ===
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities()
      )

      local servers = {
        jdtls = {},
        pyright = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      require('mason').setup()

      require('mason-tool-installer').setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        handlers = {
          function(name)
            if name == 'jdtls' then 
              -- to use mfussenegger/nvim-jdtls
              return
            end
            local cfg = servers[name] or {}
            cfg.capabilities = vim.tbl_deep_extend(
              'force', {}, capabilities, cfg.capabilities or {}
            )
            require('lspconfig')[name].setup(cfg)
          end,
        },
      }
    end,
  },

  -- === LSP Completion & Snippets ===
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = function()
          if vim.fn.has 'win32' == 1 then return end
          return 'make install_jsregexp'
        end,
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<CR>']  = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },

  -- === LSP:Java Override
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    config = function()
      local jdtls = require('jdtls')

      local root_dir = require('jdtls.setup').find_root({
        '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'
      })

      local config = {
        cmd = { 'jdtls' },
        root_dir = root_dir,
      }

      jdtls.start_or_attach(config)
    end,
  },


  -- === AI Assistants ===
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    opts = {
      -- Set which provider to use by default:
      provider = "lmstudio",   -- or "lmstudio" below

      providers = {
        -- == OpenAI / GPT-4o-mini configuration ==
        openai = {
          endpoint = "https://api.openai.com/v1/chat/completions",
          model = "gpt-4o-mini",
          timeout = 30000,   -- ms for slower models
          extra_request_body = {
            temperature = 0.1,
            max_completion_tokens = 14096,
          },
        },

        -- == LMStudio (local OSS LLM) configuration ==
        lmstudio = {
           __inherited_from = "openai",
          endpoint = "http://127.0.0.1:11434/v1",
          model = "zai-org/glm-4.6v-flash", --gpt-oss:20b", -- model exposed by LMStudio
          timeout = 30000,
          extra_request_body = {
            temperature = 0.1,
            max_completion_tokens = 14096,
          },
        },

        -- == LLaMA CPP style server config ==
        llamacpp = {
           __inherited_from = "openai",
          endpoint = "http://127.0.0.1:8080/v1",
          model = "gpt-oss:20b",                  -- or whichever gguf model name your server serves
          timeout = 30000,
          extra_request_body = {
            temperature = 0.1,
            max_completion_tokens = 14096,
          },
        },
      },
    },

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-tree/nvim-web-devicons",
    },
  },
  {
    "johnseth97/codex.nvim",
    lazy = true,                       -- loads on demand
    cmd = { "Codex", "CodexToggle" },  -- load when running these commands
    keys = {
      {
        "<leader>cc",
        function() require("codex").toggle() end,
        desc = "Toggle Codex window",
      },
    },
    opts = {
      keymaps = {
        toggle = nil,      -- disable internal default toggle key
        quit   = "<C-q>",   -- close Codex window
      },
      border      = "rounded",  -- floating window border style
      width       = 0.8,        -- relative width
      height      = 0.8,        -- relative height
      model       = nil,        -- custom model name (optional)
      autoinstall = true,       -- auto-install `codex` CLI
      panel       = false,      -- `false` = floating, `true` = vertical split
      use_buffer  = false,      -- capture output into buffer
    },
  },
},
{
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = '⌘',
			config = '🛠',
			event = '📅',
			ft = '📂',
			init = '⚙',
			keys = '🗝',
			plugin = '🔌',
			runtime = '💻',
			require = '🌙',
			source = '📄',
			start = '🚀',
			task = '📌',
			lazy = '💤 ',
		},
	},
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
