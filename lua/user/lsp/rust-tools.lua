local mason_path = vim.fn.stdpath('data') .. 'mason'

require('which-key').register({ ['<localleader>r'] = { name = 'Rust Tools', h = 'Inlay Hints' } })

local rt = require('rust-tools')

local on_attach = function(_, bufnr)
  map('n', 'K', rt.hover_actions.hover_actions, { desc = 'hover', buffer = bufnr })
  map('n', '<localleader>rhe', rt.inlay_hints.set, { desc = 'set hints', buffer = bufnr })
  map('n', '<localleader>rhd', rt.inlay_hints.unset, { desc = 'unset hints', buffer = bufnr })
  map('n', '<localleader>rr', rt.runnables.runnables, { desc = 'runnables', buffer = bufnr })
  map('n', '<localleader>rc', rt.open_cargo_toml.open_cargo_toml, { desc = 'open cargo', buffer = bufnr })
  map('n', '<localleader>rd', rt.debuggables.debuggables, { desc = 'debuggables', buffer = bufnr })
  map('n', '<localleader>rm', rt.expand_macro.expand_macro, { desc = 'expand macro', buffer = bufnr })
  map('n', '<localleader>ro', rt.external_docs.open_external_docs, { desc = 'open external docs', buffer = bufnr })
  map('n', '<localleader>rp', rt.parent_module.parent_module, { desc = 'parent module', buffer = bufnr })
  map('n', '<localleader>rs', rt.workspace_refresh.reload_workspace, { desc = 'reload workspace', buffer = bufnr })
  map('n', '<localleader>rg', '<Cmd>RustViewCrateGraph<CR>', { desc = 'view crate graph', buffer = bufnr })
end

rt.setup({
  tools = {
    executor = require('rust-tools/executors').termopen, -- can be quickfix or termopen
    reload_workspace_from_cargo_toml = true,
    runnables = { use_telescope = false },
    inlay_hints = {
      auto = false,
      show_parameter_hints = false,
      parameter_hints_prefix = ' ',
    },
    hover_actions = {
      border = rvim.ui.border.rectangle,
      auto_focus = true,
      max_width = math.min(math.floor(vim.o.columns * 0.7), 100),
      max_height = math.min(math.floor(vim.o.lines * 0.3), 30),
    },
    on_initialized = function()
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'CursorHold', 'InsertLeave' }, {
        pattern = { '*.rs' },
        callback = function()
          local _, _ = pcall(vim.lsp.codelens.refresh)
        end,
      })
    end,
  },
  dap = {
    adapter = require('rust-tools.dap').get_codelldb_adapter(
      mason_path .. '/bin/codelldb',
      mason_path .. '/packages/codelldb/extension/lldb/lib/liblldb.so'
    ),
  },
  server = {
    on_attach = on_attach,
    standalone = false,
    settings = require('user.servers')('rust_analyzer'),
  },
})
