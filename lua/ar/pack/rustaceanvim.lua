if not ar.lsp.enable then return end

local name = 'rustaceanvim'
local override = ar.config.lsp.override
if not ar.falsy(override) then
  if not vim.tbl_contains(override, name) then return end
elseif not ar.get_plugin_cond(name, ar.config.lsp.lang.rust[name]) then
  return
end

local bacon_ls = ar.config.lsp.lang.rust.bacon_ls

-- Rustaceanvim loads itself through ftplugin/rust.lua; register it before FileType.
ar.pack.add({
  src = 'https://github.com/mrcjkb/rustaceanvim',
  lazy = false,
  setup = function()
    vim.g.whichkey_add_spec({ '<leader><leader>r', group = 'Rustaceanvim' })
    vim.g.rustaceanvim = {
      tools = {
        executor = require('rustaceanvim/executors').termopen, -- can be quickfix or termopen
        reload_workspace_from_cargo_toml = true,
        runnables = { use_telescope = false },
        hover_actions = {
          border = ar.ui.current.border.rectangle,
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
                local _, _ = pcall(vim.lsp.codelens.enable)
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
        cmd_env = {
          PATH = vim.fs.joinpath(
            vim.env.CARGO_HOME or vim.fn.expand('~/.cargo'),
            'bin'
          )
            .. ':'
            .. vim.env.PATH,
        },
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
        -- standalone = false,
        default_settings = {
          ['rust-analyzer'] = {
            assist = {
              importEnforceGranularity = true,
              importPrefix = 'crate',
            },
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = { enable = true },
            },
            diagnostics = { enable = not bacon_ls },
            lens = { enable = true },
            procMacro = { enable = true },
            files = {
              exclude = {
                '.direnv',
                '.git',
                '.jj',
                '.github',
                '.gitlab',
                'bin',
                'node_modules',
                'target',
                'venv',
                '.venv',
              },
              -- Avoid Roots Scanned hanging, see https://github.com/rust-lang/rust-analyzer/issues/12613#issuecomment-2096386344
              watcher = 'client',
            },
          },
        },
      },
    }
  end,
})
