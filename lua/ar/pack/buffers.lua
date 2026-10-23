local fmt = string.format

_G.early_retirement_enabled = true

local function toggle_early_retirement()
  _G.early_retirement_enabled = not _G.early_retirement_enabled
  local status = _G.early_retirement_enabled and 'enabled' or 'disabled'
  vim.notify(fmt('Early retirement is now %s', status), vim.log.levels.INFO)
end

ar.pack.add({
  {
    src = 'https://github.com/ton/vim-bufsurf',
    event = 'VeryLazy',
    cond = function() return ar.get_plugin_cond('vim-bufsurf') end,
    setup = function()
      local function jump(options)
        return ar.jump(function(opts)
          if opts.forward then vim.cmd('BufSurfForward') end
          if not opts.forward then vim.cmd('BufSurfBack') end
        end, options)
      end
      map('n', 'gP', jump({ forward = false }), { desc = 'previous buffer' })
      map('n', 'gN', jump({ forward = true }), { desc = 'next buffer' })
    end,
  },
  {
    src = 'https://github.com/chrisgrieser/nvim-early-retirement',
    cond = function()
      return ar.get_plugin_cond('nvim-early-retirement', not ar.plugins.minimal)
    end,
    event = 'VeryLazy',
    init = function()
      ar.add_to_select('command_palette', {
        ['Toggle Early Retirement'] = toggle_early_retirement,
      })
    end,
    setup = function()
      require('early-retirement').setup({
        retirementAgeMins = 7,
        minimumBufferNum = 6,
        notificationOnAutoClose = false,
        deleteFunction = function(bufnr)
          if _G.early_retirement_enabled then
            vim.api.nvim_buf_delete(bufnr, { force = false, unload = false })
          end
        end,
      })
    end,
  },
  {
    src = 'https://github.com/razak17/cybu.nvim',
    cond = function()
      return ar.get_plugin_cond('cybu.nvim', not ar.plugins.minimal)
    end,
    event = { 'BufRead', 'BufNewFile' },
    setup = function()
      require('cybu').setup({
        position = { relative_to = 'editor', anchor = 'topright' },
        style = {
          highlights = { background = 'NormalFloat' },
        },
      })
    end,
  },
  {
    src = 'https://github.com/stevearc/stickybuf.nvim',
    cond = function()
      return ar.get_plugin_cond('stickybuf.nvim', not ar.plugins.minimal)
    end,
    cmd = { 'PinBuffer', 'PinBuftype', 'PinFiletype', 'Unpin' },
    setup = function()
      require('stickybuf').setup({
        get_auto_pin = function(bufnr)
          local buf_ft =
            vim.api.nvim_get_option_value('filetype', { buf = bufnr })
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
  {
    src = 'https://github.com/ahkohd/buffer-sticks.nvim',
    event = { 'VeryLazy' },
    cond = function()
      local cond = not ar.plugins.minimal
        and ar.config.buffers.variant == 'buffer-sticks'
      return ar.get_plugin_cond('buffer-sticks.nvim', cond)
    end,
    keys = {
      { '<M-space>', function() BufferSticks.jump() end, desc = 'buffers' },
    },
    setup = function()
      require('buffer-sticks').setup({
        highlights = {
          label = { link = 'CursorLineNr' },
          active = { link = 'CursorLineNr' },
          inactive = { link = 'Comment' },
        },
      })
    end,
  },
})
