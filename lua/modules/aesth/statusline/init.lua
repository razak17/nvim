local gl = require('galaxyline')
local colors = require('galaxyline.theme').default
local condition = require('galaxyline.condition')
local gls = gl.section
gl.short_line_list = {'NvimTree', 'vista', 'dbui', 'packer'}

local function hide_in_width()
  local tbl = {['dashboard'] = true, [''] = true}
  local squeeze_width = vim.fn.winwidth(0) / 2
  if tbl[vim.bo.filetype] or squeeze_width < 45 then
    return false
  end
  return true

end

gls.left[1] = {
  RainbowRed = {
    provider = function()
      return '▊ '
    end,
    highlight = {colors.blue, colors.bg}
  }
}
gls.left[2] = {
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
      local mode_color = {
        n = colors.red,
        i = colors.green,
        v = colors.blue,
        [''] = colors.blue,
        V = colors.blue,
        c = colors.magenta,
        no = colors.red,
        s = colors.orange,
        S = colors.orange,
        [''] = colors.orange,
        ic = colors.yellow,
        R = colors.violet,
        Rv = colors.violet,
        cv = colors.red,
        ce = colors.red,
        r = colors.cyan,
        rm = colors.cyan,
        ['r?'] = colors.cyan,
        ['!'] = colors.red,
        t = colors.red
      }
      vim.api
          .nvim_command('hi GalaxyViMode guifg=' .. mode_color[vim.fn.mode()])
      return '  '
    end,
    highlight = {colors.red, colors.bg, 'bold'}
  }
}
gls.left[3] = {
  FileSize = {
    provider = 'FileSize',
    -- condition = condition.buffer_not_empty,
    condition = hide_in_width,
    highlight = {colors.fg, colors.bg}
  }
}
gls.left[4] = {
  FileIcon = {
    provider = 'FileIcon',
    condition = condition.buffer_not_empty,
    highlight = {
      require('galaxyline.provider_fileinfo').get_file_icon_color,
      colors.bg
    }
  }
}

gls.left[5] = {
  FileName = {
    provider = 'FileName',
    condition = condition.buffer_not_empty,
    highlight = {colors.magenta, colors.bg, 'bold'}
  }
}

gls.left[6] = {
  GitIcon = {
    provider = function()
      return '  '
    end,
    condition = condition.check_git_workspace,
    separator = ' ',
    separator_highlight = {'NONE', colors.bg},
    highlight = {colors.violet, colors.bg, 'bold'}
  }
}

gls.left[7] = {
  GitBranch = {
    provider = 'GitBranch',
    condition = condition.check_git_workspace,
    separator = ' ',
    separator_highlight = {'NONE', colors.bg},
    highlight = {colors.violet, colors.bg, 'bold'}
  }
}

gls.left[8] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.red, colors.bg}
  }
}
gls.left[9] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.yellow, colors.bg}
  }
}

gls.left[10] = {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    highlight = {colors.blue, colors.bg}
  }
}

gls.left[11] = {
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = '  ',
    highlight = {'#1abc9c', colors.bg}
  }
}

gls.right[1] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = hide_in_width,
    icon = '  ',
    highlight = {colors.green, colors.bg},
    separator = ' ',
    separator_highlight = {'NONE', colors.bg}
  }
}
gls.right[2] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = hide_in_width,
    icon = '  ',
    highlight = {colors.orange, colors.bg}
  }
}
gls.right[3] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = hide_in_width,
    icon = '  ',
    highlight = {colors.red, colors.bg}
  }
}

gls.right[4] = {
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = hide_in_width,
    icon = 'LSP:',
    highlight = {colors.cyan, colors.bg, 'bold'}
  }
}

gls.right[5] = {
  FileEncode = {
    provider = 'FileEncode',
    condition = function()
      local squeeze_width = vim.fn.winwidth(0) / 2
      if vim.bo.filetype == 'dashboard' then
        return true
      elseif squeeze_width < 50 then
        return false
      else
        return true
      end
    end,
    separator = ' ',
    separator_highlight = {'NONE', colors.bg},
    highlight = {colors.green, colors.bg, 'bold'}
  }
}

gls.right[6] = {
  FileFormat = {
    provider = 'FileFormat',
    condition = function()
      local squeeze_width = vim.fn.winwidth(0) / 2
      if vim.bo.filetype == 'dashboard' then
        return true
      elseif squeeze_width < 50 then
        return false
      else
        return true
      end
    end,
    separator = ' ',
    separator_highlight = {'NONE', colors.bg},
    highlight = {colors.green, colors.bg, 'bold'}
  }
}

gls.right[7] = {
  LineInfo = {
    provider = 'LineColumn',
    condition = function()
      return vim.bo.filetype ~= 'dashboard'
    end,
    separator = ' ',
    separator_highlight = {'NONE', colors.bg},
    highlight = {colors.fg, colors.bg}
  }
}

gls.right[8] = {
  PerCent = {
    provider = 'LinePercent',
    condition = function()
      return vim.bo.filetype ~= 'dashboard'
    end,
    separator = ' ',
    separator_highlight = {'NONE', colors.bg},
    highlight = {colors.fg, colors.bg, 'bold'}
  }
}

gls.right[9] = {
  RainbowBlue = {
    provider = function()
      return vim.bo.filetype ~= 'dashboard' and ' ▊' or '  ▊'
    end,
    highlight = {colors.blue, colors.bg}
  }
}

gls.short_line_left[1] = {
  BufferType = {
    provider = 'FileTypeName',
    separator = ' ',
    separator_highlight = {'NONE', colors.bg},
    highlight = {colors.blue, colors.bg, 'bold'}
  }
}

gls.short_line_left[2] = {
  SFileName = {
    provider = 'SFileName',
    condition = condition.buffer_not_empty,
    highlight = {colors.fg, colors.bg, 'bold'}
  }
}

gls.short_line_right[1] = {
  BufferIcon = {provider = 'BufferIcon', highlight = {colors.fg, colors.bg}}
}

