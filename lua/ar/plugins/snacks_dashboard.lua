local fn = vim.fn

local dashboard = {
  enabled = ar_config.dashboard.enable
    and ar_config.dashboard.variant == 'snacks',
  width = 60,
  row = nil, -- dashboard position. nil for center
  col = nil, -- dashboard position. nil for center
  pane_gap = 4, -- empty columns between vertical panes
  autokeys = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', -- autokey sequence
  -- These settings are used by some built-in sections
  preset = {
    -- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
    ---@type fun(cmd:string, opts:table)|nil
    pick = nil,
    -- Used by the `keys` section to show keymaps.
    -- Set your custom keymaps here.
    -- When using a function, the `items` argument are the default keymaps.
    ---@type snacks.dashboard.Item[]
    keys = {
      {
        icon = ' ',
        key = 's',
        desc = 'Restore Session',
        section = 'session',
      },
      {
        icon = '󰋇 ',
        key = 'p',
        desc = 'Pick Session',
        action = '<Cmd>ListSessions<CR>',
      },
      {
        icon = ' ',
        key = 'r',
        desc = 'Recent Files',
        action = ":lua Snacks.dashboard.pick('oldfiles')",
      },
      {
        icon = ' ',
        key = 'f',
        desc = 'Find File',
        action = ":lua Snacks.dashboard.pick('files')",
      },
      {
        icon = ' ',
        key = 'w',
        desc = 'Find Text',
        action = ":lua Snacks.dashboard.pick('live_grep')",
      },
      -- {
      --   icon = ' ',
      --   key = 'n',
      --   desc = 'New File',
      --   action = ':ene | startinsert',
      -- },
      {
        icon = ' ',
        key = 'c',
        desc = 'Config',
        action = ":lua Snacks.dashboard.pick('files', {cwd = fn.stdpath('config')})",
      },
      {
        icon = '󰒲 ',
        key = 'l',
        desc = 'Lazy',
        action = ':Lazy',
        enabled = package.loaded.lazy ~= nil,
      },
      { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
    },
    -- Used by the `header` section
    header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
  },
  formats = {
    icon = function(item) return { item.icon, width = 2, hl = 'icon' } end,
    footer = { '%s', align = 'center' },
    header = { '%s', align = 'center' },
    file = function(item, ctx)
      local fname = fn.fnamemodify(item.file, ':~')
      fname = ctx.width and #fname > ctx.width and fn.pathshorten(fname)
        or fname
      if #fname > ctx.width then
        local dir = fn.fnamemodify(fname, ':h')
        local file = fn.fnamemodify(fname, ':t')
        if dir and file then
          file = file:sub(-(ctx.width - #dir - 2))
          fname = dir .. '/…' .. file
        end
      end
      local dir, file = fname:match('^(.*)/(.+)$')
      return dir and { { dir .. '/', hl = 'dir' }, { file, hl = 'file' } }
        or { { fname, hl = 'file' } }
    end,
  },
  -- item field formatters,
  sections = {
    { section = 'header' },
    { section = 'keys', gap = 1, padding = 1 },
    { section = 'startup' },
  },
}

return {
  desc = 'snacks dashboard',
  recommended = true,
  'folke/snacks.nvim',
  opts = function(_, opts)
    return vim.tbl_deep_extend('force', opts or {}, {
      dashboard = dashboard,
    })
  end,
}
