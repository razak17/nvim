return function()
  local stages_util = require('notify.stages.util')
  local fade_in_slide_out_bottom = {
    function(state)
      local next_height = state.message.height + 2
      local next_row =
        stages_util.available_slot(state.open_windows, next_height, stages_util.DIRECTION.BOTTOM_UP)
      if not next_row then return nil end
      return {
        relative = 'editor',
        anchor = 'NE',
        width = state.message.width,
        height = state.message.height,
        col = vim.opt.columns:get(),
        row = next_row,
        border = 'rounded',
        style = 'minimal',
        opacity = 0,
      }
    end,
    function(state, win)
      return {
        opacity = { 100 },
        col = { vim.opt.columns:get() },
        row = {
          stages_util.slot_after_previous(win, state.open_windows, stages_util.DIRECTION.BOTTOM_UP),
          frequency = 3,
          complete = function() return true end,
        },
      }
    end,
    function(state, win)
      return {
        col = { vim.opt.columns:get() },
        time = true,
        row = {
          stages_util.slot_after_previous(win, state.open_windows, stages_util.DIRECTION.BOTTOM_UP),
          frequency = 3,
          complete = function() return true end,
        },
      }
    end,
    function(state, win)
      return {
        width = {
          1,
          frequency = 2.5,
          damping = 0.9,
          complete = function(cur_width) return cur_width < 3 end,
        },
        opacity = {
          0,
          frequency = 2,
          complete = function(cur_opacity) return cur_opacity <= 4 end,
        },
        col = { vim.opt.columns:get() },
        row = {
          stages_util.slot_after_previous(win, state.open_windows, stages_util.DIRECTION.BOTTOM_UP),
          frequency = 3,
          complete = function() return true end,
        },
      }
    end,
  }

  local api = vim.api
  local codicons = rvim.style.codicons

  local notify = require('notify')

  notify.setup({
    max_width = function() return math.floor(vim.o.columns * 0.8) end,
    max_height = function() return math.floor(vim.o.lines * 0.8) end,
    background_colour = 'NormalFloat',
    on_open = function(win)
      if api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, { border = rvim.style.border.current })
      end
    end,
    timeout = 500,
    stages = fade_in_slide_out_bottom,
    render = function(...)
      local notif = select(2, ...)
      local style = notif.title[1] == '' and 'minimal' or 'default'
      require('notify.render')[style](...)
    end,
    icons = {
      ERROR = codicons.lsp.error,
      WARN = codicons.lsp.warn,
      INFO = codicons.lsp.info,
      HINT = codicons.lsp.hint,
      TRACE = codicons.lsp.trace,
    },
  })

  vim.notify = notify
end
