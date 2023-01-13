local M = { 'nvim-lualine/lualine.nvim', event = 'VeryLazy' }

function M.config()
  local P = require('zephyr.palette')
  local style = rvim.style
  local icons = style.icons
  local codicons = style.codicons
  local utils = require('user.utils.statusline')
  local conditions = utils.conditions

  -- Config
  local config = {
    options = {
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      theme = {
        normal = { c = { fg = P.base88, bg = P.bg_dark } },
        inactive = { c = { fg = P.base88, bg = P.bg_dark } },
      },
      disabled_filetypes = { 'alpha', 'Outline' },
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
      lualine_c = { 'filename' },
      lualine_x = { 'location' },
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

  local function ins_left(component) table.insert(config.sections.lualine_c, component) end

  local function ins_right(component) table.insert(config.sections.lualine_x, component) end

  ins_left({
    function() return icons.statusline.bar end,
    color = function() return { fg = mode_color[vim.fn.mode()] } end,
    padding = { left = 0, right = 1 },
  })

  ins_left({
    'branch',
    icon = icons.git.branch,
    padding = { left = 0, right = 0 },
    color = { fg = P.yellowgreen },
  })

  ins_left({
    'filename',
    color = {},
    cond = conditions.buffer_not_empty,
  })

  ins_left({
    utils.python_env,
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
    color = {},
    cond = conditions.hide_in_width,
  })

  -- Add components to right sections
  ins_right({
    'diff',
    source = utils.diff_source,
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
    padding = { left = 1, right = 0 },
  })

  ins_right({
    function() return ' LSP(s):' end,
    color = { fg = P.comment },
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

      local null_ls_clients = table.concat(null_ls, ', ') -- alt: •
      local clients = table.concat(client_names, '  ') .. '  ' .. null_ls_clients -- alt: •
      -- if #client_names > 3 then clients = #client_names - 1 .. ' clients running ' end
      if rvim.empty(client_names) then return 'No LSP clients available' end
      return clients
    end,
    color = { gui = 'bold' },
    cond = conditions.hide_in_width,
  })

  ins_right({
    function()
      local b = vim.api.nvim_get_current_buf()
      if next(vim.treesitter.highlighter.active[b]) then return ' ts' end
      return ''
    end,
    padding = { left = 0, right = 0 },
    color = { fg = P.darker_green, gui = 'bold' },
    cond = conditions.hide_in_width,
  })

  ins_right({ 'location' })

  ins_right({ 'progress' })

  ins_right({
    function() return icons.statusline.bar end,
    color = function() return { fg = mode_color[vim.fn.mode()] } end,
  })

  require('lualine').setup(config)
end

return M
