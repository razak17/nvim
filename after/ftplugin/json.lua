if not ar or ar.none then return end

local bo, wo = vim.bo, vim.wo

bo.autoindent = true
bo.expandtab = true
bo.formatoptions = 'tcq2l'
bo.shiftwidth = 2
bo.softtabstop = 2
bo.tabstop = 2

wo.conceallevel = 0
wo.foldmethod = 'syntax'

map('n', 'o', function()
  local line = vim.api.nvim_get_current_line()
  local should_add_comma = string.find(line, '[^,{[]$')
  if should_add_comma then return 'A,<cr>' end
  return 'o'
end, { buffer = 0, expr = true })

if not ar.plugins.enable or ar.plugins.minimal then return end

if not ar.is_available('package-info.nvim') then return end

if vim.fn.expand('%:t') == 'package.json' then
  local fmt = string.format

  local function with_desc(desc)
    return { buffer = 0, desc = fmt('package-info: %s', desc) }
  end
  local package_info = require('package-info')

  map('n', '<localleader>Pt', package_info.toggle, with_desc('toggle'))
  map('n', '<localleader>Pu', package_info.update, with_desc('update'))
  map('n', '<localleader>Pd', package_info.delete, with_desc('delete'))
  map('n', '<localleader>Pi', package_info.install, with_desc('install new'))
  map(
    'n',
    '<localleader>Pc',
    package_info.change_version,
    with_desc('change version')
  )
end
