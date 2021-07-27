local lsp_utils = {}

-- Taken from https://www.reddit.com/r/neovim/comments/gyb077/nvimlsp_peek_defination_javascript_ttserver/
function lsp_utils.preview_location(location, context, before_context)
  -- location may be LocationLink or Location (more useful for the former)
  context = context or 15
  before_context = before_context or 0
  local uri = location.targetUri or location.uri
  if uri == nil then
    return
  end
  local bufnr = vim.uri_to_bufnr(uri)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end

  local range = location.targetRange or location.range
  local contents = vim.api.nvim_buf_get_lines(
    bufnr,
    range.start.line - before_context,
    range["end"].line + 1 + context,
    false
  )
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return vim.lsp.util.open_floating_preview(contents, filetype, { border = rvim.lsp.popup_border })
end

function lsp_utils.preview_location_callback(_, method, result)
  local context = 15
  if result == nil or vim.tbl_isempty(result) then
    print("No location found: " .. method)
    return nil
  end
  if vim.tbl_islist(result) then
    lsp_utils.floating_buf, lsp_utils.floating_win = lsp_utils.preview_location(result[1], context)
  else
    lsp_utils.floating_buf, lsp_utils.floating_win = lsp_utils.preview_location(result, context)
  end
end

function lsp_utils.PeekDefinition()
  if vim.tbl_contains(vim.api.nvim_list_wins(), lsp_utils.floating_win) then
    vim.api.nvim_set_current_win(lsp_utils.floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(
      0,
      "textDocument/definition",
      params,
      lsp_utils.preview_location_callback
    )
  end
end

function lsp_utils.PeekTypeDefinition()
  if vim.tbl_contains(vim.api.nvim_list_wins(), lsp_utils.floating_win) then
    vim.api.nvim_set_current_win(lsp_utils.floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(
      0,
      "textDocument/typeDefinition",
      params,
      lsp_utils.preview_location_callback
    )
  end
end

function lsp_utils.PeekImplementation()
  if vim.tbl_contains(vim.api.nvim_list_wins(), lsp_utils.floating_win) then
    vim.api.nvim_set_current_win(lsp_utils.floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(
      0,
      "textDocument/implementation",
      params,
      lsp_utils.preview_location_callback
    )
  end
end

function lsp_utils.check_lsp_client_active(name)
  local clients = vim.lsp.get_active_clients()
  for _, client in pairs(clients) do
    if client.name == name then
      return true
    end
  end
  return false
end

function lsp_utils.lspLocList()
  rvim.augroup("LspLocationList", {
    {
      events = { "User LspDiagnosticsChanged" },
      command = function()
        vim.lsp.diagnostic.set_loclist {
          workspace = true,
          severity_limit = "Warning",
          open_loclist = false,
        }
      end,
    },
  })
end

function lsp_utils.toggle_autoformat()
  if rvim.lsp.format_on_save then
    rvim.augroup("AutoFormatOnSaVE", {
      {
        events = { "BufWritePre" },
        targets = { "*" },
        command = ":silent lua vim.lsp.buf.formatting_sync()",
      },
    })
  end

  if not rvim.format_on_save then
    vim.cmd [[
      if exists('#autoformat#BufWritePre')
        :autocmd! autoformat
      endif
    ]]
  end
end

function lsp_utils.root_dir()
  local util = require "lspconfig.util"
  return util.root_pattern(".gitignore", ".git", vim.fn.getcwd())
end

lsp_utils.get_cursor_pos = function()
  return { vim.fn.line ".", vim.fn.col "." }
end

lsp_utils.debounce = function(func, timeout)
  local timer_id = nil
  return function(...)
    if timer_id ~= nil then
      vim.fn.timer_stop(timer_id)
    end
    local args = { ... }

    timer_id = vim.fn.timer_start(timeout, function()
      func(args)
      timer_id = nil
    end)
  end
end

function lsp_utils.hover_diagnostics()
  rvim.augroup("HoverDiagnostics", {
    {
      events = { "CursorHold" },
      targets = { "<buffer>" },
      command = (function()
        local cursorpos = lsp_utils.get_cursor_pos()
        return function()
          local new_cursor = lsp_utils.get_cursor_pos()
          if
            (new_cursor[1] ~= 1 and new_cursor[2] ~= 1)
            and (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2])
          then
            cursorpos = new_cursor
            if rvim.plugin.saga.active then
              vim.cmd [[packadd lspsaga.nvim]]
              lsp_utils.debounce(require("lspsaga.diagnostic").show_cursor_diagnostics(), 30)
            else
              vim.lsp.diagnostic.show_line_diagnostics { show_header = false, border = "single" }
            end
          end
        end
      end)(),
    },
  })
end

return lsp_utils
