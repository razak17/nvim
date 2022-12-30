local M = { 'SmiteshP/nvim-navic' }

function M.config()
  vim.g.navic_silence = true
  local highlights = require('user.utils.highlights')
  local s = rvim.style
  local misc = s.icons.misc
  require('user.utils.highlights').plugin('navic', {
    { NavicText = { bold = false } },
    { NavicSeparator = { link = 'Directory' } },
  })
  local icons = rvim.map(function(icon, key)
    highlights.set(('NavicIcons%s'):format(key), { link = rvim.lsp.kind_highlights[key] })
    return icon .. ' '
  end, s.codicons.kind)
  require('nvim-navic').setup({
    icons = icons,
    highlight = true,
    depth_limit_indicator = misc.ellipsis,
    separator = (' %s '):format(misc.arrow_right),
  })
end

return M
