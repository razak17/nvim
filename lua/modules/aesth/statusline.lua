return function()
  -- local bo = vim.bo
  -- local gl = require "galaxyline"
  Api, Cmd, Fn = vim.api, vim.cmd, vim.fn
  Keymap, Execute, G = Api.nvim_set_keymap, Api.nvim_command, vim.g

  local Log = require "core.log"
  local status_ok, gl = rvim.safe_require "galaxyline"
  local status_okc, condition = rvim.safe_require "galaxyline.condition"
  if not status_ok and not status_okc then
    Log:debug "Failed to galaxyline"
    return
  end

  local gls = gl.section

  gl.short_line_list = { "NvimTree", "packer", "minimap", "Outline" }

  local colors = rvim.style.palette

  -- Left side
  gls.left[1] = {
    RainbowRed = {
      provider = function()
        return "▊ "
      end,
      highlight = { colors.bright_blue, colors.statusline_bg },
    },
  }
  gls.left[2] = {
    ViMode = {
      provider = function()
        -- auto change color according the vim mode
        local mode_color = {
          n = colors.pale_red,
          i = colors.green,
          v = colors.bright_blue,
          [""] = colors.bright_blue,
          V = colors.bright_blue,
          c = colors.magenta,
          no = colors.pale_red,
          s = colors.orange,
          S = colors.orange,
          [""] = colors.orange,
          ic = colors.light_yellow,
          R = colors.magenta,
          Rv = colors.magenta,
          cv = colors.pale_red,
          ce = colors.pale_red,
          r = colors.cyan,
          rm = colors.cyan,
          ["r?"] = colors.cyan,
          ["!"] = colors.pale_red,
          t = colors.pale_red,
        }
        Execute("hi GalaxyViMode guifg=" .. mode_color[Fn.mode()])
        return "  "
      end,
      highlight = { colors.pale_red, colors.statusline_bg, "bold" },
    },
  }

  gls.left[3] = {
    FileSize = {
      provider = "FileSize",
      condition = condition.buffer_not_empty,
      highlight = { colors.statusline_fg, colors.statusline_bg },
      separator = "| ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }

  gls.left[4] = {
    FileIcon = {
      provider = "FileIcon",
      condition = condition.buffer_not_empty,
      highlight = {
        require("galaxyline.provider_fileinfo").get_file_icon_color,
        colors.statusline_bg,
      },
    },
  }
  gls.left[5] = {
    FileName = {
      provider = "FileName",
      condition = condition.buffer_not_empty,
      highlight = { colors.statusline_fg, colors.statusline_bg },
      separator = "| ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }
  gls.left[6] = {
    GitIcon = {
      provider = function()
        return " "
      end,
      condition = condition.check_git_workspace,
      highlight = { colors.pale_red, colors.statusline_bg },
    },
  }
  gls.left[7] = {
    GitBranch = {
      provider = "GitBranch",
      condition = condition.check_git_workspace,
      highlight = { colors.statusline_fg, colors.statusline_bg },
      separator = " ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }
  gls.left[8] = {
    DiffAdd = {
      provider = "DiffAdd",
      condition = condition.hide_in_width,
      icon = " ",
      highlight = { colors.green, colors.statusline_bg },
    },
  }
  gls.left[9] = {
    DiffModified = {
      provider = "DiffModified",
      condition = condition.hide_in_width,
      icon = " ",
      highlight = { colors.orange, colors.statusline_bg },
    },
  }
  gls.left[10] = {
    DiffRemove = {
      provider = "DiffRemove",
      condition = condition.hide_in_width,
      icon = " ",
      highlight = { colors.pale_pale_red, colors.statusline_bg },
    },
  }
  gls.left[11] = {
    Space = {
      provider = function()
        return " "
      end,
      highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }
  gls.left[12] = {
    DiagnosticError = {
      provider = "DiagnosticError",
      icon = "  ",
      highlight = { colors.pale_red, colors.statusline_bg },
    },
  }
  gls.left[13] = {
    DiagnosticWarn = {
      provider = "DiagnosticWarn",
      icon = "  ",
      highlight = { colors.orange, colors.statusline_bg },
    },
  }
  gls.left[14] = {
    DiagnosticInfo = {
      provider = "DiagnosticInfo",
      icon = "  ",
      highlight = { colors.bright_blue, colors.statusline_bg },
    },
  }

  gls.left[15] = {
    DiagnosticHint = {
      provider = "DiagnosticHint",
      icon = "  ",
      highlight = { colors.bright_blue, colors.statusline_bg },
    },
  }

  local function get_attached_provider_name(msg)
    msg = msg or "LSP Inactive"

    local buf_clients = vim.lsp.buf_get_clients()
    if next(buf_clients) == nil then
      return msg
    end

    local buf_ft = vim.bo.filetype
    local buf_client_names = {}
    for _, client in pairs(buf_clients) do
      if client.name ~= "null-ls" then
        table.insert(buf_client_names, client.name)
      end
    end

    -- add formatter
    local formatters = require "lsp.null-ls.formatters"
    local supported_formatters = formatters.list_registered_providers(buf_ft)
    vim.list_extend(buf_client_names, supported_formatters)

    -- add linter
    local linters = require "lsp.null-ls.linters"
    local supported_linters = linters.list_registered_providers(buf_ft)
    vim.list_extend(buf_client_names, supported_linters)

    -- local null_ls = require "lsp.null-ls"
    -- local null_ls_providers = null_ls.list_supported_provider_names(vim.bo.filetype)
    -- vim.list_extend(buf_client_names, null_ls_providers)

    return table.concat(buf_client_names, " • ")
  end

  -- Right side
  gls.right[1] = {
    ShowLspClient = {
      provider = function()
        local squeeze_width = vim.fn.winwidth(0) / 2
        if squeeze_width > 55 then
          return get_attached_provider_name()
        end
        return ""
      end,
      condition = function()
        local tbl = { ["dashboard"] = true, [" "] = true }
        if tbl[vim.bo.filetype] then
          return false
        end
        return true
      end,
      icon = "• ",
      highlight = { colors.statusline_fg, colors.statusline_bg },
      separator = " ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }

  gls.right[2] = {
    TreesitterIcon = {
      provider = function()
        if next(vim.treesitter.highlighter.active) ~= nil then
          return "  " .. vim.bo.filetype
        end
        return vim.bo.filetype
      end,
      highlight = { colors.statusline_fg, colors.statusline_bg },
      separator = " | ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }

  gls.right[3] = {
    Tabstop = {
      provider = function()
        return "Spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
      end,
      condition = condition.hide_in_width,
      highlight = { colors.statusline_fg, colors.statusline_bg },
      separator = " | ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }

  gls.right[4] = {
    LineInfo = {
      provider = "LineColumn",
      condition = function()
        return vim.bo.filetype ~= "dashboard"
      end,
      highlight = { colors.statusline_fg, colors.statusline_bg },
      separator = " | ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }

  gls.right[5] = {
    FileFormat = {
      provider = "FileFormat",
      condition = condition.hide_in_width,
      highlight = { colors.statusline_fg, colors.statusline_bg },
      separator = " | ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }

  gls.right[6] = {
    FileEncode = {
      provider = "FileEncode",
      condition = condition.hide_in_width,
      highlight = { colors.statusline_fg, colors.statusline_bg },
      separator = " |",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }

  gls.right[7] = {
    PerCent = {
      provider = "LinePercent",
      condition = function()
        return vim.bo.filetype ~= "dashboard"
      end,
      highlight = { colors.statusline_fg, colors.statusline_bg },
      separator = " | ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
    },
  }

  gls.right[8] = {
    RainbowBlue = {
      provider = function()
        return "▊"
      end,
      separator = " ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_bg },
      highlight = { colors.bright_blue, colors.statusline_bg },
    },
  }

  -- Short status line
  gls.short_line_left[1] = {
    BufferType = {
      provider = "FileTypeName",
      highlight = { colors.statusline_fg, colors.statusline_section_bg },
      separator = " ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_section_bg },
    },
  }

  gls.short_line_right[1] = {
    BufferIcon = {
      provider = "BufferIcon",
      highlight = { colors.light_yellow, colors.statusline_section_bg },
      separator = " ",
      separator_highlight = { colors.statusline_section_bg, colors.statusline_section_bg },
    },
  }
end
