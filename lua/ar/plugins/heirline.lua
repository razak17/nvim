local fn, v, api, cmd = vim.fn, vim.v, vim.api, vim.cmd
local bo, o, wo = vim.bo, vim.o, vim.wo
local sep = ar.ui.icons.separators
local icons, codicons = ar.ui.icons, ar.ui.codicons
local decor = ar.ui.decorations
local falsy = ar.falsy
local fmt = string.format

local buftypes = {
  'nofile',
  'prompt',
  'help',
  'quickfix',
}

-- Filetypes which force the statusline to be inactive
local force_inactive_filetypes = {
  '^aerial$',
  '^alpha$',
  '^chatgpt$',
  '^DressingInput$',
  '^frecency$',
  '^lazy$',
  '^lazyterm$',
  '^netrw$',
  '^oil$',
  '^TelescopePrompt$',
  '^undotree$',
}

local function setup_colors()
  local P = require('onedark.palette')
  return P
end

ar.augroup('Heirline', {
  event = 'ColorScheme',
  command = function()
    if not ar.is_available('heirline.nvim') then return end
    local utils = require('heirline.utils')
    utils.on_colorscheme(setup_colors)
  end,
})

return {
  {
    'rebelot/heirline.nvim',
    event = 'BufWinEnter',
    cond = not ar.plugins.minimal,
    opts = { colors = setup_colors },
    config = function(_, opts)
      local separator = sep.dotted_thin_block
      local statusline = require('ar.statusline')
      local conditions = require('heirline.conditions')
      local is_git_repo = conditions.is_git_repo
      local utils = require('heirline.utils')
      local align = { provider = '%=' }

      local bg, fg = 'bg_dark', 'fg'
      local mode_colors = statusline.mode_colors
      local file_block = statusline.file_block

      opts.statusline = {
        condition = function()
          local win = api.nvim_get_current_win()
          local buf = api.nvim_win_get_buf(win)
          local decs = decor.get({
            ft = bo[buf].ft,
            fname = fn.bufname(buf),
            setting = 'statusline',
          })
          if not decs or ar.falsy(decs) then
            return not conditions.buffer_matches({
              buftype = buftypes,
              filetype = force_inactive_filetypes,
            })
          end
          return decs.ft == true or decs.fname == true
        end,
        hl = { bg = bg, fg = fg },
        -- Mode
        {
          init = function(self)
            self.mode = vim.fn.mode(1)
            self.mode_color = mode_colors[self.mode:sub(1, 1)]
          end,
          update = {
            'ModeChanged',
            pattern = '*:*',
            callback = vim.schedule_wrap(
              function() vim.cmd('redrawstatus') end
            ),
          },
          {
            provider = function() return statusline.block() .. ' ' end,
            hl = function(self) return { fg = self.mode_color } end,
          },
        },
        -- Git
        {
          condition = function() return is_git_repo() end,
          init = function(self) self.status_dict = vim.b.gitsigns_status_dict end,
          {
            {
              provider = function(self)
                if self.status_dict then
                  return codicons.git.branch
                    .. ' '
                    .. (self.status_dict.head == '' and 'main' or self.status_dict.head)
                    .. ' '
                end
              end,
              on_click = {
                callback = function() statusline.list_branches() end,
                name = 'git_change_branch',
              },
              hl = { fg = 'yellowgreen' },
            },
            {
              condition = function()
                return (
                  GitStatus ~= nil
                  and (GitStatus.ahead ~= 0 or _G.GitStatus.behind ~= 0)
                )
              end,
              update = { 'User', pattern = 'GitStatusChanged' },
              {
                condition = function() return GitStatus.status == 'pending' end,
                provider = codicons.git.pending,
              },
              {
                provider = function()
                  return GitStatus.behind .. icons.arrow_down
                end,
                hl = function()
                  return {
                    fg = GitStatus.behind == 0 and fg or 'pale_red',
                  }
                end,
                on_click = {
                  callback = function()
                    if GitStatus.behind > 0 then statusline.git_pull() end
                  end,
                  name = 'git_pull',
                },
              },
              {
                provider = function() return GitStatus.ahead .. icons.arrow_up end,
                hl = function()
                  return {
                    fg = GitStatus.ahead == 0 and fg or 'yellowgreen',
                  }
                end,
                on_click = {
                  callback = function()
                    if _G.GitStatus.ahead > 0 then statusline.git_push() end
                  end,
                  name = 'git_push',
                },
              },
            },
          },
        },
        -- Filename
        utils.insert(
          file_block,
          utils.insert(
            statusline.file_name,
            statusline.file_flags,
            statusline.file_size
          )
        ),
        -- Python env
        {
          condition = function() return vim.bo.filetype == 'python' end,
          provider = function() return statusline.python_env() .. ' ' end,
          hl = { fg = 'yellowgreen' },
        },
        -- LSP Diagnostics
        {
          condition = conditions.has_diagnostics,
          static = {
            error_icon = codicons.lsp.error .. ' ',
            warn_icon = codicons.lsp.warn .. ' ',
            hint_icon = codicons.lsp.hint .. ' ',
            info_icon = codicons.lsp.info .. ' ',
          },
          update = { 'LspAttach', 'DiagnosticChanged', 'BufEnter' },
          init = function(self)
            self.errors = #vim.diagnostic.get(
              0,
              { severity = vim.diagnostic.severity.ERROR }
            )
            self.warnings = #vim.diagnostic.get(
              0,
              { severity = vim.diagnostic.severity.WARN }
            )
            self.hints = #vim.diagnostic.get(
              0,
              { severity = vim.diagnostic.severity.HINT }
            )
            self.info = #vim.diagnostic.get(
              0,
              { severity = vim.diagnostic.severity.INFO }
            )
          end,
          {
            provider = function(self)
              return self.errors > 0 and (self.error_icon .. self.errors .. ' ')
            end,
            hl = { fg = 'error_red' },
          },
          {
            provider = function(self)
              return self.warnings > 0
                and (self.warn_icon .. self.warnings .. ' ')
            end,
            hl = { fg = 'dark_orange' },
          },
          {
            provider = function(self)
              return self.info > 0 and (self.info_icon .. self.info .. ' ')
            end,
            hl = { fg = 'blue' },
          },
          {
            provider = function(self)
              return self.hints > 0 and (self.hint_icon .. self.hints .. ' ')
            end,
            hl = { fg = 'forest_green' },
          },
          on_click = {
            callback = function()
              require('telescope.builtin').diagnostics({
                layout_strategy = 'center',
                bufnr = 0,
              })
            end,
            name = 'lsp_diagnostics',
          },
        },
        align,
        -- Debug
        {
          condition = function()
            local session = require('dap').session()
            return session ~= nil
          end,
          provider = function()
            return codicons.misc.bug_alt
              .. ' '
              .. require('dap').status()
              .. ' '
          end,
          hl = { fg = 'red' },
          {
            provider = ' ',
            on_click = {
              callback = function() require('dap').step_into() end,
              name = 'heirline_dap_step_into',
            },
          },
          { provider = ' ' },
          {
            provider = ' ',
            on_click = {
              callback = function() require('dap').step_out() end,
              name = 'heirline_dap_step_out',
            },
          },
          { provider = ' ' },
          {
            provider = ' ',
            on_click = {
              callback = function() require('dap').step_over() end,
              name = 'heirline_dap_step_over',
            },
          },
          { provider = ' ' },
          {
            provider = ' ',
            hl = { fg = 'green' },
            on_click = {
              callback = function() require('dap').run_last() end,
              name = 'heirline_dap_run_last',
            },
          },
          { provider = ' ' },
          {
            provider = ' ',
            hl = { fg = 'red' },
            on_click = {
              callback = function()
                require('dap').terminate()
                require('dapui').close({})
              end,
              name = 'heirline_dap_close',
            },
          },
          --       ﰇ  
        },
        -- Package Info
        {
          condition = function() return fn.expand('%') == 'package.json' end,
          provider = statusline.package_info,
          hl = { fg = 'comment' },
          on_click = {
            callback = function() require('package_info').toggle() end,
            name = 'update_plugins',
          },
        },
        -- Git Diff
        {
          condition = is_git_repo,
          init = function(self)
            self.status_dict = vim.b.gitsigns_status_dict
            self.has_changes = self.status_dict.added ~= 0
              or self.status_dict.removed ~= 0
              or self.status_dict.changed ~= 0
          end,
          hl = { fg = 'dark_orange' },
          {
            provider = function(self)
              local count = self.status_dict.added or 0
              return count > 0 and (' ' .. codicons.git.added .. ' ' .. count)
            end,
            hl = { fg = 'yellowgreen' },
          },
          {
            provider = function(self)
              local count = self.status_dict.removed or 0
              return count > 0 and (' ' .. codicons.git.removed .. ' ' .. count)
            end,
            hl = { fg = 'error_red' },
          },
          {
            provider = function(self)
              local count = self.status_dict.changed or 0
              return count > 0 and (' ' .. codicons.git.mod .. ' ' .. count)
            end,
            hl = { fg = 'dark_orange' },
          },
          on_click = {
            callback = function()
              vim.defer_fn(function() vim.cmd('Neogit') end, 100)
            end,
            name = 'git diff',
          },
        },
        -- Lazy
        {
          provider = statusline.lazy_updates,
          hl = { fg = 'dark_orange' },
          on_click = {
            callback = function() require('lazy').update() end,
            name = 'update_plugins',
          },
        },
        -- Search Matches
        {
          condition = function() return v.hlsearch ~= 0 end,
          init = function(self)
            local ok, search = pcall(vim.fn.searchcount)
            if ok and search.total then self.search = search end
          end,
          {
            provider = function(self)
              local search = self.search
              return ' '
                .. string.format(
                  ' %d/%d ',
                  search.current,
                  math.min(search.total, search.maxcount)
                )
            end,
          },
        },
        -- Word Count
        {
          condition = function() return vim.bo.filetype == 'markdown' end,
          provider = statusline.word_count,
        },
        -- LSP Clients (null-ls)
        {
          condition = function()
            return conditions.lsp_attached and ar.lsp.null_ls.enable
          end,
          update = { 'LspAttach', 'LspDetach', 'WinEnter' },
          provider = function() return ' ' .. statusline.lsp_client_names() end,
          hl = { bold = true },
          on_click = {
            callback = function()
              vim.defer_fn(function() vim.cmd('LspInfo') end, 100)
            end,
            name = 'lsp_clients',
          },
        },
        -- LSP Clients (conform,nvim-lint)
        {
          condition = function()
            return conditions.lsp_attached and not ar.lsp.null_ls.enable
          end,
          init = function(self)
            local curwin = api.nvim_get_current_win()
            local curbuf = api.nvim_win_get_buf(curwin)
            self.active = true
            self.clients = vim.lsp.get_clients({ bufnr = curbuf })
            local copilot = vim.tbl_filter(
              function(client) return client.name == 'copilot' end,
              self.clients
            )
            self.copilot = copilot[1]
            if self.copilot ~= nil then
              self.copilot.requests = copilot[1].requests
            end
            self.clients = vim.tbl_filter(
              function(client) return client.name ~= 'copilot' end,
              self.clients
            )
            if falsy(self.clients) then self.active = false end
            self.linters = statusline.get_linters()
            self.formatters = statusline.get_formatters(curbuf)
          end,
          {
            update = { 'LspAttach', 'LspDetach', 'WinEnter' },
            init = function(self)
              if self.active then
                local lsp_servers = vim.tbl_map(
                  function(client) return { name = client.name } end,
                  self.clients
                )
                self.client_names = vim
                  .iter(ipairs(lsp_servers))
                  :map(function(_, c) return c.name end)
                  :totable()
                self.servers = codicons.misc.disconnect
                  .. ' '
                  .. table.concat(self.client_names, fmt('%s ', separator))
                  .. separator
              end
            end,
            provider = function(self)
              if not self.active then
                return ' '
                  .. codicons.misc.disconnect
                  .. ' No Active LSP '
                  .. separator
              end
              if #self.client_names > 2 then
                return ' '
                  .. self.client_names[1]
                  .. ' and 2 others'
                  .. separator
              end
              return ' ' .. self.servers
            end,
            hl = { bold = true },
          },
          {
            update = { 'LspAttach', 'LspDetach', 'WinEnter' },
            condition = function(self) return self.active end,
            provider = function(self)
              if not ar.falsy(self.linters) then return ' ' .. self.linters end
            end,
            hl = { bold = true },
          },
          {
            update = { 'LspAttach', 'LspDetach', 'WinEnter' },
            condition = function(self) return self.active end,
            provider = function(self)
              if not ar.falsy(self.formatters) then
                return ' ' .. self.formatters
              end
            end,
            hl = { bold = true },
            on_click = {
              callback = function()
                vim.defer_fn(function() vim.cmd('ConformInfo') end, 100)
              end,
              name = 'formatters',
            },
          },
          -- Copilot Status
          {
            {
              init = function(self)
                self.processing = false
                if self.copilot ~= nil then
                  if not vim.tbl_isempty(self.copilot.requests) then
                    self.processing = true
                  end
                end
              end,
              provider = ' ' .. codicons.misc.copilot,
              hl = function(self)
                if self.processing then
                  return { fg = 'forest_green', bold = true }
                end
                return { fg = 'comment', bold = true }
              end,
              on_click = {
                callback = function()
                  vim.defer_fn(function() vim.cmd('copilot status') end, 100)
                end,
                name = 'copilot_attached',
              },
            },
            { provider = ' ' .. separator, hl = { bold = true } },
          },
        },
        -- CodeCompanion
        {
          static = { processing = false },
          update = {
            'User',
            pattern = 'CodeCompanionRequest*',
            callback = function(self, args)
              if args.match == 'CodeCompanionRequestStarted' then
                self.processing = true
              elseif args.match == 'CodeCompanionRequestFinished' then
                self.processing = false
              end
              vim.cmd('redrawstatus')
            end,
          },
          {
            provider = ' ' .. codicons.misc.robot_alt,
            hl = function(self)
              if self.processing then return { fg = 'yellow', bold = true } end
              return { fg = 'comment', bold = true }
            end,
          },
          { provider = ' ' .. separator, hl = { bold = true } },
        },
        -- Kulala env
        {
          condition = function() return vim.bo.ft == 'http' end,
          {
            provider = function()
              local CONFIG = require('kulala.config')
              local env = vim.g.kulala_selected_env or CONFIG.get().default_env
              if not env then return '' end
              return ' ' .. icons.misc.right_arrow .. ' ' .. env
            end,
          },
          {
            provider = ' ' .. separator,
            hl = { bold = true },
          },
        },
        -- Copilot Status
        {
          condition = function()
            return ar.ai.enable
              and not ar.plugins.minimal
              and ar.lsp.null_ls.enable
          end,
          init = function(self)
            self.processing = false
            local status = statusline.copilot_indicator()
            if status == 'working' then self.processing = true end
          end,
          {
            provider = ' ' .. codicons.misc.copilot,
            hl = function(self)
              if self.processing then
                return { fg = 'forest_green', bold = true }
              end
              return { fg = 'comment', bold = true }
            end,
            on_click = {
              callback = function()
                vim.defer_fn(function() cmd('copilot panel') end, 100)
              end,
              name = 'copilot_status',
            },
          },
          { provider = ' ' .. separator, hl = { bold = true } },
        },
        -- File Type
        utils.insert(file_block, statusline.file_icon, statusline.file_type),
        -- Buffers
        {
          condition = function()
            return ar.is_available('buffalo.nvim') and false
          end,
          provider = function()
            local buffers = require('buffalo').buffers()
            local tabpages = require('buffalo').tabpages()
            return codicons.misc.buffers
              .. buffers
              .. codicons.misc.tabs
              .. tabpages
          end,
          hl = { fg = 'yellow' },
        },
        -- File Encoding
        {
          condition = function(self)
            return not conditions.buffer_matches({
              filetype = self.filetypes,
            }) and false
          end,
          {
            provider = function()
              local enc = (bo.fenc ~= '' and bo.fenc) or o.enc -- :h 'enc'
              return ' ' .. enc
            end,
          },
        },
        -- Formatting
        {
          condition = function()
            local curwin = api.nvim_get_current_win()
            local curbuf = api.nvim_win_get_buf(curwin)
            return vim.b[curbuf].formatting_disabled == true
              or vim.g.formatting_disabled == true
          end,
          provider = function() return '  ' .. codicons.misc.shaded_lock end,
          hl = { fg = 'blue', bold = true },
        },
        -- Spell
        {
          condition = function() return vim.wo.spell end,
          provider = function() return '  ' .. icons.misc.spell_check end,
          hl = { fg = 'blue' },
        },
        -- Treesitter
        {
          condition = function() return ar.treesitter.enable and false end,
          provider = function() return '  ' .. statusline.ts_active() end,
          hl = { fg = 'forest_green' },
        },
        -- Session
        {
          update = { 'User', pattern = 'PersistedStateChange' },
          {
            condition = function(self)
              return not conditions.buffer_matches({
                filetype = self.filetypes,
              }) and false
            end,
            {
              provider = function()
                if vim.g.persisting then
                  return codicons.misc.cloud_check
                else
                  return codicons.misc.cloud_outline
                end
              end,
              hl = { fg = 'blue' },
              on_click = {
                callback = function() vim.cmd('SessionToggle') end,
                name = 'toggle_session',
              },
            },
          },
        },
        -- Macro
        {
          condition = function()
            return fn.reg_recording() ~= '' or fn.reg_executing() ~= ''
          end,
          update = { 'RecordingEnter', 'RecordingLeave' },
          {
            init = function(self)
              self.rec = fn.reg_recording()
              self.exec = fn.reg_executing()
            end,
            provider = function(self)
              if not ar.falsy(self.rec) then
                return '  ' .. icons.misc.dot_alt .. ' ' .. 'REC'
              end
              if not ar.falsy(self.exec) then
                return '  ' .. icons.misc.play .. ' ' .. 'PLAY'
              end
            end,
            hl = { fg = 'red' },
          },
        },
        -- Ruler
        {
          provider = function()
            return '  %7(%l/%3L%):%2c ' .. statusline.progress()
          end,
        },
        -- Scroll Bar
        {
          init = function(self)
            self.mode = fn.mode(1)
            self.mode_color = mode_colors[self.mode:sub(1, 1)]
          end,
          provider = function()
            local current_line = fn.line('.')
            local total_lines = fn.line('$')
            local chars = icons.scrollbars.thin
            local line_ratio = current_line / total_lines
            local index = math.ceil(line_ratio * #chars)
            return ' ' .. chars[index]
          end,
          hl = function(self) return { fg = self.mode_color } end,
        },
      }

      local statuscol = require('ar.statuscolumn')
      local space = statuscol.space
      local spacer = { provider = space(), hl = 'HeirlineStatusColumn' }
      local shade = sep.light_shade_block

      opts.statuscolumn = {
        condition = function()
          if not ar.ui.statuscolumn.enable or ar.ui.statuscolumn.custom then
            return false
          end
          local win = api.nvim_get_current_win()
          local buf = api.nvim_win_get_buf(win)
          local decs = decor.get({
            ft = bo[buf].ft,
            fname = fn.bufname(buf),
            setting = 'statuscolumn',
          })
          if not decs or ar.falsy(decs) then
            return not conditions.buffer_matches({
              buftype = buftypes,
              filetype = force_inactive_filetypes,
            })
          end
          return decs.ft == true or decs.fname == true
        end,
        static = {
          click_args = function(self, minwid, clicks, button, mods)
            local args = {
              minwid = minwid,
              clicks = clicks,
              button = button,
              mods = mods,
              mousepos = fn.getmousepos(),
            }
            local sign =
              fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
            if sign == ' ' then
              sign = fn.screenstring(
                args.mousepos.screenrow,
                args.mousepos.screencol - 1
              )
            end
            args.sign = self.signs[sign]
            api.nvim_set_current_win(args.mousepos.winid)
            api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })

            return args
          end,
          handlers = {},
        },
        init = function(self)
          self.signs = {}

          self.handlers.signs = function(_)
            return vim.schedule(vim.diagnostic.open_float)
          end

          self.handlers.line_number = function(_)
            local dap_avail, dap = pcall(require, 'dap')
            if dap_avail then vim.schedule(dap.toggle_breakpoint) end
          end

          self.handlers.git_signs = function(_)
            local gitsigns_avail, gitsigns = pcall(require, 'gitsigns')
            if gitsigns_avail then vim.schedule(gitsigns.preview_hunk) end
          end

          self.handlers.fold = function(args)
            local lnum = args.mousepos.line
            if fn.foldlevel(lnum) <= fn.foldlevel(lnum - 1) then return end
            cmd.execute(
              "'"
                .. lnum
                .. 'fold'
                .. (fn.foldclosed(lnum) == -1 and 'close' or 'open')
                .. "'"
            )
          end
        end,
        {
          init = function(self)
            local lnum, relnum, virtnum = v.lnum, v.relnum, v.virtnum
            local win = api.nvim_get_current_win()
            local buf = api.nvim_win_get_buf(win)
            local line_count = api.nvim_buf_line_count(buf)

            self.ln = statuscol.nr(win, lnum, relnum, virtnum, line_count)
            self.left, self.g_sns = statuscol.get_left(buf, lnum)
            self.no = wo[win].signcolumn == 'no'
          end,
          -- Signs
          {
            provider = function(self) return self.no and '' or self.left end,
            on_click = {
              name = 'sign_click',
              callback = function(self, ...)
                if self.handlers.signs then
                  self.handlers.signs(self.click_args(self, ...))
                end
              end,
            },
          },
          align,
          spacer,
          -- Line numbers
          {
            provider = function(self) return self.ln end,
            on_click = {
              name = 'line_number_click',
              callback = function(self, ...)
                if self.handlers.line_number then
                  self.handlers.line_number(self.click_args(self, ...))
                end
              end,
            },
          },
          spacer,
          -- Git signs
          {
            {
              condition = function() return not is_git_repo() or v.virtnum ~= 0 end,
              provider = space(),
              hl = 'HeirlineStatusColumn',
            },
            {
              condition = function() return is_git_repo() and v.virtnum == 0 end,
              init = function(self)
                if #self.g_sns == 0 then
                  self.gitsign = nil
                else
                  self.gitsign = unpack(self.g_sns)
                end
                self.has_gitsign = self.gitsign ~= nil
              end,
              provider = function(self)
                if self.has_gitsign then return self.gitsign.text end
                return space()
              end,
              hl = function(self)
                if self.has_gitsign then return self.gitsign.texthl end
                return 'HeirlineStatusColumn'
              end,
              on_click = {
                name = 'gitsigns_click',
                callback = function(self, ...)
                  if self.handlers.git_signs then
                    self.handlers.git_signs(self.click_args(self, ...))
                  end
                end,
              },
            },
          },
          -- Virtual lines
          {
            init = function(self)
              self.is_wrap = self.ln:gsub('^%s*(.-)%s*$', '%1') == ''
              self.is_shade = self.ln:gsub('^%s*(.-)%s*$', '%1') == shade
            end,
            provider = function(self)
              if self.is_shade then return '' end
              if not self.is_wrap then return sep.left_thin_block end
              return ''
            end,
            hl = 'IndentBlanklineChar',
          },
          -- Folds
          {
            condition = function() return v.virtnum == 0 end,
            init = function(self) self.fold = statuscol.get_fold(v.lnum) end,
            {
              provider = function(self) return self.fold.text end,
              hl = function(self) return self.fold.texthl end,
            },
            on_click = {
              name = 'fold_click',
              callback = function(self, ...)
                if self.handlers.fold then
                  self.handlers.fold(self.click_args(self, ...))
                end
              end,
            },
            spacer,
          },
        },
      }

      require('heirline').setup(opts)
    end,
  },
}
