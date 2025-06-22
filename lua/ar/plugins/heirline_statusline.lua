local fn, v, api = vim.fn, vim.v, vim.api

local is_avail = ar.is_available
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
  cond = function() return ar.get_plugin_cond('heirline.nvim', not minimal) end,
  opts = function(_, opts)
    local separator = sep.dotted_thin_block
    local stl = require('ar.statusline')
    local conditions = require('heirline.conditions')
    local is_git_repo = conditions.is_git_repo
    local align = { provider = '%=' }
    local utils = require('heirline.utils')
    local file_block = stl.file_block

    local mode_colors = stl.mode_colors

    local vim_mode = {
      init = function(self)
        self.mode = fn.mode(1)
        self.mode_color = mode_colors[self.mode:sub(1, 1)]
      end,
      update = {
        'ModeChanged',
        pattern = '*:*',
        callback = vim.schedule_wrap(function() vim.cmd('redrawstatus') end),
      },
      {
        provider = function() return stl.block() .. ' ' end,
        hl = function(self) return { fg = self.mode_color } end,
      },
    }

    local mason_statusline = {
      condition = function() return vim.bo.filetype == 'mason' end,
      vim_mode,
      { provider = 'Mason', bold = true },
      {
        condition = function() return is_avail('mason.nvim') end,
        init = function(self)
          self.mason_registry = nil
          local ok, registry = pcall(require, 'mason-registry')
          if ok then self.mason_registry = registry end
        end,
        {
          condition = function(self) return self.mason_registry ~= nil end,
          provider = function(self)
            return ' Installed: '
              .. #self.mason_registry.get_installed_packages()
              .. '/'
              .. #self.mason_registry.get_all_package_specs()
          end,
          hl = { fg = 'comment' },
        },
      },
      align,
    }

    local explorer_statusline = {
      condition = function()
        local filetypes = {
          '^neo--tree$',
          'snacks_picker_list',
        }
        return conditions.buffer_matches({ filetype = filetypes })
      end,
      vim_mode,
      {
        provider = function() return fn.fnamemodify(fn.getcwd(), ':~') end,
        hl = { fg = 'blue' },
      },
      align,
    }

    local help_statusline = {
      condition = function() return vim.bo.buftype == 'help' end,
      vim_mode,
      stl.root_dir(),
      utils.insert(utils.insert(stl.pretty_path, stl.file_flags)),
      align,
    }

    local lazy_statusline = {
      condition = function() return vim.bo.filetype == 'lazy' end,
      vim_mode,
      { provider = 'lazy', hl = { fg = 'fg', bold = true } },
      {
        provider = function()
          local lazy = require('lazy')
          return ' 💤 loaded: '
            .. lazy.stats().loaded
            .. '/'
            .. lazy.stats().count
        end,
        hl = { fg = 'comment', bold = true },
      },
      {
        provider = function() return ' ' .. stl.lazy_updates() end,
        hl = { fg = 'dark_orange' },
      },
      align,
    }

    local terminal_statusline = {
      condition = function()
        return conditions.buffer_matches({ buftype = { 'terminal' } })
      end,
      vim_mode,
      {
        provider = function()
          local icon = codicons.misc.terminal .. ' '
          if vim.bo.filetype == 'toggleterm' then
            return icon .. 'ToggleTerm #' .. vim.b.toggle_number
          end
          local tname, _ = api.nvim_buf_get_name(0):gsub('.*:', '')
          return icon .. tname
        end,
        hl = { fg = 'blue', bold = true },
      },
      align,
    }

    local minimal_statusline = {
      condition = function(self)
        return conditions.buffer_matches({ filetype = self.filetypes })
      end,
      vim_mode,
      {
        condition = function() return vim.bo.filetype ~= 'help' end,
        provider = function() return string.lower(vim.bo.filetype) end,
        hl = { fg = 'fg' },
      },
      align,
    }

    local statusline = {
      -- Mode
      vim_mode,
      -- Git Branch
      {
        init = update_events({
          'BufEnter',
          'BufWritePost',
          'FocusGained',
        }),
        provider = function()
          return codicons.git.branch .. ' ' .. stl.pretty_branch()
        end,
        on_click = {
          callback = function()
            vim.defer_fn(function() stl.list_branches() end, 100)
          end,
          name = 'git_change_branch',
        },
        hl = { fg = 'yellowgreen' },
      },
      {
        condition = function() return is_avail('nvim-tinygit') and false end,
        init = function(self)
          self.blame = require('tinygit.statusline').blame()
          self.branch_state = require('tinygit.statusline').branchState()
        end,
        {
          condition = function(self) return self.blame ~= '' end,
          provider = function(self) return ' ' .. self.blame end,
          hl = { fg = 'comment' },
        },
        {
          condition = function(self) return self.branch_state ~= '' end,
          provider = function(self) return ' ' .. self.branch_state end,
        },
      },
      -- Git
      {
        -- condition = conditions.is_git_repo,
        condition = function() return not stl.is_dots_repo end,
        init = function(self)
          self.status_dict = vim.b.gitsigns_status_dict
          self.git_status = stl.git_status
        end,
        update = {
          'User',
          pattern = { 'GitSignsUpdate', 'GitSignsChanged' },
          callback = function() vim.schedule(vim.cmd.redrawstatus) end,
        },
        {
          condition = function(self) return self.git_status ~= nil end,
          update = { 'User', pattern = 'git_statusChanged' },
          {
            condition = function(self)
              return self.git_status.status == 'pending'
            end,
            provider = ' ' .. codicons.git.pending,
            hl = { fg = 'comment', bold = true },
          },
          {
            condition = function(self)
              return self.git_status.status ~= 'pending'
                and self.git_status.status ~= 'error'
                and self.git_status.status ~= nil
            end,
            {
              provider = function(self)
                return ' ' .. self.git_status.behind .. icons.misc.arrow_down
              end,
              hl = function(self)
                return {
                  fg = self.git_status.behind == 0 and 'fg' or 'pale_red',
                }
              end,
              on_click = {
                callback = function(self)
                  if self.git_status.behind > 0 then stl.git_pull() end
                end,
                name = 'git_pull',
              },
            },
            {
              provider = function(self)
                return ' ' .. self.git_status.ahead .. icons.misc.arrow_up
              end,
              hl = function(self)
                return {
                  fg = self.git_status.ahead == 0 and 'fg' or 'yellowgreen',
                }
              end,
              on_click = {
                callback = function(self)
                  if self.git_status.ahead > 0 then stl.git_push() end
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
        utils.insert(stl.pretty_path, stl.file_flags, stl.file_size)
      ),
      -- Python env
      {
        condition = function() return vim.bo.filetype == 'python' end,
        provider = function() return ' ' .. stl.python_env() end,
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
        init = function() stl.autocmds() end,
        condition = function() return ar.lsp.enable end,
        -- LSP Progress
        {
          provider = function() return stl.lsp_progress end,
          hl = { fg = 'comment' },
        },
        -- LSP Pending Requests
        {
          condition = function() return stl.lsp_progress == '' end,
          provider = function() return stl.lsp_pending end,
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
          local ok, search = pcall(fn.searchcount)
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
      {
        condition = function()
          if not is_avail('nvim-dap') then return false end
          local session = require('dap').session()
          return session ~= nil and false
        end,
        provider = function()
          return codicons.misc.bug_alt .. ' ' .. require('dap').status() .. ' '
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
        provider = stl.package_info,
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
        provider = function() return ' ' .. stl.lazy_updates() end,
        hl = { fg = 'dark_orange' },
        on_click = {
          callback = function() require('lazy').update() end,
          name = 'update_plugins',
        },
      },
      -- cloc
      {
        update = { 'User', pattern = 'ClocStatusUpdated' },
        condition = function() return is_avail('cloc.nvim') end,
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
        provider = stl.word_count,
      },
      -- LSP Clients (null-ls)
      {
        update = { 'LspAttach', 'LspDetach', 'WinEnter', 'BufEnter' },
        condition = function()
          return conditions.lsp_attached and ar_config.lsp.null_ls.enable
        end,
        init = function(self)
          local curwin = api.nvim_get_current_win()
          local curbuf = api.nvim_win_get_buf(curwin)
          local ft = vim.bo[curbuf].ft
          self.client_names = vim
            .iter(vim.lsp.get_clients({ bufnr = curbuf }))
            :filter(function(client) return client.name ~= 'copilot' end)
            :map(function(client) return client.name end)
            :totable()
          self.is_null_ls = vim
            .iter(self.client_names)
            :filter(function(client) return client:match('null') end)
            :totable()
          self.client_names = vim
            .iter(self.client_names)
            :filter(function(client) return not client:match('null') end)
            :totable()
          if not falsy(self.is_null_ls) then
            self.formatters = stl.get_null_ls_formatters(ft)
            self.linters = stl.get_null_ls_linters(ft)
          end
          self.icon = ' ' .. codicons.misc.connect .. ' '
        end,
        {
          provider = function(self)
            if not ar.lsp.enable then return '' end
            if falsy(self.client_names) then
              return self.icon .. 'No Active LSP ' .. separator
            end
            return self.icon .. stl.format_servers(self.client_names)
          end,
          hl = { bold = true },
          on_click = {
            callback = function(self)
              if not falsy(self.client_names) then
                vim.defer_fn(function() vim.cmd('LspInfo') end, 100)
              end
            end,
            name = 'lsp_clients',
          },
        },
        {
          update = { 'LspAttach', 'LspDetach', 'WinEnter', 'BufEnter' },
          {
            condition = function(self)
              return not falsy(self.linters) or not falsy(self.formatters)
            end,
            provider = function() return ' ' .. codicons.misc.null_ls end,
            hl = { bold = true },
          },
          {
            condition = function(self) return not falsy(self.linters) end,
            provider = function(self) return ' ' .. self.linters end,
            hl = { bold = true },
          },
          {
            condition = function(self) return not falsy(self.formatters) end,
            provider = function(self) return ' ' .. self.formatters end,
            hl = { bold = true },
          },
          on_click = {
            callback = function()
              vim.defer_fn(function() vim.cmd('NullLsInfo') end, 100)
            end,
            name = 'null_ls',
          },
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
          self.client_names = vim
            .iter(vim.lsp.get_clients({ bufnr = curbuf }))
            :filter(function(client) return client.name ~= 'copilot' end)
            :map(function(client) return client.name end)
            :totable()
          self.linters = stl.get_linters()
          self.formatters = stl.get_formatters(curbuf)
          self.icon = ' ' .. codicons.misc.disconnect .. ' '
        end,
        {
          update = { 'LspAttach', 'LspDetach', 'WinEnter', 'BufEnter' },
          provider = function(self)
            if not ar.lsp.enable then return '' end
            if falsy(self.client_names) then
              return self.icon .. 'No Active LSP ' .. separator
            end
            return self.icon .. stl.format_servers(self.client_names)
          end,
          hl = { bold = true },
          on_click = {
            callback = function(self)
              if not falsy(self.client_names) then
                vim.defer_fn(function() vim.cmd('LspInfo') end, 100)
              end
            end,
            name = 'lsp_clients',
          },
        },
        {
          update = { 'LspAttach', 'LspDetach', 'WinEnter', 'BufEnter' },
          condition = function(self) return not falsy(self.linters) end,
          provider = function(self)
            if ar.lsp.enable then return ' ' .. self.formatters end
            return self.icon .. self.linters
          end,
          hl = { bold = true },
        },
        {
          update = { 'LspAttach', 'LspDetach', 'WinEnter', 'BufEnter' },
          condition = function(self) return not falsy(self.formatters) end,
          provider = function(self)
            if ar.lsp.enable then return ' ' .. self.formatters end
            return self.icon .. self.formatters
          end,
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
        condition = function()
          return is_avail('ecolog.nvim')
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
            if self.shelter_active then return { fg = 'blue', bold = true } end
            return { fg = 'comment', bold = true }
          end,
        },
        { provider = ' ' .. separator, hl = { bold = true } },
      },
      -- Copilot Status
      {
        condition = function()
          return ar.ai.enable and ar_config.ai.models.copilot
        end,
        init = function(self)
          self.processing = false
          local status = stl.copilot_status()
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
        condition = function() return ar.ai.enable end,
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
      -- MCPHub
      {
        condition = function() return is_avail('mcphub.nvim') and ar.ai.enable end,
        static = {
          active_servers = 0,
          is_connected = false,
          is_connecting = false,
        },
        update = {
          'User',
          pattern = 'MCPHubStateChange',
          callback = function(self, args)
            if args.data then
              local status = args.data.state
              self.is_connected = status == 'ready' or status == 'restarted'
              self.is_connecting = status == 'starting'
                or status == 'restarting'
              self.active_servers = args.data.active_servers or 0
            end
            vim.cmd('redrawstatus')
          end,
        },
        {
          provider = function(self)
            local tower = '󰐻'
            local active_servers = tostring(self.active_servers or 0)
            if self.active_servers == 0 then return ' ' .. tower end
            return ' ' .. tower .. ' ' .. active_servers
          end,
          hl = function(self)
            local color = 'comment'
            if self.is_connected then color = 'green' end
            if self.is_connecting then color = 'blue' end
            return { fg = color, bold = true }
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
      utils.insert(file_block, stl.file_icon, stl.file_type),
      -- Buffers
      {
        condition = function() return is_avail('buffalo.nvim') and false end,
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
        condition = function() return false end,
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
          if not vim.bo.modifiable or vim.bo.readonly then return false end
          local curwin = api.nvim_get_current_win()
          local curbuf = api.nvim_win_get_buf(curwin)
          return vim.b[curbuf].formatting_disabled == true
            or vim.g.formatting_disabled == true
        end,
        provider = function() return '  ' .. codicons.misc.lock end,
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
        provider = function() return '  ' .. stl.ts_active() end,
        hl = { fg = 'forest_green' },
      },
      -- Session
      {
        update = { 'User', pattern = 'PersistedStateChange' },
        {
          condition = function() return false end,
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
            if not falsy(self.rec) then
              return '  ' .. icons.misc.dot_alt .. ' ' .. 'REC'
            end
            if not falsy(self.exec) then
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
            return '  ' .. '%7(%l/%3L%):%2c ' .. stl.progress()
          elseif line_number > 9 then
            return ' ' .. '%7(%l/%3L%):%2c ' .. stl.progress()
          end
          return '%7(%l/%3L%):%2c ' .. stl.progress()
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

    return vim.tbl_extend('force', opts or {}, {
      statusline = vim.tbl_extend('force', opts.statusline or {}, {
        hl = { bg = 'bg_dark', fg = 'fg' },
        fallthrough = false,
        mason_statusline,
        explorer_statusline,
        help_statusline,
        lazy_statusline,
        terminal_statusline,
        minimal_statusline,
        statusline,
      }),
    })
  end,
}
