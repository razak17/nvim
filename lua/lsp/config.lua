local M = {}

function M.setup()
  local command = rvim.command

  vim.lsp.protocol.CompletionItemKind = rvim.lsp.completion.item_kind

  for _, sign in ipairs(rvim.lsp.diagnostics.signs.values) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end

  command {
    "LspLog",
    function()
      local path = vim.lsp.get_log_path()
      vim.cmd("edit " .. path)
    end,
  }
  command {
    "LspFormat",
    function()
      -- vim.lsp.buf.formatting(vim.g[string.format("format_options_%s", vim.bo.filetype)] or {})
      vim.cmd [[
        :silent lua vim.lsp.buf.formatting_sync()
      ]]
    end,
  }
  command {
    "LspToggleVirtualText",
    function()
      local virtual_text = {}
      virtual_text.show = true
      virtual_text.show = not virtual_text.show
      vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1, { virtual_text = virtual_text.show })
    end,
  }
  command {
    "LspReload",
    function()
      vim.cmd [[
      :lua vim.lsp.stop_client(vim.lsp.get_active_clients())
      :edit
    ]]
    end,
  }
end

return M
