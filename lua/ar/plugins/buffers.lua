local api, fn = vim.api, vim.fn
local ui = ar.ui
local fmt = string.format
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

_G.early_retirement_enabled = true

local function toggle_early_retirement()
  _G.early_retirement_enabled = not _G.early_retirement_enabled
  local status = _G.early_retirement_enabled and 'enabled' or 'disabled'
  vim.notify(fmt('Early retirement is now %s', status), vim.log.levels.INFO)
end

return {
  {
    'ton/vim-bufsurf',
    cond = function() return ar.get_plugin_cond('vim-bufsurf', not minimal) end,
    keys = { '[b', ']b' },
  },
  {
    'chrisgrieser/nvim-early-retirement',
    cond = function()
      return ar.get_plugin_cond('nvim-early-retirement', not minimal)
    end,
    event = 'VeryLazy',
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Toggle Early Retirement'] = toggle_early_retirement,
      })
    end,
    opts = {
      retirementAgeMins = 7,
      minimumBufferNum = 6,
      notificationOnAutoClose = false,
      deleteFunction = function(bufnr)
        if _G.early_retirement_enabled then
          api.nvim_buf_delete(bufnr, { force = false, unload = false })
        end
      end,
    },
  },
  {
    'razak17/cybu.nvim',
    cond = function() return ar.get_plugin_cond('cybu.nvim', not minimal) end,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      position = { relative_to = 'editor', anchor = 'topright' },
      style = {
        highlights = { background = 'NormalFloat' },
      },
    },
  },
  {
    'stevearc/stickybuf.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('stickybuf.nvim', condition)
    end,
    cmd = { 'PinBuffer', 'PinBuftype', 'PinFiletype', 'Unpin' },
    config = function()
      require('stickybuf').setup({
        get_auto_pin = function(bufnr)
          local buf_ft = api.nvim_get_option_value('filetype', { buf = bufnr })
          if buf_ft == 'DiffviewFiles' then
            -- this is a diffview tab, disable creating new windows
            -- (which would be the default behavior of handle_foreign_buffer)
            return {
              handle_foreign_buffer = function(_) end,
            }
          end
          return require('stickybuf').should_auto_pin(bufnr)
        end,
      })
    end,
  },
}
