local M = {}

M.config = function()
  local jdtls = require('jdtls')
  local wk = require('which-key')

  local cmd = { vim.fn.exepath("jdtls") }
  
  -- Add lombok support if mason is available
  if vim.fn.executable("mason") == 1 then
    local lombok_jar = vim.fn.expand("$MASON/share/jdtls/lombok.jar")
    if vim.fn.filereadable(lombok_jar) == 1 then
      table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
    end
  end

  local opts = {
    root_dir = function(path)
      return vim.fs.root(path, vim.lsp.config.jdtls.root_markers)
    end,

    -- How to find the project name for a given root dir.
    project_name = function(root_dir)
      return root_dir and vim.fs.basename(root_dir)
    end,

    -- Where are the config and workspace dirs for a project?
    jdtls_config_dir = function(project_name)
      return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
    end,
    
    jdtls_workspace_dir = function(project_name)
      return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
    end,

    -- How to run jdtls
    cmd = cmd,
    
    full_cmd = function(opts)
      local fname = vim.api.nvim_buf_get_name(0)
      local root_dir = opts.root_dir(fname)
      local project_name = opts.project_name(root_dir)
      local cmd = vim.deepcopy(opts.cmd)
      if project_name then
        vim.list_extend(cmd, {
          "-configuration",
          opts.jdtls_config_dir(project_name),
          "-data",
          opts.jdtls_workspace_dir(project_name),
        })
      end
      return cmd
    end,

    -- DAP configuration
    dap = { 
      hotcodereplace = "auto", 
      config_overrides = {} 
    },
    
    -- Main class scan (set to false for large projects)
    dap_main = {},
    
    test = true,
    
    settings = {
      java = {
        inlayHints = {
          parameterNames = {
            enabled = true
          }
        },
        configuration = {
          runtimes = {
            {
              name = "JavaSE-17",
              path = "/usr/lib/jvm/java-17-openjdk"
            }
          }
        }
      }
    },
    
    -- Custom on_attach function
    on_attach = function(client, bufnr)
      -- Setup which-key mappings for Java
      wk.add({
        {
          mode = "n",
          buffer = bufnr,
          { "<leader>t", group = "test" },
          {
            "<leader>tt",
            function()
              require("jdtls.dap").test_class({
                config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
              })
            end,
            desc = "Run All Test",
          },
          {
            "<leader>tr",
            function()
              require("jdtls.dap").test_nearest_method({
                config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
              })
            end,
            desc = "Run Nearest Test",
          },
          { "<leader>tT", require("jdtls.dap").pick_test, desc = "Run Test" },
        },
      })
      
      -- Call the original on_attach if it exists
      if opts.on_attach then
        opts.on_attach(client, bufnr)
      end
    end
  }

  -- Start or attach jdtls
  local root_dir = opts.root_dir(vim.api.nvim_buf_get_name(0))
  jdtls.start_or_attach(opts)
end

return M