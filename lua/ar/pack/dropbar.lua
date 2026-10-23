local fmt = string.format
local ui, highlight = ar.ui, ar.highlight
local border = ui.current.border.default
local decor = ui.decorations

ar.pack.add({
  {
    src = 'https://github.com/Bekaboo/dropbar.nvim',
    event = { 'BufRead', 'BufNewFile' },
    cond = function()
      local condition = ar.config.ui.winbar.enable
        and ar.config.ui.winbar.variant == 'dropbar'
      return ar.get_plugin_cond('dropbar.nvim', condition)
    end,
    keys = {
      {
        '<leader>wo',
        function() require('dropbar.api').pick() end,
        desc = 'winbar: pick',
      },
    },
    setup = function()
      local function build_fzf(path)
        local result = vim
          .system({ 'make' }, { cwd = path, text = true })
          :wait()
        if result.code ~= 0 then
          error('fzf build failed: ' .. (result.stderr or ''))
        end
      end
      ar.pack.add({
        src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
        lazy = false,
        build = function(event) build_fzf(event.data.path) end,
      })
      local fzf = vim.pack.get({ 'telescope-fzf-native.nvim' })[1]
      if fzf and vim.fn.glob(fzf.path .. '/build/libfzf.*') == '' then
        build_fzf(fzf.path)
      end
      local function get_opts()
        local symbol_map = require('lspkind').symbol_map

        return {
          bar = {
            update_interval = 0,
            attach_events = {
              'OptionSet',
              'BufWinEnter',
              'BufWritePost',
              'BufEnter',
              'FileType',
            },
            enable = function(buf, win)
              local b, w = vim.bo[buf], vim.wo[win]
              local decs =
                decor.get({ ft = b.ft, bt = b.bt, setting = 'winbar' })
              local bufname = vim.api.nvim_buf_get_name(buf)
              local is_diffview = vim.startswith(bufname, 'diffview://')

              local show = false
              if not decs or ar.falsy(decs) or is_diffview then
                show = true
              else
                show = decs.ft == true or decs.bt == true
              end
              if not show then
                vim.opt_local.winbar = ''
                return false
              end
              return show
                and b.bt == ''
                and not w.diff
                and not vim.api.nvim_win_get_config(win).zindex
                and vim.api.nvim_buf_get_name(buf) ~= ''
            end,
          },
          icons = {
            ui = {
              bar = { separator = fmt(' %s ', ui.icons.misc.chevron_right) },
            },
            kinds = {
              symbols = vim.tbl_map(
                function(value) return value .. ' ' end,
                symbol_map
              ),
            },
          },
          menu = {
            win_configs = {
              border = border,
              col = function(menu)
                return menu.prev_menu and menu.prev_menu._win_configs.width + 1
                  or 0
              end,
            },
          },
        }
      end
      local opts = get_opts()
      require('dropbar').setup(opts)
      highlight.plugin('dropbar', {
        theme = {
          ['onedark'] = {
            { DropBarIconUISeparator = { fg = { from = 'Label' } } },
            { DropBarIconUIIndicator = { link = 'Label' } },
            { DropBarHover = { link = 'CursorLine' } },
            { DropBarMenuHoverEntry = { link = 'CursorLine' } },
            { DropBarMenuCurrentContext = { link = 'CursorLine' } },
          },
        },
      })
    end,
    dependencies = { { src = 'https://github.com/razak17/lspkind.nvim' } },
  },
})
