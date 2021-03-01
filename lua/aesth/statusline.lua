local devicons = require 'nvim-web-devicons'

local gl = require('galaxyline')
local gls = gl.section
local colors = require 'aesth.colors'
gl.short_line_list = {'LuaTree','vista','dbui'}

local buffer_not_empty = function()
  if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then
    return true
  end
  return false
end

gls.left[1] = {
  ViMode = {
    provider = function()
      local mode = require 'aesth.icons'

      local vimMode = mode[vim.fn.mode()]

      vim.api.nvim_command("hi GalaxyViMode guibg=" .. vimMode[2])
      return " " .. vimMode[1] ..  " Nvim" .. " "
    end,
    separator = ' ',
    separator_highlight = {colors.yellow,function()
      if not buffer_not_empty() then
        return colors.bg
      end
      return colors.bg
    end},
    highlight = {colors.act1, colors.DarkGoldenrod2}
  }
}
gls.left[2] = {
  FileIcon = {
    provider = function()
      local fname, ext = vim.fn.expand('%:t'), vim.fn.expand('%:e')
      local icon, iconhl = devicons.get_icon(fname, ext)
      if icon == nil then return '' end
      local fg = vim.fn.synIDattr(vim.fn.hlID(iconhl), 'fg')
      local cmd = string.format('highlight %s guifg=%s guibg=%s', 'GalaxyFileIcon', fg, colors.bg)
      vim.cmd(cmd)
      return ' ' .. icon .. ' '
    end,
    condition = buffer_not_empty,
  },
}
gls.left[3] = {
  FileName = {
    provider = { 'FileName' },
    condition = buffer_not_empty,
    separator_highlight = {colors.purple,colors.bg},
    highlight = {colors.grey,colors.bg,}
  }
}

local checkwidth = function()
  local squeeze_width  = vim.fn.winwidth(0) / 2
  if squeeze_width > 40 then
    return true
  end
  return false
end

gls.left[5] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = checkwidth,
    -- separator = ' ',
    -- separator_highlight = {colors.purple,colors.bg},
    icon = '  ',
    highlight = {colors.green,colors.bg},
  }
}
gls.left[6] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = checkwidth,
    -- separator = ' ',
    -- separator_highlight = {colors.purple,colors.bg},
    icon = '  ',
    highlight = {colors.blue,colors.bg},
  }
}
gls.left[7] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = checkwidth,
    -- separator = ' ',
    -- separator_highlight = {colors.purple,colors.bg},
    icon = '  ',
    highlight = {colors.red,colors.bg},
  }
}
gls.left[8] = {
  LeftEnd = {
    provider = function() return ' ' end,
    separator = ' ',
    separator_highlight = {colors.purple,colors.bg},
    highlight = {colors.purple,colors.bg}
  }
}
gls.left[9] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.red,colors.bg}
  }
}
gls.left[10] = {
  Space = {
    provider = function () return '' end
  }
}
gls.left[11] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.yellow,colors.bg},
  }
}
gls.left[12] = {
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = '   ',
    highlight = {colors.blue,colors.bg},
  }
}
gls.left[13] = {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '   ',
    highlight = {colors.orange,colors.bg},
  }
}

gls.right[1]= {
  GitIcon = {
    provider = function() return '  ' end,
    condition = buffer_not_empty,
    highlight = {colors.orange,colors.bg},
  }
}
gls.right[2] = {
  GitBranch = {
    provider = 'GitBranch',
    condition = buffer_not_empty,
    highlight = {colors.grey,colors.bg},
  }
}
gls.right[3]= {
  FileFormat = {
    provider = function() return vim.bo.filetype end,
    separator = ' | ',
    separator_highlight = {colors.darkblue,colors.bg},
    highlight = { colors.fg,colors.bg },
  }
}
gls.right[4] = {
  LineInfo = {
    provider = 'LineColumn',
    separator = ' | ',
    separator_highlight = {colors.darkblue,colors.bg},
    highlight = {colors.grey,colors.bg},
  },
}
gls.right[5] = {
  PerCent = {
    provider = 'LinePercent',
    separator = ' |',
    separator_highlight = {colors.darkblue,colors.bg},
    highlight = {colors.grey,colors.bg},
  }
}

gls.short_line_left[1] = {
  BufferType = {
    provider = 'FileName',
    condition = buffer_not_empty,
    separator = ' ',
    separator_highlight = {colors.purple,colors.bg},
    highlight = {colors.grey,colors.bg,}
  }
}

gls.short_line_right[1] = {
  FileIcon = {
    provider = function()
      local fname, ext = vim.fn.expand('%:t'), vim.fn.expand('%:e')
      local icon, iconhl = devicons.get_icon(fname, ext)
      if icon == nil then return '' end
      local fg = vim.fn.synIDattr(vim.fn.hlID(iconhl), 'fg')
      local cmd = string.format('highlight %s guifg=%s guibg=%s', 'GalaxyFileIcon', fg, colors.bg)
      vim.cmd(cmd)
      return ' ' .. icon .. ' '
    end,
    condition = buffer_not_empty,
  },
}
