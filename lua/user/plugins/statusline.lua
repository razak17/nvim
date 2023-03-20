local icons = rvim.ui.icons
local codicons = rvim.ui.codicons

local conditions = {
  buffer_not_empty = function() return vim.fn.empty(vim.fn.expand('%:t')) ~= 1 end,
  hide_in_width = function() return vim.fn.winwidth(0) > 99 end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

local function is_pipfile_root()
  return not vim.tbl_isempty(vim.fs.find({ 'Pipfile', 'Pipfile.lock' }, {
    path = vim.fn.expand('%:p'),
    upward = true,
  }))
end
local function env_cleanup(venv)
  if string.find(venv, '/') then
    local final_venv = venv
    for w in venv:gmatch('([^/]+)') do
      final_venv = w
    end
    venv = final_venv
  end
  if is_pipfile_root() then venv = venv:match('^([^%-]*)') end
  return venv
end

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  config = function()
    local P = require('zephyr.palette')

    local bg = rvim.highlight.get('StatusLine', 'bg')
    local fg = rvim.highlight.get('StatusLine', 'fg')

    -- Config
    local lualine_config = {
      options = {
        globalstatus = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = { 'alpha', 'Outline' },
        theme = {
          normal = { c = { fg = fg, bg = bg } },
          inactive = { c = { fg = fg, bg = bg } },
        },
      },
      sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    }

    local mode_color = {
      n = P.blue,
      i = P.yellowgreen,
      v = P.magenta,
      [''] = P.pale_blue,
      V = P.pink,
      c = P.yellow,
      no = P.pale_red,
      s = P.orange,
      S = P.orange,
      [''] = P.orange,
      ic = P.yellowgreen,
      R = P.violet,
      Rv = P.violet,
      cv = P.pale_red,
      ce = P.pale_red,
      r = P.cyan,
      rm = P.cyan,
      ['r?'] = P.cyan,
      ['!'] = P.pale_red,
      t = P.red,
    }

    local function ins_left(component) table.insert(lualine_config.sections.lualine_c, component) end

    local function ins_right(component) table.insert(lualine_config.sections.lualine_x, component) end

    ins_left({
      function() return icons.separators.bar end,
      color = function() return { fg = mode_color[vim.fn.mode()] } end,
      padding = { left = 0, right = 1 },
    })

    ins_left({
      'branch',
      icon = '',
      padding = { left = 1, right = 1 },
      color = { fg = P.yellowgreen },
    })

    ins_left({
      'filename',
      cond = conditions.buffer_not_empty,
      path = 1,
    })

    ins_left({
      function()
        if vim.bo.filetype == 'python' then
          local venv = vim.env.CONDA_DEFAULT_ENV
          if venv then return string.format('[%s]', env_cleanup(venv)) end
          venv = vim.env.VIRTUAL_ENV
          if venv then return string.format('[%s]', env_cleanup(venv)) end
          return ''
        end
        return ''
      end,
      color = { fg = P.yellowgreen },
      cond = conditions.hide_in_width,
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
      cond = conditions.hide_in_width,
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
        added = { fg = P.yellowgreen },
        modified = { fg = P.dark_orange },
        removed = { fg = P.error_red },
      },
      cond = conditions.hide_in_width,
    })

    ins_right({
      function()
        local package_info = require('package-info')
        return package_info.get_status()
      end,
      cond = function() return vim.fn.expand('%') == 'package.json' end,
      padding = { left = 1, right = 0 },
    })

    ins_right({
      require('lazy.status').updates,
      cond = require('lazy.status').has_updates,
      color = { fg = P.orange },
    })

    ins_right({
      function() return ' LSP(s):' end,
      color = { fg = P.comment, gui = 'italic' },
      cond = conditions.hide_in_width,
    })

    ins_right({
      function()
        local buf_clients = vim.lsp.get_active_clients()
        table.sort(buf_clients, function(a, b)
          if a.name == 'null-ls' then
            return false
          elseif b.name == 'null-ls' then
            return true
          end
          return a.name < b.name
        end)

        -- add lsp clients
        local client_names = {}
        for _, client in pairs(buf_clients) do
          if client.name ~= 'null-ls' then table.insert(client_names, client.name) end
        end

        -- add null-ls sources
        local registered_sources = {}
        local available_sources = require('null-ls.sources').get_available(vim.bo.filetype)
        for _, source in ipairs(available_sources) do
          for method in pairs(source.methods) do
            registered_sources[method] = registered_sources[method] or {}
            table.insert(registered_sources[method], source.name)
          end
        end

        local null_ls = {}
        local formatter = registered_sources['NULL_LS_FORMATTING']
        local linter = registered_sources['NULL_LS_DIAGNOSTICS']
        if formatter ~= nil then vim.list_extend(null_ls, formatter) end
        if linter ~= nil then vim.list_extend(null_ls, linter) end

        if rvim.empty(client_names) then return 'No Active LSP' end
        local clients = table.concat(client_names, '  ')
        null_ls = table.concat(null_ls, ', ')
        clients = clients .. ' '
        if not rvim.empty(null_ls) then clients = clients .. ' ' .. null_ls .. ' ' end
        return clients
      end,
      color = { gui = 'bold' },
      cond = conditions.hide_in_width,
    })

    ins_right({ 'filetype', cond = nil, padding = { left = 1, right = 1 } })

    ins_right({
      function()
        if vim.wo.spell then return icons.ui.spell_check end
        return ''
      end,
      padding = { left = 1, right = 0 },
      color = { fg = P.darker_green, gui = 'bold' },
      cond = conditions.hide_in_width,
    })

    ins_right({
      function()
        local b = vim.api.nvim_get_current_buf()
        if next(vim.treesitter.highlighter.active[b]) then return icons.ui.active_ts .. ' TS' end
        return ''
      end,
      padding = { left = 1, right = 0 },
      color = { fg = P.darker_green, gui = 'bold' },
      cond = conditions.hide_in_width,
    })

    ins_right({ 'location' })

    ins_right({ 'progress' })

    ins_right({
      function() return icons.separators.bar end,
      color = function() return { fg = mode_color[vim.fn.mode()] } end,
    })

    require('lualine').setup(lualine_config)
  end,
}