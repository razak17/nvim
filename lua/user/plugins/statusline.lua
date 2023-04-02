local fn, api, env = vim.fn, vim.api, vim.env
local falsy, hl, icons, codicons = rvim.falsy, rvim.highlight, rvim.ui.icons, rvim.ui.codicons
local curwin = api.nvim_get_current_win()

local conditions = {
  buffer_not_empty = function() return fn.empty(fn.expand('%:t')) ~= 1 end,
  hide_in_width = function() return fn.winwidth(0) > 99 end,
  check_git_workspace = function()
    local filepath = fn.expand('%:p:h')
    local gitdir = fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
  formatting_disabled = function()
    local curbuf = api.nvim_win_get_buf(curwin)
    return vim.b[curbuf].formatting_disabled == true or vim.g.formatting_disabled == true
  end,
  is_pipfile_root = function()
    return not vim.tbl_isempty(vim.fs.find({ 'Pipfile', 'Pipfile.lock' }, {
      path = fn.expand('%:p'),
      upward = true,
    }))
  end,
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

local function npm_package_info()
  local ok, package_info = pcall(require, 'package-info')
  if not ok then return '' end
  return package_info.get_status()
end

local function stl_lsp_clients(bufnum)
  local clients = vim.lsp.get_active_clients({ bufnr = bufnum })
  if falsy(clients) then return { { name = 'No Active LSP' } } end
  table.sort(clients, function(a, b)
    if a.name == 'null-ls' then
      return false
    elseif b.name == 'null-ls' then
      return true
    end
    return a.name < b.name
  end)

  return vim.tbl_map(function(client)
    if client.name:match('null') then
      local sources = require('null-ls.sources').get_available(vim.bo[bufnum].filetype)
      local source_names = vim.tbl_map(function(s) return s.name end, sources)
      return { name = '␀ ' .. table.concat(source_names, ', ') }
    end
    return { name = client.name }
  end, clients)
end

local function lsp_clients()
  local curbuf = api.nvim_win_get_buf(curwin)
  local client_names = rvim.map(function(client) return client.name end, stl_lsp_clients(curbuf))
  return table.concat(client_names, '  ') .. ' '
end

return {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  config = function()
    local P = require('onedark.palette')
    local bg, fg = hl.tint(P.bg_dark, -0.2), P.base8

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
      -- stylua: ignore
      sections = {
        lualine_a = {}, lualine_b = {}, lualine_y = {}, lualine_z = {}, lualine_c = {}, lualine_x = {},
      },
      -- stylua: ignore
      inactive_sections = {
        lualine_a = {}, lualine_b = {}, lualine_y = {}, lualine_z = {}, lualine_c = {}, lualine_x = {},
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

    local function block_color() return { fg = mode_color[fn.mode()] } end
    local function block() return icons.separators.bar end
    local function ins_left(component) table.insert(lualine_config.sections.lualine_c, component) end
    local function ins_right(component) table.insert(lualine_config.sections.lualine_x, component) end

    ins_left({ block, color = block_color, padding = { left = 0, right = 1 } })

    ins_left({ 'branch', icon = '', padding = { left = 0, right = 1 }, color = { fg = P.yellowgreen } })

    ins_left({ 'filename', cond = conditions.buffer_not_empty, padding = { left = 0, right = 1 }, path = 1 })

    ins_left({
      python_env,
      padding = { left = 0, right = 0 },
      color = { fg = P.yellowgreen },
      cond = function() return vim.bo.filetype == 'python' and conditions.hide_in_width() end,
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

    -- Insert mid section.
    ins_left({ function() return '%=%=' end })

    ins_left({
      npm_package_info,
      color = { fg = P.comment },
      cond = function() return fn.expand('%') == 'package.json' and conditions.hide_in_width() end,
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

    ins_right({ lazy_updates, color = { fg = P.orange }, cond = conditions.hide_in_width })

    ins_right({
      function() return ' LSP(s):' end,
      color = { fg = P.comment, gui = 'italic' },
      cond = conditions.hide_in_width,
    })

    ins_right({
      lsp_clients,
      color = { gui = 'bold' },
      padding = { left = 0, right = 1 },
      cond = conditions.hide_in_width,
    })

    ins_right({ 'filetype', cond = nil, padding = { left = 0, right = 1 } })

    ins_right({
      function() return codicons.misc.shaded_lock end,
      padding = { left = 1, right = 1 },
      color = { fg = P.comment, gui = 'bold' },
      cond = function() return conditions.hide_in_width() and conditions.formatting_disabled() end,
    })

    ins_right({
      function() return icons.misc.spell_check end,
      padding = { left = 1, right = 0 },
      color = { fg = P.blue, gui = 'bold' },
      cond = function() return vim.wo.spell and conditions.hide_in_width() end,
    })

    ins_right({
      ts_active,
      padding = { left = 1, right = 0 },
      color = { fg = P.darker_green, gui = 'bold' },
      cond = conditions.hide_in_width,
    })

    ins_right({ 'location', padding = { left = 1, right = 0 } })

    ins_right({ 'progress', padding = { left = 1, right = 0 } })

    ins_right({ block, color = block_color, padding = { left = 1, right = 0 } })

    require('lualine').setup(lualine_config)
  end,
}
