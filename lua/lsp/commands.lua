local command = rvim.command
local M = {}

function M.init()
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
      vim.lsp.buf.formatting(vim.g[string.format("format_options_%s", vim.bo.filetype)] or {})
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
