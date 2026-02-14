local M = {}

-- =========================================================
-- Global Keymaps
-- =========================================================
function M.setup()
  local map = vim.keymap.set

  -- Core
  map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search' })
  map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diag list' })

  map('n', '<C-h>', '<C-w><C-h>', { desc = 'Win left' })
  map('n', '<C-l>', '<C-w><C-l>', { desc = 'Win right' })
  map('n', '<C-j>', '<C-w><C-j>', { desc = 'Win down' })
  map('n', '<C-k>', '<C-w><C-k>', { desc = 'Win up' })

  map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit term' })

  -- Search
  map('n', '<C-p>', function()
    require('telescope.builtin').find_files()
  end, { desc = 'Find files' })

  map('n', '<leader>sf', function()
    require('telescope.builtin').find_files()
  end, { desc = 'Search files' })

  map('n', '<leader>sg', function()
    require('telescope.builtin').live_grep()
  end, { desc = 'Live grep' })

  map('n', '<leader>sb', function()
    require('telescope.builtin').buffers()
  end, { desc = 'Search buffers' })

  map('n', '<leader>sh', function()
    require('telescope.builtin').help_tags()
  end, { desc = 'Help tags' })

  -- Explorer
  map('n', '\\', '<cmd>Neotree toggle<CR>', { desc = 'File explorer' })

  -- Replace
  map('n', '<leader>sS', '<cmd>Spectre<CR>', { desc = 'Search replace' })

  -- Format
  map('n', '<leader>f', function()
    require('conform').format({
      async = true,
      lsp_format = 'fallback',
    })
  end, { desc = 'Format file' })

  -- Git
  map('n', '<leader>hf', '<cmd>Git<CR>', { desc = 'Git status' })
  map('n', '<leader>hl', '<cmd>LazyGit<CR>', { desc = 'LazyGit UI' })

  -- Terminal
  map('n', '<leader>tf', function()
    require("user.toggleterm").float_term:toggle()
  end, { desc = 'Float term' })

  map('n', '<leader>tr', function()
    require("user.toggleterm").right_term:toggle()
  end, { desc = 'Right term' })

  -- Diagnostics Panel
  map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diag panel' })
  map('n', '<leader>xQ', '<cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix panel' })

  -- AI
  map('n', '<leader>cc', function()
    require("codex").toggle()
  end, { desc = 'Toggle Codex' })
end


-- =========================================================
-- LSP On Attach (Generic)
-- =========================================================
function M.lsp_on_attach(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  -- Navigation
  map('n', 'gd', vim.lsp.buf.definition, 'Goto def')
  map('n', 'gD', vim.lsp.buf.declaration, 'Goto decl')
  map('n', 'gi', vim.lsp.buf.implementation, 'Goto impl')
  map('n', 'go', vim.lsp.buf.type_definition, 'Type def')
  map('n', 'gr', vim.lsp.buf.references, 'References')

  -- Docs
  map('n', 'K', vim.lsp.buf.hover, 'Hover doc')
  map('n', '<C-k>', vim.lsp.buf.signature_help, 'Signature')

  -- Refactor
  map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
  map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')

  -- Diagnostics
  map('n', '<leader>ld', vim.diagnostic.open_float, 'Line diag')
  map('n', '[d', vim.diagnostic.goto_prev, 'Prev diag')
  map('n', ']d', vim.diagnostic.goto_next, 'Next diag')
  map('n', '<leader>lq', vim.diagnostic.setloclist, 'Diag list')

  -- Workspace
  map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, 'Add ws')
  map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Remove ws')
  map('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, 'List ws')

  -- Format
  map('n', '<leader>lf', function()
      require('conform').format({
        async = true,
        lsp_format = 'prefer',
      })
    end, 'LSP format')


  -- Inlay Hints (0.10+)
  if vim.lsp.inlay_hint then
    map('n', '<leader>uh', function()
      vim.lsp.inlay_hint.enable(
        not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
        { bufnr = bufnr }
      )
    end, 'Toggle hints')
  end
end


-- =========================================================
-- JDTLS On Attach (Java Extras)
-- =========================================================
function M.jdtls_on_attach(client, bufnr)
  M.lsp_on_attach(client, bufnr)

  local jdtls = require('jdtls')

  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map('n', '<leader>je', jdtls.extract_variable, 'Extract var')
  map('v', '<leader>je', jdtls.extract_variable, 'Extract var')

  map('n', '<leader>jm', jdtls.extract_method, 'Extract method')
  map('v', '<leader>jm', jdtls.extract_method, 'Extract method')

  map('n', '<leader>jo', jdtls.organize_imports, 'Organize imports')

  map('n', '<leader>jt', jdtls.test_class, 'Test class')
  map('n', '<leader>jn', jdtls.test_nearest_method, 'Test method')
end

return M
