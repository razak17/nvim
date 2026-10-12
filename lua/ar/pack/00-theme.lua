local scheme_switcher = require('ar.scheme_switcher')
local colorscheme = scheme_switcher.get_current_colorscheme()
local theming = require('ar.theming')
local variant = ar.config.colorscheme.variant

--- Get colorscheme cond
---@param names table
---@return boolean
local function get_cond(names)
  if ar.config.colorscheme.all or vim.list_contains(names, colorscheme) then
    return true
  end
  return not ar.plugins.minimal and vim.tbl_contains(names, colorscheme)
end

if get_cond({ 'onedark' }) then
  vim.opt.rtp:append(
    vim.fs.joinpath(vim.g.projects_dir, 'plugins', 'onedark.nvim')
  )
  -- vim.pack.add(
  --   { 'https://github.com/razak17/onedark.nvim' },
  --   { confirm = false }
  -- )
  require('onedark').setup({ variant = variant })
  local overrides = {
    { Strict = { link = 'DiffDeleteAlt' } },
    { Dim = { link = 'VertSplit' } },
    -- { ['@variable'] = { fg = { from = '@none' } } },
  }
  ar.list_insert(
    overrides,
    theming.generate_completion_overrides(),
    theming.generate_lsp_overrides()
  )
  theming.apply_overrides('onedark', { default = overrides })
end
