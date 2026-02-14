local M = {}

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
    require('conform').format({ async = true, lsp_format = 'fallback' })
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

  -- Diagnostics
  map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diag panel' })
  map('n', '<leader>xQ', '<cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix panel' })

  -- AI
  map('n', '<leader>cc', function()
    require("codex").toggle()
  end, { desc = 'Toggle Codex' })
end

return M
