local M = {}

local get_cursor_pos = function()
  return { vim.fn.line ".", vim.fn.col "." }
end

local debounce = function(func, timeout)
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

function M.hover_diagnostics()
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
            if rvim.plugin.saga.active then
              vim.cmd [[packadd lspsaga.nvim]]
              debounce(require("lspsaga.diagnostic").show_cursor_diagnostics(), 30)
            else
              vim.lsp.diagnostic.show_line_diagnostics { show_header = false, border = "single" }
            end
          end
        end
      end)(),
    },
  })
end

function M.setup()
  if rvim.lsp.hover_diagnostics then
    M.hover_diagnostics()
  end
end

return M
