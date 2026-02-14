-- =========================================================
-- Leader & Globals
-- =========================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- =========================================================
-- Editor Options
-- =========================================================
local opt = vim.opt

opt.number = true
opt.mouse = 'a'
opt.showmode = false
opt.breakindent = true
opt.undofile = true
opt.signcolumn = 'yes'
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.cursorline = true
opt.scrolloff = 10
opt.hidden = true

opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

opt.inccommand = 'split'
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.encoding = 'utf-8'
opt.fileencoding = 'utf-8'
opt.fileencodings = 'utf-8'
opt.fileformats = 'unix,dos,mac'
opt.backspace = 'indent,eol,start'

opt.tabstop = 3
opt.shiftwidth = 3
opt.softtabstop = 0
opt.expandtab = true

vim.schedule(function()
  opt.clipboard = 'unnamedplus'
end)

-- =========================================================
-- Command Abbreviations
-- =========================================================
local cmd = vim.cmd
cmd 'cnoreabbrev W! w!'
cmd 'cnoreabbrev Q! q!'
cmd 'cnoreabbrev Qall! qall!'
cmd 'cnoreabbrev Wq wq'
cmd 'cnoreabbrev Wa wa'
cmd 'cnoreabbrev wQ wq'
cmd 'cnoreabbrev WQ wq'
cmd 'cnoreabbrev W w'
cmd 'cnoreabbrev Q q'
cmd 'cnoreabbrev Qall qall'

-- =========================================================
-- Autocommands
-- =========================================================
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Enable autoread
vim.o.autoread = true

-- Auto-check for file changes
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
    callback = function()
        if vim.fn.mode() ~= 'c' then
            vim.cmd("checktime")
        end
    end
})

-- Notify when file is reloaded
vim.api.nvim_create_autocmd("FileChangedShellPost", {
    callback = function()
        vim.api.nvim_echo({{"File changed on disk. Buffer reloaded.", "WarningMsg"}}, false, {})
    end
})


-- =========================================================
-- Keymaps (Central Module)
-- =========================================================
require("user.keymaps").setup()

-- =========================================================
-- Lazy.nvim Bootstrap
-- =========================================================
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- =========================================================
-- Plugins
-- =========================================================
require('lazy').setup({

-- =========================================================
-- === Look & Feel
-- =========================================================
{
  'folke/tokyonight.nvim',
  priority = 1000,
  init = function()
    vim.cmd.colorscheme 'habamax'
    vim.cmd.hi 'Comment gui=none'
  end,
},

{ 'HiPhish/rainbow-delimiters.nvim' },

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

{
  "nvim-lualine/lualine.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
        icons_enabled = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { { "filename", path = 1 }, "diagnostics" },
        lualine_x = { "filetype" },
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

-- =========================================================
-- === Search & Navigation
-- =========================================================
{
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},
},

{
  'nvim-telescope/telescope.nvim',
  branch = '0.22.x',
  cmd = "Telescope",
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function() return vim.fn.executable 'make' == 1 end,
    },
    'nvim-telescope/telescope-ui-select.nvim',
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    local telescope = require('telescope')

    -- Set up telescope with proper default preview configuration
    telescope.setup({
      defaults = {
        preview = {
          check_filetype = true,
          filetype_hook = function(filepath, bufnr, opts)
            vim.api.nvim_win_set_buf(opts.winid, bufnr)
          end,
        },
        present_line = { enabled = true },
        layout_config = {
          horizontal = {
            preview_width = 0.5,
          },
        },
      },
      pickers = {
        find_files = {
          theme = "dropdown",
          hidden = true,
        },
        buffers = {
          theme = "dropdown",
          preview_width = 0.6,
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    })

    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'ui-select')
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
},

{ 'nvim-pack/nvim-spectre', cmd = "Spectre" },

-- =========================================================
-- === Editing & Productivity
-- =========================================================
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
    highlight = { enable = true },
    indent = { enable = true },
  },
},

{ 'windwp/nvim-autopairs', event = 'InsertEnter', config = true },

{
  'stevearc/conform.nvim',
  event = 'BufWritePre',

  opts = {
    notify_on_error = false,

    formatters_by_ft = {
      lua = { 'stylua' },
      java = { 'google_java_format' },
      rust = { 'rustfmt' },
    },

    formatters = {
      google_java_format = {
        command = "java",
        args = {
          "-jar",
          "/usr/local/bin/google-java-format.jar",
          "--stdin",
        },
        stdin = true,
      },
    },
  },
},


-- =========================================================
-- === Git & VCS
-- =========================================================
{ 'lewis6991/gitsigns.nvim', event = 'VimEnter', opts = {} },
{ 'tpope/vim-fugitive', cmd = 'Git' },
{ 'airblade/vim-gitgutter' },
{
  'sindrets/diffview.nvim',
  cmd = 'Diffview',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local diffview = require('diffview')
    local api = require('telescope.actions')

    diffview.setup({
      diff_binaries = false,
      use_icons = true,
      show_help_hints = true,
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
      },
      file_panel = {
        listing_style = 'tree',
        tree_options = {
          flatten_dirs = true,
          icons = {
            folder_blank = ' ',
            folder_open = ' ',
            folder_empty = ' ',
          },
        },
        win_config = {
          position = 'left',
          width = 35,
          height = 1,
          border = 'rounded',
          winhighlight = { Cursor = 'CursorLine', Normal = 'Normal', EndOfBuffer = 'Special' },
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            diff_merges = 'combined',
          },
        },
        win_config = {
          position = 'bottom',
          height = 16,
          border = 'rounded',
          winhighlight = { Cursor = 'CursorLine', Normal = 'Normal', EndOfBuffer = 'Special' },
        },
        default_config = {
          mappings: {
            close = '<C-q>',
            option = '<C-o>',
          },
        },
      },
      default_args = {
        DiffviewOpen = {},
        DiffviewClose = {},
        DiffviewFileHistory = {},
      },
    })

    -- Telescope integration
    local view = require('diffview.view')
    view.EVENTS:subscribe(view.Events.FileHistoryClosed, function()
      if pcall(require, 'telescope.builtin') ~= nil then
        pcall(require('telescope.builtin').git_file_history, {})
      end
    end)
  end,
},
{ 'kdheepak/lazygit.nvim', cmd = 'LazyGit', dependencies = { 'nvim-lua/plenary.nvim' } },
{
    'lanej/hotreload.nvim',
    opts = {}  -- Uses fs_event watchers by default
},

-- =========================================================
-- === Terminal
-- =========================================================
{
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },
  config = function()
    require("toggleterm").setup({
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

    })

    local Terminal = require("toggleterm.terminal").Terminal

    package.loaded["user.toggleterm"] = {
      float_term = Terminal:new({ direction = "float", hidden = true }),
      right_term = Terminal:new({ direction = "vertical", size = 80, hidden = true }),
    }
  end,

  -- FIXME: overriding keymaps
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
},

-- =========================================================
-- === Errors & Diagnostics
-- =========================================================
{ 'folke/trouble.nvim', cmd = 'Trouble', opts = {} },

{
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = { signs = false },
},

-- =========================================================
-- === LSP Core
-- =========================================================
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

    local keymaps = require("user.keymaps")
    require('mason-lspconfig').setup {
      ensure_installed = vim.tbl_keys(servers),
      handlers = {
        function(name)
          if name == 'jdtls' then return end
          local cfg = servers[name] or {}
          cfg.capabilities = capabilities
          cfg.on_attach = keymaps.lsp_on_attach
          require('lspconfig')[name].setup(cfg)
        end,
      },
    }
  end,
},

-- =========================================================
-- === LSP Completion
-- =========================================================
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

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<CR>']  = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete({}),
      }),
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
      },
    })
  end,
},

-- =========================================================
-- === LSP Java Override
-- =========================================================
{
  'mfussenegger/nvim-jdtls',
  ft = 'java',
  config = function()
    local jdtls = require('jdtls')
    local root_dir = require('jdtls.setup').find_root({
      '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'
    })

    local keymaps = require("user.keymaps")

    jdtls.start_or_attach({
      cmd = { 'jdtls' },
      root_dir = root_dir,
      on_attach = keymaps.jdtls_on_attach,
    })

  end,
},

-- =========================================================
-- === AI Assistants
-- =========================================================
{
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  opts = {
    provider = "lmstudio",
    providers = {
      openai = {
        endpoint = "https://api.openai.com/v1/chat/completions",
        model = "gpt-4o-mini",
      },
      lmstudio = {
        __inherited_from = "openai",
        endpoint = "http://127.0.0.1:11434/v1",
        model = "zai-org/glm-4.6v-flash",
      },
      llamacpp = {
        __inherited_from = "openai",
        endpoint = "http://127.0.0.1:8080/v1",
        model = "gpt-oss:20b",
      },
    },
  },
},

{
  "johnseth97/codex.nvim",
  cmd = { "Codex", "CodexToggle" },
},

})

