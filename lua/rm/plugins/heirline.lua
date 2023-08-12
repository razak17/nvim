local api, fn = vim.api, vim.fn
local ui, sep = rvim.ui, rvim.ui.icons.separators
local separator = sep.left_thin_block
local space = ' '

local align = { provider = '%=' }
local spacer = { provider = space }
local divider = { provider = separator, hl = 'LineNr' }

return {
  {
    'rebelot/heirline.nvim',
    event = 'VeryLazy',
    enabled = not rvim.plugins.minimal or not rvim.ui.statuscolumn.enable,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local statuscolumn = require('rm.statuscolumn')
      local statusline = require('rm.statusline')

      require('heirline').setup({
        statusline = {
          condition = function()
            local win = api.nvim_get_current_win()
            local buf = api.nvim_win_get_buf(win)
            local d = ui.decorations.get({
              ft = vim.bo[buf].ft,
              fname = fn.bufname(buf),
              setting = 'statusline',
            })
            if rvim.falsy(d) then return true end
            return d and d.ft == true or d and d.fname == true
          end,
          statusline.vim_mode,
          statusline.git_branch,
          statusline.file_name_block,
          statusline.python_env,
          statusline.lsp_diagnostics,
          align,
          statusline.package_info,
          statusline.git_diff,
          statusline.lazy_updates,
          statusline.search_results,
          statusline.lsp_clients,
          statusline.copilot_attached,
          statusline.copilot_status,
          statusline.dap,
          statusline.file_type,
          -- statusline.file_encoding,
          statusline.formatting,
          statusline.spell,
          -- statusline.treesitter,
          -- statusline.session,
          statusline.macro_recording,
          statusline.ruler,
          statusline.scroll_bar,
          -- statusline.vim_mode,
        },
        statuscolumn = {
          condition = function()
            local win = api.nvim_get_current_win()
            local buf = api.nvim_win_get_buf(win)
            local d = ui.decorations.get({
              ft = vim.bo[buf].ft,
              fname = fn.bufname(buf),
              setting = 'statuscolumn',
            })
            if rvim.falsy(d) then return true end
            return d and d.ft == true or d and d.fname == true
          end,
          static = statuscolumn.static,
          init = statuscolumn.init,
          statuscolumn.signs,
          align,
          spacer,
          statuscolumn.line_numbers,
          spacer,
          statuscolumn.git_signs,
          divider,
          statuscolumn.folds,
          spacer,
        },
      })
    end,
  },
}
