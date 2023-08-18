local api, fn = vim.api, vim.fn
local ui = rvim.ui

local align = { provider = '%=' }

return {
  {
    'rebelot/heirline.nvim',
    event = 'VeryLazy',
    enabled = not rvim.plugins.minimal,
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
          statusline.word_count,
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
            -- if not rvim.ui.statuscolumn.enable then return false end
            if rvim.falsy(d) then return true end
            return d and d.ft == true or d and d.fname == true
          end,
          static = statuscolumn.static,
          init = statuscolumn.init,
          statuscolumn.render,
        },
      })
    end,
  },
}
