return function()
  rvim.augroup('GoLang', {
    {
      event = { 'BufWritePost' },
      pattern = { '*.go' },
      command = function() require('go.format').goimport() end,
    },
    -- FIX: Running more than once
    {
      event = { 'BufEnter' },
      pattern = { '*.go' },
      once = true,
      command = function()
        local get_config = require('user.core.servers')
        require('go').setup({
          gopls_cmd = { 'gopls' },
          icons = false,
          verbose = false,
          lsp_cfg = get_config('gopls'),
          lsp_codelens = false,
          lsp_keymaps = false,
          lsp_diag_hdlr = false,
          dap_debug_keymap = false,
          textobjects = false,
          luasnip = true,
        })
      end,
    },
  })
end
