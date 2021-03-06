local bo = vim.bo
local gl = require('galaxyline')
local condition = require('galaxyline.condition')
local gls = gl.section
Api, Cmd, Fn = vim.api, vim.cmd, vim.fn
Keymap, Execute, G = Api.nvim_set_keymap, Api.nvim_command, vim.g

gl.short_line_list = {'NvimTree', 'packer', 'minimap', 'Outline'}

local colors = {
  bg = '#373d48',
  section_bg = '#2f333b',
  fg = '#c8ccd4',
  yellow = '#e5c07b',
  cyan = '#56b6c2',
  green = '#98c379',
  orange = '#ffb86c',
  magenta = '#c678dd',
  blue = '#61afef',
  red = '#e06c75',
}

-- Left side
gls.left[1] = {
  RainbowRed = {
    provider = function() return '▊ ' end,
    highlight = {colors.blue, colors.bg},
  },
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
        R = colors.magenta,
        Rv = colors.magenta,
        cv = colors.red,
        ce = colors.red,
        r = colors.cyan,
        rm = colors.cyan,
        ['r?'] = colors.cyan,
        ['!'] = colors.red,
        t = colors.red,
      }
      Execute('hi GalaxyViMode guifg=' .. mode_color[Fn.mode()])
      return '  '
    end,
    highlight = {colors.red, colors.bg, 'bold'},
  },
}

gls.left[3] = {
  FileSize = {
    provider = 'FileSize',
    condition = condition.buffer_not_empty,
    highlight = {colors.fg, colors.bg},
    separator = '| ',
    separator_highlight = {colors.section_bg, colors.bg},
  },
}

gls.left[4] = {
  FileIcon = {
    provider = 'FileIcon',
    condition = condition.buffer_not_empty,
    highlight = {
      require('galaxyline.provider_fileinfo').get_file_icon_color,
      colors.bg,
    },
  },
}
gls.left[5] = {
  FileName = {
    provider = 'FileName',
    condition = condition.buffer_not_empty,
    highlight = {colors.fg, colors.bg},
    separator = '| ',
    separator_highlight = {colors.section_bg, colors.bg},
  },
}
gls.left[6] = {
  GitIcon = {
    provider = function() return ' ' end,
    condition = condition.check_git_workspace,
    highlight = {colors.red, colors.bg},
  },
}
gls.left[7] = {
  GitBranch = {
    provider = 'GitBranch',
    condition = condition.check_git_workspace,
    highlight = {colors.fg, colors.bg},
    separator = ' ',
    separator_highlight = {colors.section_bg, colors.bg},
  },
}
gls.left[8] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = condition.hide_in_width,
    icon = ' ',
    highlight = {colors.green, colors.bg},
  },
}
gls.left[9] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = condition.hide_in_width,
    icon = ' ',
    highlight = {colors.orange, colors.bg},
  },
}
gls.left[10] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = condition.hide_in_width,
    icon = ' ',
    highlight = {colors.red, colors.bg},
  },
}
gls.left[11] = {
  Space = {
    provider = function() return ' ' end,
    highlight = {colors.section_bg, colors.bg},
  },
}
gls.left[12] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.red, colors.bg},
  },
}
gls.left[13] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.orange, colors.bg},
  },
}
gls.left[14] = {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    highlight = {colors.blue, colors.bg},
  },
}

gls.left[15] = {
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = '  ',
    highlight = {colors.blue, colors.bg},
  },
}

-- Right side
gls.right[1] = {
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = condition.hide_in_width,
    icon = 'LSP: ',
    highlight = {colors.fg, colors.bg},
    separator = ' ',
    separator_highlight = {colors.section_bg, colors.bg},
  },
}
gls.right[2] = {
  FileType = {
    provider = function() return bo.filetype end,
    highlight = {colors.fg, colors.bg},
    separator = ' | ',
    separator_highlight = {colors.section_bg, colors.bg},
  },
}

gls.right[3] = {
  Tabstop = {
    provider = function()
      return "Spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
    end,
    condition = condition.hide_in_width,
    highlight = {colors.grey, colors.bg},
    separator = ' | ',
    separator_highlight = {colors.section_bg, colors.bg},
  },
}

gls.right[4] = {
  LineInfo = {
    provider = 'LineColumn',
    condition = function() return vim.bo.filetype ~= 'dashboard' end,
    highlight = {colors.fg, colors.bg},
    separator = ' | ',
    separator_highlight = {colors.section_bg, colors.bg},
  },
}

gls.right[5] = {
  FileFormat = {
    provider = 'FileFormat',
    condition = condition.hide_in_width,
    highlight = {colors.fg, colors.bg},
    separator = ' | ',
    separator_highlight = {colors.section_bg, colors.bg},
  },
}

gls.right[6] = {
  FileEncode = {
    provider = 'FileEncode',
    condition = condition.hide_in_width,
    highlight = {colors.fg, colors.bg},
    separator = ' |',
    separator_highlight = {colors.section_bg, colors.bg},
  },
}

gls.right[7] = {
  PerCent = {
    provider = 'LinePercent',
    condition = function() return vim.bo.filetype ~= 'dashboard' end,
    highlight = {colors.fg, colors.bg},
    separator = ' | ',
    separator_highlight = {colors.section_bg, colors.bg},
  },
}

gls.right[8] = {
  RainbowBlue = {
    provider = function() return '▊' end,
    separator = ' ',
    separator_highlight = {colors.section_bg, colors.bg},
    highlight = {colors.blue, colors.bg},
  },
}

-- Short status line
gls.short_line_left[1] = {
  BufferType = {
    provider = 'FileTypeName',
    highlight = {colors.fg, colors.section_bg},
    separator = ' ',
    separator_highlight = {colors.section_bg, colors.section_bg},
  },
}

gls.short_line_right[1] = {
  BufferIcon = {
    provider = 'BufferIcon',
    highlight = {colors.yellow, colors.section_bg},
    separator = ' ',
    separator_highlight = {colors.section_bg, colors.section_bg},
  },
}

