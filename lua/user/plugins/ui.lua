local api = vim.api
local highlight, ui = rvim.highlight, rvim.ui
local codicons = ui.codicons
local border = ui.current.border
local strwidth = vim.api.nvim_strwidth
local separators, decorations = ui.icons.separators, ui.decorations

return {
  {
    'razak17/smartcolumn.nvim',
    event = 'VeryLazy',
    init = function()
      rvim.augroup('SmartCol', {
        event = { 'VimEnter', 'BufEnter', 'WinEnter' },
        command = function(args)
          decorations.set_colorcolumn(
            args.buf,
            function(colorcolumn) require('smartcolumn').setup_buffer({ colorcolumn = colorcolumn }) end
          )
        end,
      })
    end,
    opts = {},
    dependencies = {
      {
        'lukas-reineke/virt-column.nvim',
        event = 'BufReadPre',
        opts = { char = separators.right_thin_block },
      },
    },
  },
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {
      preview = {
        border_chars = { '│', '│', '─', '─', '┌', '┐', '└', '┘', '▊' },
      },
    },
  },
  {
    'kevinhwang91/nvim-hlslens',
    event = 'BufReadPre',
    enabled = not rvim.plugins.minimal,
    opts = {},
    init = function() highlight.plugin('hlslens', { { HlSearchLens = { fg = { from = 'Comment', alter = 0.15 } } } }) end,
    keys = {
      { 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]] },
      { 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]] },
    },
  },
  {
    'stevearc/dressing.nvim',
    enabled = not rvim.plugins.minimal,
    event = 'BufRead',
    opts = {
      input = { insert_only = false, border = border },
      select = {
        telescope = rvim.telescope.adaptive_dropdown(),
        get_config = function() return { backend = 'telescope', telescope = rvim.telescope.cursor() } end,
      },
    },
  },
  {
    'j-hui/fidget.nvim',
    tag = 'legacy',
    enabled = rvim.lsp.enable and not rvim.plugins.minimal,
    event = 'BufReadPre',
    config = function()
      require('fidget').setup({
        align = { bottom = false, right = true },
        fmt = { stack_upwards = false },
      })
      rvim.augroup('CloseFidget', {
        event = { 'VimLeavePre', 'LspDetach' },
        command = 'silent! FidgetClose',
      })
    end,
  },
  {
    'folke/todo-comments.nvim',
    enabled = not rvim.plugins.minimal,
    event = 'BufReadPre',
    cmd = { 'TodoTelescope', 'TodoTrouble', 'TodoQuickFix', 'TodoDots' },
    keys = {
      { '<leader>tt', '<cmd>TodoDots<CR>', desc = 'todo: dotfiles todos' },
      { '<leader>tj', function() require('todo-comments').jump_next() end, desc = 'todo-comments: next todo' },
      { '<leader>tk', function() require('todo-comments').jump_prev() end, desc = 'todo-comments: prev todo' },
    },
    config = function()
      require('todo-comments').setup({ highlight = { after = '' } })
      rvim.command('TodoDots', string.format('TodoTelescope cwd=%s keywords=TODO,FIXME', vim.fn.stdpath('config')))
    end,
  },
  {
    'uga-rosa/ccc.nvim',
    keys = { { '<leader>oc', '<cmd>CccHighlighterToggle<CR>', desc = 'toggle ccc' } },
    opts = function()
      local ccc = require('ccc')
      local p = ccc.picker
      p.hex.pattern = {
        [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)>]=],
        [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)(\x\x)>]=],
      }
      ccc.setup({
        win_opts = { border = border },
        pickers = { p.hex, p.css_rgb, p.css_hsl, p.css_hwb, p.css_lab, p.css_lch, p.css_oklab, p.css_oklch },
        highlighter = {
          auto_enable = true,
          excludes = { 'dart', 'lazy', 'orgagenda', 'org', 'NeogitStatus', 'toggleterm' },
        },
      })
    end,
  },
  {
    'Bekaboo/dropbar.nvim',
    commit = 'b00ede8',
    event = 'VeryLazy',
    enabled = not rvim.plugins.minimal,
    keys = {
      { '<leader>wp', function() require('dropbar.api').pick() end, desc = 'winbar: pick' },
    },
    config = function()
      require('dropbar').setup({
        general = {
          update_interval = 100,
          enable = function(buf, win)
            local b, w = vim.bo[buf], vim.wo[win]
            local decor = ui.decorations.get({ ft = b.ft, bt = b.bt, setting = 'winbar' })
            return decor
              and decor.ft ~= false
              and decor.bt ~= false
              and b.bt == ''
              and not w.diff
              and not api.nvim_win_get_config(win).zindex
              and api.nvim_buf_get_name(buf) ~= ''
          end,
        },
        icons = {
          ui = { bar = { separator = ' ' .. ui.icons.misc.triangle .. ' ' } },
          kinds = { symbols = vim.tbl_map(function(value) return value .. ' ' end, require('lspkind').symbol_map) },
        },
        menu = {
          win_configs = {
            border = border,
            col = function(menu) return menu.prev_menu and menu.prev_menu._win_configs.width + 1 or 0 end,
          },
        },
      })
      rvim.highlight.plugin('dropbar', {
        { DropBarIconUISeparator = { fg = { from = 'Label' } } },
        { DropBarIconUIIndicator = { link = 'Label' } },
        { DropBarMenuHoverEntry = { bg = 'NONE' } },
        { DropBarMenuCurrentContext = { link = 'CursorLine' } },
      })
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    enabled = rvim.treesitter.enable and not rvim.plugins.minimal,
    event = 'BufRead',
    opts = {
      char = separators.left_thin_block,
      show_foldtext = false,
      context_char = separators.left_thin_block,
      char_priority = 12,
      show_current_context = true,
      show_current_context_start = false,
      show_current_context_start_on_current_line = false,
      show_first_indent_level = true,
      filetype_exclude = {
        'dbout',
        'neo-tree-popup',
        'log',
        'gitcommit',
        'txt',
        'help',
        'NvimTree',
        'git',
        'flutterToolsOutline',
        'undotree',
        'markdown',
        'norg',
        'org',
        'orgagenda',
        '', -- for all buffers without a file type
      },
    },
  },
  {
    'kevinhwang91/nvim-ufo',
    enabled = rvim.treesitter.enable,
    event = 'BufRead',
    config = function()
      rvim.highlight.plugin('ufo', {
        { Folded = { bold = false, italic = false, bg = { from = 'CursorLine' } } },
      })
    end,
    keys = {
      { 'zR', function() require('ufo').openAllFolds() end, 'open all folds' },
      { 'zM', function() require('ufo').closeAllFolds() end, 'close all folds' },
      { 'zP', function() require('ufo').peekFoldedLinesUnderCursor() end, 'preview fold' },
    },
    opts = function()
      local ft_map = { rust = 'lsp' }
      require('ufo').setup({
        open_fold_hl_timeout = 0,
        preview = {
          win_config = {
            border = rvim.ui.current.border,
            winhighlight = 'Normal:VertSplit,FloatBorder:VertSplit',
          },
        },
        enable_get_fold_virt_text = true,
        close_fold_kinds = { 'imports', 'comment' },
        provider_selector = function(_, ft) return ft_map[ft] or { 'treesitter', 'indent' } end,
        fold_virt_text_handler = function(virt_text, _, end_lnum, width, truncate, ctx)
          local result, cur_width, padding = {}, 0, ''
          local suffix_width = strwidth(ctx.text)
          local target_width = width - suffix_width

          for _, chunk in ipairs(virt_text) do
            local chunk_text = chunk[1]
            local chunk_width = strwidth(chunk_text)
            if target_width > cur_width + chunk_width then
              table.insert(result, chunk)
            else
              chunk_text = truncate(chunk_text, target_width - cur_width)
              local hl_group = chunk[2]
              table.insert(result, { chunk_text, hl_group })
              chunk_width = strwidth(chunk_text)
              if cur_width + chunk_width < target_width then
                padding = padding .. (' '):rep(target_width - cur_width - chunk_width)
              end
              break
            end
            cur_width = cur_width + chunk_width
          end

          if ft_map[vim.bo[ctx.bufnr].ft] == 'lsp' then
            table.insert(result, { ' ⋯ ', 'UfoFoldedEllipsis' })
            return result
          end

          local end_text = ctx.get_fold_virt_text(end_lnum)
          -- reformat the end text to trim excess whitespace from
          -- indentation usually the first item is indentation
          if end_text[1] and end_text[1][1] then end_text[1][1] = end_text[1][1]:gsub('[%s\t]+', '') end

          vim.list_extend(result, { { ' ⋯ ', 'UfoFoldedEllipsis' }, unpack(end_text) })
          table.insert(result, { padding, '' })
          return result
        end,
      })
    end,
    dependencies = { 'kevinhwang91/promise-async' },
  },
  {
    'rcarriga/nvim-notify',
    event = 'BufRead',
    keys = {
      { '<leader>nn', '<cmd>Notifications<CR>', desc = 'notify: show' },
      {
        '<leader>nx',
        function() require('notify').dismiss({ silent = true, pending = true }) end,
        desc = 'notify: dismiss notifications',
      },
    },
    init = function()
      local notify = require('notify')
      notify.setup({
        max_width = function() return math.floor(vim.o.columns * 0.6) end,
        max_height = function() return math.floor(vim.o.lines * 0.8) end,
        background_colour = 'NormalFloat',
        on_open = function(win)
          if api.nvim_win_is_valid(win) then api.nvim_win_set_config(win, { border = ui.current.border }) end
        end,
        timeout = 70,
        stages = 'fade_in_slide_out',
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

      local ignored = {
        'No information available',
        '[LSP] Format request failed, no matching language servers.',
      }

      vim.notify = function(msg, level, opts)
        if vim.tbl_contains(ignored, msg) then return end
        return notify(msg, level, opts)
      end
    end,
  },
}
