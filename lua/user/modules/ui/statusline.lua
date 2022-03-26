return function()
  local api, fn = vim.api, vim.fn
  local execute = api.nvim_command

  local Log = require "user.core.log"
  local status_ok, gl = rvim.safe_require "galaxyline"
  local status_okc, condition = rvim.safe_require "galaxyline.condition"
  if not status_ok and not status_okc then
    Log:debug "Failed to galaxyline"
    return
  end

  local hide_in_width = function()
    local squeeze_width = vim.api.nvim_win_get_width(0) / 2
    if squeeze_width >= 75 then
      return true
    end
    return false
  end

  local gls = gl.section

  gl.short_line_list = { "NvimTree", "packer", "minimap", "Outline" }

  local colors = rvim.palette
  local icons = rvim.style.icons

  -- Left side
  gls.left[1] = {
    RainbowRed = {
      provider = function()
        return icons.statusline.bar .. " "
      end,
      highlight = { colors.pale_blue, colors.bg },
    },
  }
  gls.left[2] = {
    ViMode = {
      provider = function()
        -- auto change color according the vim mode
        local mode_color = {
          n = colors.pale_red,
          i = colors.green,
          v = colors.pale_blue,
          [""] = colors.pale_blue,
          V = colors.pale_blue,
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
        execute("hi GalaxyViMode guifg=" .. mode_color[fn.mode()])
        return icons.statusline.mode .. " "
      end,
      highlight = { colors.pale_red, colors.bg, "bold" },
    },
  }

  gls.left[3] = {
    FileSize = {
      provider = "FileSize",
      condition = condition.buffer_not_empty or hide_in_width,
      highlight = { colors.statusline_fg, colors.bg },
      separator = "| ",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }

  gls.left[4] = {
    FileIcon = {
      provider = "FileIcon",
      condition = condition.buffer_not_empty,
      highlight = {
        require("galaxyline.providers.fileinfo").get_file_icon_color,
        colors.bg,
      },
    },
  }
  gls.left[5] = {
    FileName = {
      provider = "FileName",
      -- provider = require("galaxyline.providers.fileinfo").get_current_file_path,
      condition = condition.buffer_not_empty,
      highlight = { colors.statusline_fg, colors.bg },
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }

  local function env_cleanup(venv)
    if string.find(venv, "/") then
      local final_venv = venv
      for w in venv:gmatch "([^/]+)" do
        final_venv = w
      end
      venv = final_venv
    end
    return venv
  end

  gls.left[6] = {
    ShowPythonEnv = {
      provider = function()
        if vim.bo.filetype == "python" then
          local venv = os.getenv "CONDA_DEFAULT_ENV"
          if venv then
            return string.format(" (%s) ", env_cleanup(venv))
          end
          venv = os.getenv "VIRTUAL_ENV"
          if venv then
            return string.format(" (%s) ", env_cleanup(venv))
          end
          return ""
        end
        return ""
      end,
      condition = hide_in_width,
      highlight = { colors.dark_green, colors.bg },
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }
  gls.left[7] = {
    GitIcon = {
      provider = function()
        return "   " .. icons.git.branch .. " "
      end,
      condition = condition.check_git_workspace,
      highlight = { colors.dark_green, colors.bg },
    },
  }
  gls.left[8] = {
    GitBranch = {
      provider = "GitBranch",
      condition = condition.check_git_workspace,
      highlight = { colors.statusline_fg, colors.bg },
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }
  gls.left[9] = {
    Space = {
      provider = function()
        return "      "
      end,
      highlight = { colors.statusline_section_bg, colors.bg },
    },
  }
  gls.left[10] = {
    DiffAdd = {
      provider = "DiffAdd",
      condition = condition.hide_in_width,
      icon = icons.git.add .. " ",
      highlight = { colors.yellowgreen, colors.bg },
    },
  }
  gls.left[11] = {
    DiffModified = {
      provider = "DiffModified",
      condition = condition.hide_in_width,
      icon = icons.git.mod .. " ",
      highlight = { colors.dark_orange, colors.bg },
    },
  }
  gls.left[12] = {
    DiffRemove = {
      provider = "DiffRemove",
      condition = condition.hide_in_width,
      icon = icons.git.remove .. " ",
      highlight = { colors.error_red, colors.bg },
    },
  }
  gls.left[13] = {
    Space = {
      provider = function()
        return " "
      end,
      highlight = { colors.statusline_section_bg, colors.bg },
    },
  }
  gls.left[14] = {
    DiagnosticError = {
      provider = "DiagnosticError",
      icon = " " .. icons.lsp.error .. " ",
      highlight = { colors.pale_red, colors.bg },
    },
  }
  gls.left[15] = {
    DiagnosticWarn = {
      provider = "DiagnosticWarn",
      icon = " " .. icons.lsp.warn .. " ",
      highlight = { colors.orange, colors.bg },
    },
  }
  gls.left[16] = {
    DiagnosticInfo = {
      provider = "DiagnosticInfo",
      icon = " " .. icons.lsp.info .. " ",
      highlight = { colors.blue, colors.bg },
    },
  }

  gls.left[17] = {
    DiagnosticHint = {
      provider = "DiagnosticHint",
      icon = " " .. icons.lsp.hint .. " ",
      highlight = { colors.dark_green, colors.bg },
    },
  }

  local function get_attached_provider_name(msg)
    msg = msg or "LSP Inactive"

    local buf_clients = vim.lsp.buf_get_clients()
    if next(buf_clients) == nil then
      -- TODO: clean up this if statement
      if type(msg) == "boolean" or #msg == 0 then
        return "LS Inactive"
      end
      return msg
    end

    -- local buf_ft = vim.bo.filetype
    local buf_client_names = {}
    for _, client in pairs(buf_clients) do
      if client.name ~= "null-ls" then
        table.insert(buf_client_names, client.name)
      end
    end

    -- add formatter
    -- local formatters = require "user.lsp.null-ls.formatters"
    -- local supported_formatters = formatters.list_registered(buf_ft)
    -- vim.list_extend(buf_client_names, supported_formatters)

    -- add linter
    -- local linters = require "user.lsp.null-ls.linters"
    -- local supported_linters = linters.list_registered(buf_ft)
    -- vim.list_extend(buf_client_names, supported_linters)

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
      icon = icons.misc.dot .. " ",
      highlight = { colors.statusline_fg, colors.bg },
      separator = " ",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }

  gls.right[2] = {
    TreesitterIcon = {
      provider = function()
        if next(vim.treesitter.highlighter.active) ~= nil then
          return icons.misc.tree .. "  " .. vim.bo.filetype
        end
        return vim.bo.filetype
      end,
      condition = hide_in_width,
      highlight = { colors.statusline_fg, colors.bg },
      separator = " | ",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }

  gls.right[3] = {
    Tabstop = {
      provider = function()
        return "Spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
      end,
      condition = hide_in_width,
      highlight = { colors.statusline_fg, colors.bg },
      separator = " | ",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }

  gls.right[4] = {
    LineInfo = {
      provider = "LineColumn",
      condition = function()
        return vim.bo.filetype ~= "dashboard"
      end,
      highlight = { colors.statusline_fg, colors.bg },
      separator = " | ",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }

  gls.right[5] = {
    FileFormat = {
      provider = "FileFormat",
      condition = hide_in_width,
      highlight = { colors.statusline_fg, colors.bg },
      separator = " | ",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }

  gls.right[6] = {
    FileEncode = {
      provider = "FileEncode",
      condition = hide_in_width,
      highlight = { colors.statusline_fg, colors.bg },
      separator = " |",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }

  gls.right[7] = {
    PerCent = {
      provider = "LinePercent",
      condition = function()
        return vim.bo.filetype ~= "dashboard"
      end,
      highlight = { colors.statusline_fg, colors.bg },
      separator = " | ",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }

  gls.right[8] = {
    RainbowBlue = {
      provider = function()
        return icons.statusline.bar
      end,
      separator = "",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
      highlight = { colors.pale_blue, colors.bg },
    },
  }

  -- Short status line
  gls.short_line_left[1] = {
    BufferType = {
      provider = "FileName",
      highlight = { colors.statusline_fg, colors.bg },
      separator = "",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }

  gls.short_line_right[2] = {
    BufferIcon = {
      provider = "BufferIcon",
      highlight = { colors.light_yellow, colors.bg },
      separator = "",
      separator_highlight = { colors.statusline_section_bg, colors.bg },
    },
  }
end
