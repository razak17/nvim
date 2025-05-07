local border = ar.ui.current.border

local enabled = ar.lsp.enable and not ar.plugin_disabled('rustaceanvim')

return {
  {
    'mrcjkb/rustaceanvim',
    ft = { 'rust' },
    cond = enabled,
    init = function()
      vim.g.whichkey_add_spec({ '<leader><leader>r', group = 'Rustaceanvim' })
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
            local extension_path = ar.get_pkg_path('codelldb', 'extension')
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
            map('n', '<leader><leader>rr', function() rlsp({'runnables', 'last' }) end, { desc = 'runnables', buffer = bufnr })
            map('n', '<leader><leader>rc', function() rlsp('openCargo') end, { desc = 'open cargo', buffer = bufnr })
            map('n', '<leader><leader>rd', function() rlsp({'debuggables', 'last' }) end, { desc = 'debuggables', buffer = bufnr })
            map('n', '<leader><leader>rm', function() rlsp('expandMacro') end, { desc = 'expand macro', buffer = bufnr })
            map('n', '<leader><leader>ro', function() rlsp('externalDocs') end, { desc = 'open external docs', buffer = bufnr })
            map('n', '<leader><leader>rp', function() rlsp('parentModule') end, { desc = 'parent module', buffer = bufnr })
            map('n', '<leader><leader>rs', function() rlsp('reloadWorkspace') end, { desc = 'reload workspace', buffer = bufnr })
            map('n', '<leader><leader>rg', function() rlsp({ 'crateGraph', '[backend]', '[output]' }) end, { desc = 'view crate graph', buffer = bufnr })
            map('n', '<leader><leader>ra', function() rlsp('codeAction') end, { desc = 'code action', buffer = bufnr })
            map('n', '<leader><leader>rx', function() rlsp('explainError') end, { desc = 'explain error', buffer = bufnr })
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
      vim.g.whichkey_add_spec({ '<leader><localleader>c', group = 'Crates' })
    end,
    cond = not ar.plugins.minimal,
    event = 'BufRead Cargo.toml',
    opts = {
      popup = { autofocus = true, border = border },
      null_ls = { enabled = true, name = 'crates' },
    },
  },
}
