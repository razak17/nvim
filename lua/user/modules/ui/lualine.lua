return function()
  local conditions = {
    buffer_not_empty = function()
      return vim.fn.empty(vim.fn.expand "%:t") ~= 1
    end,
    hide_in_width = function()
      return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
      local filepath = vim.fn.expand "%:p:h"
      local gitdir = vim.fn.finddir(".git", filepath .. ";")
      return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
  }

  local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
      return {
        added = gitsigns.added,
        modified = gitsigns.changed,
        removed = gitsigns.removed,
      }
    end
  end

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

  local P = rvim.palette
  local icons = rvim.style.icons

  -- Config
  local config = {
    options = {
      -- Disable sections and component separators
      component_separators = "",
      section_separators = "",
      theme = {
        -- We are going to use lualine_c an lualine_x as left and
        -- right section. Both are highlighted by c theme .  So we
        -- are just setting default looks o statusline
        normal = { c = { fg = P.statusline_fg, bg = P.statusline_section_bg } },
        inactive = { c = { fg = P.statusline_fg, bg = P.statusline_section_bg } },
      },
    },
    sections = {
      -- these are to remove the defaults
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      -- These will be filled later
      lualine_c = {},
      lualine_x = {},
    },
    inactive_sections = {
      -- these are to remove the defaults
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      lualine_c = {},
      lualine_x = {},
    },
  }

  -- Inserts a component in lualine_c at left section
  local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
  end

  -- Inserts a component in lualine_x ot right section
  local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
  end

  ins_left {
    function()
      return icons.statusline.bar
    end,
    color = { fg = P.pale_blue }, -- Sets highlighting of component
    padding = { left = 0, right = 1 }, -- We don't need space before this
  }

  ins_left {
    -- mode component
    function()
      return icons.statusline.mode
    end,
    color = function()
      -- auto change color according to neovims mode
      local mode_color = {
        n = P.red,
        i = P.green,
        v = P.blue,
        [""] = P.pale_blue,
        V = P.pale_blue,
        c = P.magenta,
        no = P.pale_red,
        s = P.orange,
        S = P.orange,
        [""] = P.orange,
        ic = P.yellow,
        R = P.violet,
        Rv = P.violet,
        cv = P.pale_red,
        ce = P.pale_red,
        r = P.cyan,
        rm = P.cyan,
        ["r?"] = P.cyan,
        ["!"] = P.pale_red,
        t = P.red,
      }
      return { fg = mode_color[vim.fn.mode()] }
    end,
    padding = { right = 1 },
  }

  ins_left {
    -- filesize component
    "filesize",
    cond = conditions.buffer_not_empty,
    color = { fg = P.statusline_fg },
  }

  ins_left {
    "filename",
    cond = conditions.buffer_not_empty,
    color = { fg = P.statusline_fg },
  }

  ins_left {
    "branch",
    -- "b:gitsigns_head",
    icon = icons.git.branch,
    color = { fg = P.dark_green },
    cond = conditions.hide_in_width,
  }

  ins_left {
    "diff",
    source = diff_source,
    -- Is it me or the symbol for modified us really weird
    symbols = {
      added = icons.git.added .. " ",
      modified = icons.git.mod .. " ",
      removed = icons.git.removed .. " ",
    },
    diff_color = {
      added = { fg = P.yellowgreen },
      modified = { fg = P.dark_orange },
      removed = { fg = P.error_red },
    },
    cond = conditions.hide_in_width,
  }

  ins_right {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = {
      error = icons.lsp.error .. " ",
      warn = icons.lsp.warn .. " ",
      info = icons.lsp.info .. " ",
      hint = icons.lsp.hint .. " ",
    },
    diagnostics_color = {
      color_error = { fg = P.pale_red },
      color_warn = { fg = P.dark_orange },
      color_info = { fg = P.blue },
      color_hint = { fg = P.dark_green },
    },
  }

  ins_right {
    -- Lsp server name .
    function(msg)
      msg = msg or "LS Inactive"
      local buf_clients = vim.lsp.buf_get_clients()
      if next(buf_clients) == nil then
        -- TODO: clean up this if statement
        if type(msg) == "boolean" or #msg == 0 then
          return "LS Inactive"
        end
        return msg
      end
      local buf_client_names = {}

      -- add client
      for _, client in pairs(buf_clients) do
        if client.name ~= "null-ls" then
          table.insert(buf_client_names, client.name)
        end
      end

      return table.concat(buf_client_names, " • ")
    end,
    colors = { fg = P.statusline_fg },
    cond = conditions.hide_in_width,
  }

  ins_right {
    function()
      local b = vim.api.nvim_get_current_buf()
      if next(vim.treesitter.highlighter.active[b]) then
        return icons.misc.tree
      end
      return ""
    end,
  }

  ins_right {
    "filetype",
    icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
    cond = conditions.hide_in_width,
    color = {},
  }

  ins_right {
    function()
      if vim.bo.filetype == "python" then
        local venv = os.getenv "CONDA_DEFAULT_ENV"
        if venv then
          return string.format("(%s)", env_cleanup(venv))
        end
        venv = os.getenv "VIRTUAL_ENV"
        if venv then
          return string.format("(%s)", env_cleanup(venv))
        end
        return ""
      end
      return ""
    end,
    cond = conditions.hide_in_width,
  }

  -- ins_right {
  --   function()
  --     return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
  --   end,
  --   color = { fg = P.statusline_fg },
  -- }

  -- Add components to right sections
  ins_right {
    "o:encoding", -- option component same as &encoding in viml
    fmt = string.upper, -- I'm not sure why it's upper case either ;)
    cond = conditions.hide_in_width,
  }

  ins_right {
    "fileformat",
    fmt = string.upper,
    icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
    cond = conditions.hide_in_width,
  }

  ins_right { "location" }

  ins_right { "progress", color = { fg = P.statusline_fg, gui = "bold" } }

  ins_right {
    function()
      return icons.statusline.bar
    end,
    color = { fg = P.pale_blue },
    padding = { left = 1 },
  }

  -- Now don't forget to initialize lualine
  local lualine = require "lualine"
  lualine.setup(config)
end
