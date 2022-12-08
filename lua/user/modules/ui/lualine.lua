return function()
  local P = require('zephyr.palette')
  local s = rvim.style
  local icons = s.icons
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
    function()
      local filename = (vim.fn.expand('%') == '' and 'Empty ') or vim.fn.expand('%:t')
      return filename == 'neo-tree filesystem [1]' and 'File Explorer' or filename
    end,
    padding = { left = 1, right = 0 },
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
      error = s.codicons.lsp.error .. ' ',
      warn = s.codicons.lsp.warn .. ' ',
      info = s.codicons.lsp.info .. ' ',
      hint = s.codicons.lsp.hint .. ' ',
    },
    color = {},
    cond = conditions.hide_in_width,
  })

  -- Add components to right sections
  ins_right({
    'diff',
    source = utils.diff_source,
    symbols = {
      added = s.codicons.git.added .. ' ',
      modified = s.codicons.git.mod .. ' ',
      removed = s.codicons.git.removed .. ' ',
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
      if not rvim.plugin_installed('package-info.nvim') then return end
      local package_info = require('package-info')
      return package_info.get_status()
    end,
    padding = { left = 1, right = 0 },
  })

  ins_right({
    function(msg)
      msg = msg or 'LS Inactive'
      local buf_clients = vim.lsp.get_active_clients()
      if next(buf_clients) == nil then
        -- TODO: clean up this if statement
        if type(msg) == 'boolean' or #msg == 0 then return 'LS Inactive' end
        return msg
      end
      local buf_client_names = {}
      local copilot_active = false

      -- add client
      for _, client in pairs(buf_clients) do
        if client.name == 'copilot' then copilot_active = true end
        if client.name ~= 'copilot' then table.insert(buf_client_names, client.name) end
      end

      local clients = table.concat(buf_client_names, '  ') -- alt: •
      return copilot_active and clients .. '%#SLCopilot#' .. '  ' .. icons.misc.octoface or clients
    end,
    cond = conditions.hide_in_width,
  })

  ins_right({
    function()
      local b = vim.api.nvim_get_current_buf()
      if next(vim.treesitter.highlighter.active[b]) then return icons.misc.tree end
      return ''
    end,
    color = { fg = P.dark_green },
    cond = conditions.hide_in_width,
  })

  ins_right({
    'filetype',
    icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
    color = {},
  })

  ins_right({
    'o:encoding',
    fmt = string.upper,
    cond = conditions.hide_in_width,
  })

  ins_right({
    'fileformat',
    fmt = string.upper,
    icons_enabled = false,
    cond = conditions.hide_in_width,
  })

  ins_right({ 'location' })

  ins_right({ 'progress' })

  ins_right({
    function() return icons.statusline.bar end,
    color = function() return { fg = mode_color[vim.fn.mode()] } end,
    padding = { left = 1 },
  })

  require('lualine').setup(config)
end
