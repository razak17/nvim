require('rust-tools').setup({
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
      rvim.path.mason .. '/bin/codelldb',
      rvim.path.mason .. '/packages/codelldb/extension/lldb/lib/liblldb.so'
    ),
  },
  server = {
    standalone = false,
    settings = {
      ['rust-analyzer'] = {
        lens = { enable = true },
        checkOnSave = { enable = true, command = 'clippy' },
      },
    },
  },
})
