local fn, v, api = vim.fn, vim.v, vim.api
local fmt = string.format

local minimal = ar.plugins.minimal
local sep = ar.ui.icons.separators
local icons, codicons = ar.ui.icons, ar.ui.codicons
local falsy = ar.falsy

--- An `init` function to build multiple update events which is not supported yet by Heirline's update field.
---@param opts any[] an array like table of autocmd events as either just a string or a table with custom patterns and callbacks.
---@return function # The Heirline init function.
-- @usage local heirline_component = { init = require("base.utils.status").init.update_events { "BufEnter", { "User", pattern = "LspProgressUpdate" } } }
local function update_events(opts)
  return function(self)
    if not rawget(self, 'once') then
      local clear_cache = function() self._win_cache = nil end
      for _, event in ipairs(opts) do
        local event_opts = { callback = clear_cache }
        if type(event) == 'table' then
          event_opts.pattern = event.pattern
          event_opts.callback = event.callback or clear_cache
          event.pattern, event.callback = nil, nil
        end
        api.nvim_create_autocmd(event, event_opts)
      end
      self.once = true
    end
  end
end

return {
  desc = 'heirline statusline',
  recommended = true,
  'rebelot/heirline.nvim',
  cond = not minimal,
  opts = function(_, opts)
    local separator = sep.dotted_thin_block
    local statusline = require('ar.statusline')
    local conditions = require('heirline.conditions')
    local is_git_repo = conditions.is_git_repo
    local align = { provider = '%=' }
    local utils = require('heirline.utils')
    local file_block = statusline.file_block

    local bg, fg = 'bg_dark', 'fg'
    local mode_colors = statusline.mode_colors
    return vim.tbl_deep_extend('force', opts or {}, {
      statusline = vim.tbl_deep_extend('force', opts.statusline or {}, {
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
        -- Git Branch
        {
          init = update_events({
            'BufEnter',
            'BufWritePost',
            'FocusGained',
          }),
          provider = function()
            return codicons.git.branch .. ' ' .. statusline.git_branch()
          end,
          on_click = {
            callback = function()
              vim.defer_fn(function() statusline.list_branches() end, 100)
            end,
            name = 'git_change_branch',
          },
          hl = { fg = 'yellowgreen' },
        },
        -- Git
        {
          -- condition = conditions.is_git_repo,
          init = function(self)
            self.status_dict = vim.b.gitsigns_status_dict
            -- statusline.git_remote_sync()
          end,
          update = {
            'User',
            pattern = { 'GitSignsUpdate', 'GitSignsChanged' },
            callback = function() vim.schedule(vim.cmd.redrawstatus) end,
          },
          {
            condition = function() return GitStatus ~= nil end,
            update = { 'User', pattern = 'GitStatusChanged' },
            {
              condition = function() return GitStatus.status == 'pending' end,
              provider = ' ' .. codicons.git.pending,
            },
            {
              provider = function()
                return ' ' .. GitStatus.behind .. icons.misc.arrow_down
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
              provider = function()
                return ' ' .. GitStatus.ahead .. icons.misc.arrow_up
              end,
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
        -- Filename
        utils.insert(
          file_block,
          utils.insert(
            statusline.pretty_path,
            statusline.file_flags,
            statusline.file_size
          )
        ),
        -- Python env
        {
          condition = function() return vim.bo.filetype == 'python' end,
          provider = function() return ' ' .. statusline.python_env() end,
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
          update = { 'LspAttach', 'LspDetach', 'DiagnosticChanged', 'BufEnter' },
          init = function(self)
            local bufnr = api.nvim_get_current_buf()
            if not vim.b[bufnr].is_large_file then
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
            else
              self.errors = 0
              self.warnings = 0
              self.hints = 0
              self.info = 0
            end
          end,
          {
            provider = function(self)
              return self.errors > 0 and (' ' .. self.error_icon .. self.errors)
            end,
            hl = { fg = 'error_red' },
          },
          {
            provider = function(self)
              return self.warnings > 0
                and (' ' .. self.warn_icon .. self.warnings)
            end,
            hl = { fg = 'dark_orange' },
          },
          {
            provider = function(self)
              return self.info > 0 and (' ' .. self.info_icon .. self.info)
            end,
            hl = { fg = 'blue' },
          },
          {
            provider = function(self)
              return self.hints > 0 and (' ' .. self.hint_icon .. self.hints)
            end,
            hl = { fg = 'forest_green' },
          },
          on_click = {
            callback = function()
              vim.defer_fn(ar.pick('diagnostics_buffer'), 100)
            end,
            name = 'lsp_diagnostics',
          },
        },
        align,
        -- LSP
        {
          init = function() statusline.autocmds() end,
          condition = function() return not minimal and ar.lsp.enable end,
          -- LSP Progress
          {
            provider = function() return statusline.lsp_progress end,
            hl = { fg = 'comment' },
          },
          -- LSP Pending Requests
          {
            condition = function() return statusline.lsp_progress == '' end,
            provider = function() return statusline.lsp_pending end,
            hl = { fg = 'comment' },
          },
        },
        align,
        -- Noice Status
        {
          condition = function()
            return ar.is_available('noice.nvim')
              ---@diagnostic disable-next-line: undefined-field
              and require('noice').api.status.command.has()
          end,
          provider = function()
            ---@diagnostic disable-next-line: undefined-field
            local noice_cmd = require('noice').api.status.command.get()
            return noice_cmd or ''
          end,
          hl = { fg = 'blue' },
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
        -- Debug
        -- {
        --   condition = function()
        --     if not ar.is_available('nvim-dap') then return false end
        --     local session = require('dap').session()
        --     return session ~= nil
        --   end,
        --   provider = function()
        --     return codicons.misc.bug_alt
        --       .. ' '
        --       .. require('dap').status()
        --       .. ' '
        --   end,
        --   hl = { fg = 'red' },
        --   {
        --     provider = ' ',
        --     on_click = {
        --       callback = function() require('dap').step_into() end,
        --       name = 'heirline_dap_step_into',
        --     },
        --   },
        --   { provider = ' ' },
        --   {
        --     provider = ' ',
        --     on_click = {
        --       callback = function() require('dap').step_out() end,
        --       name = 'heirline_dap_step_out',
        --     },
        --   },
        --   { provider = ' ' },
        --   {
        --     provider = ' ',
        --     on_click = {
        --       callback = function() require('dap').step_over() end,
        --       name = 'heirline_dap_step_over',
        --     },
        --   },
        --   { provider = ' ' },
        --   {
        --     provider = ' ',
        --     hl = { fg = 'green' },
        --     on_click = {
        --       callback = function() require('dap').run_last() end,
        --       name = 'heirline_dap_run_last',
        --     },
        --   },
        --   { provider = ' ' },
        --   {
        --     provider = ' ',
        --     hl = { fg = 'red' },
        --     on_click = {
        --       callback = function()
        --         require('dap').terminate()
        --         require('dapui').close({})
        --       end,
        --       name = 'heirline_dap_close',
        --     },
        --   },
        --   --       ﰇ  
        -- },
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
        -- cloc
        {
          update = { 'User', pattern = 'ClocStatusUpdated' },
          condition = function() return ar.is_available('cloc.nvim') end,
          provider = function(_)
            local status = require('cloc').get_status()
            if status.statusCode == 'loading' then return 'Clocing...' end
            if status.statusCode == 'error' then return 'Error' end
            return ' ' .. status.data[1].code
          end,
        },
        -- Word Count
        {
          condition = function() return vim.bo.filetype == 'markdown' end,
          provider = statusline.word_count,
        },
        -- LSP Clients (null-ls)
        {
          condition = function()
            return conditions.lsp_attached and ar_config.lsp.null_ls.enable
          end,
          update = { 'LspAttach', 'LspDetach', 'WinEnter', 'BufEnter' },
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
          update = { 'LspAttach', 'LspDetach', 'WinEnter', 'BufEnter' },
          condition = function()
            return conditions.lsp_attached and not ar_config.lsp.null_ls.enable
          end,
          init = function(self)
            local curwin = api.nvim_get_current_win()
            local curbuf = api.nvim_win_get_buf(curwin)
            self.active = true
            self.clients = vim.lsp.get_clients({ bufnr = curbuf })
            self.clients = vim.tbl_filter(
              function(client) return client.name ~= 'copilot' end,
              self.clients
            )
            if falsy(self.clients) then self.active = false end
            self.linters = statusline.get_linters()
            self.formatters = statusline.get_formatters(curbuf)
          end,
          {
            update = { 'LspAttach', 'LspDetach', 'WinEnter', 'BufEnter' },
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
              if #self.client_names > 1 then
                -- return ' ' .. table.concat(self.client_names, ', ') .. separator
                return ' '
                  .. fmt('%s +%d', self.client_names[1], #self.client_names - 1)
                  .. separator
              end
              return ' ' .. self.servers
            end,
            hl = { bold = true },
            on_click = {
              callback = function()
                vim.defer_fn(function() vim.cmd('LspInfo') end, 100)
              end,
              name = 'lsp_clients',
            },
          },
          {
            update = { 'LspAttach', 'LspDetach', 'WinEnter', 'BufEnter' },
            condition = function(self) return not ar.falsy(self.linters) end,
            provider = function(self) return ' ' .. self.linters end,
            hl = { bold = true },
          },
          {
            update = { 'LspAttach', 'LspDetach', 'WinEnter', 'BufEnter' },
            condition = function(self) return not ar.falsy(self.formatters) end,
            provider = function(self) return ' ' .. self.formatters end,
            hl = { bold = true },
            on_click = {
              callback = function()
                vim.defer_fn(function() vim.cmd('ConformInfo') end, 100)
              end,
              name = 'formatters',
            },
          },
        },
        -- Ecolog Status
        {
          cond = function()
            return not minimal
              and ar_config.shelter.enable
              and ar_config.shelter.variant == 'ecolog'
          end,
          init = function(self)
            local ecolog_utils = require('ecolog.utils')
            local shelter = ecolog_utils.get_module('ecolog.shelter')
            self.shelter_active = shelter.is_enabled('files')
          end,
          {
            provider = function(self)
              local icon = self.shelter_active and '' or '🌲'
              return ' ' .. icon
            end,
            hl = function(self)
              if self.shelter_active then
                return { fg = 'blue', bold = true }
              end
              return { fg = 'comment', bold = true }
            end,
          },
          { provider = ' ' .. separator, hl = { bold = true } },
        },
        -- Copilot Status
        {
          condition = function()
            return not minimal and ar.ai.enable and ar_config.ai.models.copilot
          end,
          init = function(self)
            self.processing = false
            local status = statusline.copilot_status()
            -- local status = statusline.copilot_indicator()
            if status == 'pending' then self.processing = true end
          end,
          {
            provider = ' ' .. codicons.misc.copilot,
            hl = function(self)
              return self.processing and { fg = 'yellow', bold = true }
                or { fg = 'comment', bold = true }
            end,
            on_click = {
              callback = function()
                vim.defer_fn(function() vim.cmd('copilot panel') end, 100)
              end,
              name = 'copilot_status',
            },
          },
          { provider = ' ' .. separator, hl = { bold = true } },
        },
        -- CodeCompanion
        {
          cond = function() return not minimal and ar.ai.enable end,
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
              local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc -- :h 'enc'
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
          condition = function() return vim.wo.spell and false end,
          provider = function() return ' ' .. icons.misc.spell_check end,
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
            local line_number = fn.line('.')
            if line_number > 99 then
              return '  ' .. '%7(%l/%3L%):%2c ' .. statusline.progress()
            elseif line_number > 9 then
              return ' ' .. '%7(%l/%3L%):%2c ' .. statusline.progress()
            end
            return '%7(%l/%3L%):%2c ' .. statusline.progress()
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
      }),
    })
  end,
}
