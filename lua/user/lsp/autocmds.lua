local M = {}
local Log = require "user.core.log"

function M.enable_lsp_document_highlight(client_id)
  rvim.augroup("LspCursorCommands", {
    {
      events = { "CursorHold" },
      targets = { "<buffer>" },
      command = string.format(
        "lua require('user.lsp.utils').conditional_document_highlight(%d)",
        client_id
      ),
    },
    {
      events = { "CursorHoldI" },
      targets = { "<buffer>" },
      command = "lua vim.lsp.buf.document_highlight()",
    },
    {
      events = { "CursorMoved" },
      targets = { "<buffer>" },
      command = "lua vim.lsp.buf.clear_references()",
    },
  })
end

function M.disable_lsp_document_highlight()
  rvim.disable_augroup "lsp_document_highlight"
end

function M.enable_code_lens_refresh()
  rvim.augroup("LspCodeLensRefresh", {
    {
      events = { "InsertLeave" },
      targets = { "<buffer>" },
      command = "lua vim.lsp.codelens.refresh()",
    },
    {
      events = { "InsertLeave" },
      targets = { "<buffer>" },
      command = "lua vim.lsp.codelens.display()",
    },
  })
end

function M.disable_code_lens_refresh()
  rvim.disable_augroup "lsp_code_lens_refresh"
end

function M.enable_lsp_hover_diagnostics()
  local get_cursor_pos = function()
    return { vim.fn.line ".", vim.fn.col "." }
  end

  rvim.augroup("HoverDiagnostics", {
    {
      events = { "CursorHold" },
      targets = { "<buffer>" },
      command = (function()
        local cursorpos = get_cursor_pos()
        return function()
          local new_cursor = get_cursor_pos()
          if
            (new_cursor[1] ~= 1 and new_cursor[2] ~= 1)
            and (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2])
          then
            cursorpos = new_cursor
            vim.lsp.diagnostic.show_line_diagnostics { show_header = false, border = "single" }
          end
        end
      end)(),
    },
  })
end

local get_format_on_save_opts = function()
  local defaults = rvim.common.format_on_save
  -- accept a basic boolean `rvim.format_on_save=true`
  if type(rvim.common.format_on_save) ~= "table" then
    return defaults
  end

  return {
    pattern = rvim.common.format_on_save.pattern or defaults.pattern,
    timeout = rvim.common.format_on_save.timeout or defaults.timeout,
  }
end

function M.enable_format_on_save(opts)
  local fmd_cmd = string.format(":silent lua vim.lsp.buf.formatting_sync({}, %s)", opts.timeout_ms)
  rvim.augroup("FormatOnSave", {
    {
      events = { "BufWritePre" },
      targets = { opts.pattern },
      command = fmd_cmd,
    },
  })
  Log:debug "enabled format-on-save"
end

function M.disable_format_on_save()
  rvim.remove_augroup "format_on_save"
  Log:debug "disabled format-on-save"
end

function M.configure_format_on_save()
  if rvim.common.format_on_save then
    if vim.fn.exists "#format_on_save#BufWritePre" == 1 then
      rvim.remove_augroup "format_on_save"
      Log:debug "reloading format-on-save configuration"
    end
    local opts = get_format_on_save_opts()
    M.enable_format_on_save(opts)
  else
    M.disable_format_on_save()
  end
end

function M.toggle_format_on_save()
  if vim.fn.exists "#format_on_save#BufWritePre" == 0 then
    local opts = get_format_on_save_opts()
    M.enable_format_on_save(opts)
  else
    M.disable_format_on_save()
  end
end

local function set_diagnostics()
  return vim.diagnostic.setqflist { open = false }
end

function M.enable_lsp_commands()
  local command = rvim.command

  command {
    "LspDiagnostics",
    function()
      set_diagnostics()
      rvim.toggle_list "quickfix"
      if rvim.is_vim_list_open() then
        rvim.augroup("LspDiagnosticUpdate", {
          {
            events = { "DiagnosticChanged" },
            targets = { "*" },
            command = function()
              set_diagnostics()
              if rvim.is_vim_list_open() then
                rvim.toggle_list "quickfix"
              end
            end,
          },
        })
      elseif vim.fn.exists "#LspDiagnosticUpdate" > 0 then
        vim.cmd "autocmd! LspDiagnosticUpdate"
      end
      vim.cmd "copen"
    end,
  }

  command {
    "LspLog",
    function()
      vim.cmd("edit " .. vim.lsp.get_log_path())
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
      vim.lsp.diagnostic.display(
        vim.lsp.diagnostic.get(0, 1),
        0,
        1,
        { virtual_text = virtual_text.show }
      )
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
