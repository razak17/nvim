local api = vim.api
local ui = rvim.ui
local codicons = ui.codicons
local border = ui.current.border
local strwidth = vim.api.nvim_strwidth

return {
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
    'j-hui/fidget.nvim',
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
    'stevearc/dressing.nvim',
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
    'folke/todo-comments.nvim',
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
    ft = { 'lua', 'vim', 'typescript', 'typescriptreact', 'javascriptreact', 'svelte', 'astro' },
    keys = { { '<leader>oc', '<cmd>CccHighlighterToggle<CR>', desc = 'toggle ccc' } },
    opts = {
      win_opts = { border = border },
      highlighter = {
        auto_enable = true,
        excludes = { 'dart', 'lazy', 'orgagenda', 'org', 'NeogitStatus', 'toggleterm' },
      },
    },
  },
  {
    'levouh/tint.nvim',
    event = 'WinNew',
    enabled = false,
    opts = {
      tint = -30,
      -- stylua: ignore
      highlight_ignore_patterns = {
        'WinSeparator', 'St.*', 'Comment', 'Panel.*', 'Telescope.*', 'Bqf.*', 'VirtColumn', 'Headline.*', 'NeoTree.*',
      },
      window_ignore_function = function(win_id)
        local win, buf = vim.wo[win_id], vim.bo[vim.api.nvim_win_get_buf(win_id)]
        -- BUG: neotree cannot be ignore rvim either nofile or by filetype rvim this causes tinting bugs
        if win.diff or not rvim.falsy(vim.fn.win_gettype(win_id)) then return true end
        local ignore_bt = rvim.p_table({ terminal = true, prompt = true, nofile = false })
        local ignore_ft = rvim.p_table({ ['Telescope.*'] = true, ['Neogit.*'] = true, ['qf'] = true })
        return ignore_bt[buf.buftype] or ignore_ft[buf.filetype]
      end,
    },
  },
  {
    'kevinhwang91/nvim-ufo',
    event = 'VeryLazy',
    init = function()
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
        top_down = false,
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
