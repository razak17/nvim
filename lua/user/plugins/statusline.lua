local fn, api, env, fmt = vim.fn, vim.api, vim.env, string.format
local falsy, icons, codicons = rvim.falsy, rvim.ui.icons, rvim.ui.codicons
local separator = icons.separators.dotted_thin_block

local ignored_filetypes =
  { 'toggleterm', 'lspinfo', 'null-ls-info', 'mason', 'oil', 'buffer_manager', 'Jaq' }

local conditions = {
  ignored_filetype = function() return not rvim.find_string(ignored_filetypes, vim.bo.filetype) end,
  buffer_not_empty = function() return fn.empty(fn.expand('%:t')) ~= 1 end,
  hide_in_width = function() return fn.winwidth(0) > 99 end,
  check_git_workspace = function()
    local filepath = fn.expand('%:p:h')
    local gitdir = fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
  formatting_disabled = function()
    local curwin = api.nvim_get_current_win()
    local curbuf = api.nvim_win_get_buf(curwin)
    return vim.b[curbuf].formatting_disabled == true or vim.g.formatting_disabled == true
  end,
  is_pipfile_root = function()
    return not vim.tbl_isempty(vim.fs.find({ 'Pipfile', 'Pipfile.lock' }, {
      path = fn.expand('%:p'),
      upward = true,
    }))
  end,
  copilot_enabled = function() return rvim.ai.enable and not rvim.plugins.minimal end,
  lsp_enabled = function() return rvim.lsp.enable end,
}

local function ts_active()
  local b = api.nvim_get_current_buf()
  if next(vim.treesitter.highlighter.active[b]) then return icons.misc.active_ts .. ' TS' end
  return ''
end

local function env_cleanup(venv)
  local final_venv = venv
  if string.find(venv, '/') then
    for w in venv:gmatch('([^/]+)') do
      final_venv = w
    end
  end
  if conditions.is_pipfile_root() then return final_venv:match('^([^%-]*)') end
  return final_venv
end

local function python_env()
  local venv
  if env.CONDA_DEFAULT_ENV then
    venv = env.CONDA_DEFAULT_ENV
  elseif env.VIRTUAL_ENV then
    venv = env.VIRTUAL_ENV
  end
  if venv == nil then return '' end
  return string.format('[%s]', env_cleanup(venv))
end

local function lazy_updates()
  local lazy_ok, lazy = pcall(require, 'lazy.status')
  local pending_updates = lazy_ok and lazy.updates() or nil
  local has_pending_updates = lazy_ok and lazy.has_updates() or false
  if has_pending_updates then return pending_updates end
  return ''
end

local function stl_package_info()
  local ok, package_info = pcall(require, 'package-info')
  if not ok then return '' end
  return package_info.get_status()
end

local function stl_lsp_clients(bufnum)
  -- TODO: Use lsp.get_active_clients() when
  local clients = vim.lsp.get_clients({ bufnr = bufnum })
  clients = vim.tbl_filter(function(client) return client.name ~= 'copilot' end, clients)
  local lsp_clients = vim.tbl_filter(function(client) return client.name ~= 'null-ls' end, clients)
  if falsy(clients) then return { { name = 'No Active LSP' } } end
  table.sort(clients, function(a, b)
    if a.name == 'null-ls' then return false end
    if b.name == 'null-ls' then return true end
    return a.name < b.name
  end)

  return vim.tbl_map(function(client)
    if client.name:match('null') then
      local sources = require('null-ls.sources').get_available(vim.bo[bufnum].filetype)
      if rvim.falsy(sources) then return { name = '' } end
      table.sort(sources, function(a, b) return a.name < b.name end)
      local sources_names = vim
        .iter(ipairs(sources))
        :map(function(_, s) return s.name end)
        :totable()
      local sources_component = table.concat(rvim.removeDuplicates(sources_names), ', ')
      if falsy(lsp_clients) then
        return { name = 'No Active LSP' .. ' ' .. separator .. ' ␀ ' .. sources_component }
      end
      return { name = '␀ ' .. sources_component }
    end
    return { name = client.name }
  end, clients)
end

local function lsp_client_names()
  local curwin = api.nvim_get_current_win()
  local curbuf = api.nvim_win_get_buf(curwin)
  local client_names = vim
    .iter(ipairs(stl_lsp_clients(curbuf)))
    :map(function(_, c) return c.name end)
    :totable()
  return ' ' .. table.concat(client_names, fmt(' %s ', separator)) .. ' ' .. separator
end

local function stl_copilot_indicator()
  local client = vim.lsp.get_clients({ name = 'copilot' })[1]
  if client == nil then return fmt('inactive %s', separator) end
  if vim.tbl_isempty(client.requests) then return fmt('idle %s', separator) end
  return fmt('working %s', separator)
end

return {
  {
    'nvim-lualine/lualine.nvim',
    enabled = not rvim.plugins.minimal,
    lazy = false,
    config = function()
      local colors = require('onedark.palette')
      local lualine_config = {
        options = {
          theme = 'onedark',
          globalstatus = true,
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = { 'alpha', 'Outline' },
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
      }

      local mode_color = {
        n = colors.blue,
        i = colors.yellowgreen,
        v = colors.magenta,
        [''] = colors.pale_blue,
        V = colors.pink,
        c = colors.yellow,
        no = colors.pale_red,
        s = colors.orange,
        S = colors.orange,
        [''] = colors.orange,
        ic = colors.yellowgreen,
        R = colors.violet,
        Rv = colors.violet,
        cv = colors.pale_red,
        ce = colors.pale_red,
        r = colors.cyan,
        rm = colors.cyan,
        ['r?'] = colors.cyan,
        ['!'] = colors.pale_red,
        t = colors.red,
      }

      local function block_color() return { fg = mode_color[fn.mode()] } end
      local function block() return icons.separators.bar end
      local function ins_left(component) table.insert(lualine_config.sections.lualine_c, component) end
      local function ins_right(component) table.insert(lualine_config.sections.lualine_x, component) end

      ins_left({ block, color = block_color, padding = { left = 0, right = 1 } })

      ins_left({
        'branch',
        icon = '',
        padding = { left = 0, right = 1 },
        color = { fg = colors.yellowgreen },
      })

      ins_left({
        'filename',
        cond = conditions.buffer_not_empty,
        padding = { left = 0, right = 1 },
        path = 4,
      })

      ins_left({
        python_env,
        padding = { left = 0, right = 0 },
        color = { fg = colors.yellowgreen },
        cond = conditions.hide_in_width and function() return vim.bo.filetype == 'python' end,
      })

      ins_left({
        'diagnostics',
        sources = { 'nvim_diagnostic' },
        symbols = {
          error = codicons.lsp.error .. ' ',
          warn = codicons.lsp.warn .. ' ',
          info = codicons.lsp.info .. ' ',
          hint = codicons.lsp.hint .. ' ',
        },
        cond = conditions.hide_in_width and conditions.lsp_enabled,
      })

      -- Insert mid section.
      ins_left({ function() return '%=%=' end })

      ins_left({
        stl_package_info,
        color = { fg = colors.comment },
        cond = conditions.hide_in_width and function() return fn.expand('%') == 'package.json' end,
      })

      -- Add components to right sections
      ins_right({
        'diff',
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
        symbols = {
          added = codicons.git.added .. ' ',
          modified = codicons.git.mod .. ' ',
          removed = codicons.git.removed .. ' ',
        },
        diff_color = {
          added = { fg = colors.yellowgreen },
          modified = { fg = colors.dark_orange },
          removed = { fg = colors.error_red },
        },
        cond = conditions.hide_in_width,
      })

      ins_right({
        lazy_updates,
        color = { fg = colors.orange },
        cond = conditions.hide_in_width,
      })

      ins_right({
        lsp_client_names,
        color = { gui = 'bold' },
        padding = { left = 0, right = 1 },
        cond = conditions.hide_in_width
          and function() return conditions.ignored_filetype() and conditions.lsp_enabled() end,
      })

      ins_right({
        function() return ' ' end,
        padding = { left = 0, right = 0 },
        color = { fg = colors.forest_green },
        cond = conditions.hide_in_width
          and function() return conditions.ignored_filetype() and conditions.copilot_enabled() end,
      })

      ins_right({
        stl_copilot_indicator,
        color = { gui = 'bold' },
        cond = conditions.hide_in_width
          and function() return conditions.ignored_filetype() and conditions.copilot_enabled() end,
      })

      ins_right({ 'filetype', cond = nil, padding = { left = 0, right = 0 } })

      ins_right({
        function() return codicons.misc.shaded_lock end,
        padding = { left = 2, right = 0 },
        color = { fg = colors.comment, gui = 'bold' },
        cond = conditions.hide_in_width and conditions.formatting_disabled,
      })

      ins_right({
        function() return icons.misc.spell_check end,
        padding = { left = 2, right = 0 },
        color = { fg = colors.blue, gui = 'bold' },
        cond = conditions.hide_in_width and function() return vim.wo.spell end,
      })

      ins_right({
        ts_active,
        padding = { left = 2, right = 0 },
        color = { fg = colors.darker_green, gui = 'bold' },
        cond = conditions.hide_in_width and function() return rvim.treesitter.enable end,
      })

      ins_right({ 'location', padding = { left = 1, right = 0 } })

      ins_right({ 'progress', padding = { left = 1, right = 0 } })

      ins_right({ block, color = block_color, padding = { left = 1, right = 0 } })

      require('lualine').setup(lualine_config)
    end,
  },
}
