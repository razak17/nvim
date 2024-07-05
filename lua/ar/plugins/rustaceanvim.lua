local border = ar.ui.current.border

local enabled = ar.lsp.enable and not ar.plugin_disabled('rustaceanvim')

return {
  {
    'mrcjkb/rustaceanvim',
    version = '^3', -- Recommended
    ft = { 'rust' },
    cond = enabled,
    init = function()
      require('which-key').register({
        ['<localleader>r'] = { name = 'Rustaceanvim' },
      })
    end,
    config = function()
      vim.g.rustaceanvim = {
        tools = {
          executor = require('rustaceanvim/executors').termopen, -- can be quickfix or termopen
          reload_workspace_from_cargo_toml = true,
          runnables = { use_telescope = false },
          hover_actions = {
            border = ar.ui.border.rectangle,
            auto_focus = true,
            max_width = math.min(math.floor(vim.o.columns * 0.7), 100),
            max_height = math.min(math.floor(vim.o.lines * 0.3), 30),
          },
          on_initialized = function()
            vim.api.nvim_create_autocmd(
              { 'BufWritePost', 'BufEnter', 'CursorHold', 'InsertLeave' },
              {
                pattern = { '*.rs' },
                callback = function()
                  local _, _ = pcall(vim.lsp.codelens.refresh)
                end,
              }
            )
          end,
        },
        dap = {
          adapter = function()
            local mason_registry = require('mason-registry')
            local codelldb = mason_registry.get_package('codelldb')
            local extension_path = codelldb:get_install_path() .. '/extension'
            local codelldb_path = extension_path .. '/adapter/codelldb'
            local liblldb_path = extension_path .. '/lldb/lib/liblldb.so'

            return require('rustaceanvim.config').get_codelldb_adapter(
              codelldb_path,
              liblldb_path
            )
          end,
        },
        server = {
        -- stylua: ignore
          on_attach = function(_, bufnr)
            local rlsp = vim.cmd.RustLsp

            map('n', 'K', function() rlsp({ 'hover', 'actions' }) end, { desc = 'hover', buffer = bufnr })
            map('n', '<localleader>rr', function() rlsp({'runnables', 'last' }) end, { desc = 'runnables', buffer = bufnr })
            map('n', '<localleader>rc', function() rlsp('openCargo') end, { desc = 'open cargo', buffer = bufnr })
            map('n', '<localleader>rd', function() rlsp({'debuggables', 'last' }) end, { desc = 'debuggables', buffer = bufnr })
            map('n', '<localleader>rm', function() rlsp('expandMacro') end, { desc = 'expand macro', buffer = bufnr })
            map('n', '<localleader>ro', function() rlsp('externalDocs') end, { desc = 'open external docs', buffer = bufnr })
            map('n', '<localleader>rp', function() rlsp('parentModule') end, { desc = 'parent module', buffer = bufnr })
            map('n', '<localleader>rs', function() rlsp('reloadWorkspace') end, { desc = 'reload workspace', buffer = bufnr })
            map('n', '<localleader>rg', function() rlsp({ 'crateGraph', '[backend]', '[output]' }) end, { desc = 'view crate graph', buffer = bufnr })
            map('n', '<localleader>ra', function() rlsp('codeAction') end, { desc = 'code action', buffer = bufnr })
            map('n', '<localleader>rx', function() rlsp('explainError') end, { desc = 'explain error', buffer = bufnr })
          end,
          standalone = false,
          settings = {
            ['rust-analyzer'] = {
              assist = {
                importEnforceGranularity = true,
                importPrefix = 'create',
              },
              cargo = { allFeatures = true },
              checkOnSave = {
                command = 'clippy',
                allFeatures = true,
              },
              inlayHints = {
                lifetimeElisionHints = {
                  enable = true,
                  useParameterNames = true,
                },
              },
              lens = { enable = true },
            },
          },
        },
      }
    end,
  },
  {
    'Saecki/crates.nvim',
    init = function()
      require('which-key').register({
        ['<localleader>c'] = { name = 'Crates' },
      })
    end,
    cond = not ar.plugins.minimal,
    event = 'BufRead Cargo.toml',
    opts = {
      popup = { autofocus = true, border = border },
      null_ls = { enabled = true, name = 'crates' },
    },
  },
}
