local enabled = ar.config.plugin.custom.cheatsheet.enable

if not ar or ar.none or not enabled then return end

local api, fn = vim.api, vim.fn
local strw = api.nvim_strwidth
local opt_local = api.nvim_set_option_value
local genstr = string.rep
local gapx = 10

local config = {
  excluded_groups = { 'terminal (t)', 'autopairs', 'Nvim', 'Opens' },
  theme = 'grid', -- 'grid', 'simple'
  state = {
    mappings_tb = {},
  },
  simple = {
    heading = {
      '█▀▀ █░█ █▀▀ ▄▀█ ▀█▀ █▀ █░█ █▀▀ █▀▀ ▀█▀',
      '█▄▄ █▀█ ██▄ █▀█ ░█░ ▄█ █▀█ ██▄ ██▄ ░█░',
    },
  },
  grid = {
    ascii = {
      '                                      ',
      '                                      ',
      '                                      ',
      '█▀▀ █░█ █▀▀ ▄▀█ ▀█▀ █▀ █░█ █▀▀ █▀▀ ▀█▀',
      '█▄▄ █▀█ ██▄ █▀█ ░█░ ▄█ █▀█ ██▄ ██▄ ░█░',
      '                                      ',
      '                                      ',
      '                                      ',
    },
  },
}
ar.highlight.plugin('Cheatsheet', {
  {
    NvChHeading = {
      fg = { from = 'Dim', alter = -0.5 },
      bg = { from = 'Directory', attr = 'fg' },
    },
  },
  { NvChAsciiHeader = { link = 'Debug' } },
  { NvChSection = { bg = { from = 'CodeBlock' } } },
  { NvChHeadblue = { bg = '#61AFEF', fg = '#282C34' } },
  { NvChHeadred = { bg = '#E06C75', fg = '#282C34' } },
  { NvChHeadgreen = { bg = '#98C379', fg = '#282C34' } },
  { NvChHeadyellow = { bg = '#E5C07B', fg = '#282C34' } },
  { NvChHeadorange = { bg = '#D19A66', fg = '#282C34' } },
  { NvChHeadbaby_pink = { bg = '#FF6AC1', fg = '#282C34' } },
  { NvChHeadpurple = { bg = '#C678DD', fg = '#282C34' } },
  { NvChHeadwhite = { bg = '#ABB2BF', fg = '#282C34' } },
  { NvChHeadcyan = { bg = '#56B6C2', fg = '#282C34' } },
  { NvChHeadvibrant_green = { bg = '#98C379', fg = '#282C34' } },
  { NvChHeadteal = { bg = '#008080', fg = '#b3deef' } },
})

local function capitalize(str) return (str:gsub('^%l', string.upper)) end

local function set_cleanbuf_opts(ft, buf)
  opt_local('buflisted', false, { buf = buf })
  opt_local('modifiable', false, { buf = buf })
  opt_local('buftype', 'nofile', { buf = buf })
  opt_local('number', false, { scope = 'local' })
  opt_local('list', false, { scope = 'local' })
  opt_local('wrap', false, { scope = 'local' })
  opt_local('relativenumber', false, { scope = 'local' })
  opt_local('cursorline', false, { scope = 'local' })
  opt_local('colorcolumn', '0', { scope = 'local' })
  opt_local('foldcolumn', '0', { scope = 'local' })
  opt_local('ft', ft, { buf = buf })
  vim.g[ft .. '_displayed'] = true
end

local function get_mappings(mappings, tb_to_add)
  local excluded_groups = config.excluded_groups

  for _, v in ipairs(mappings) do
    local desc = v.desc

    -- don't include mappings which have \n in their desc
    if
      not desc
      or (select(2, desc:gsub('%S+', '')) <= 1)
      or string.find(desc, '\n')
    then
      goto continue
    end

    local heading = desc:match('%S+') -- get first word
    heading = (v.mode ~= 'n' and heading .. ' (' .. v.mode .. ')') or heading

    -- useful for removing groups || <Plug> lhs keymaps from cheatsheet
    if
      vim.tbl_contains(excluded_groups, heading)
      or vim.tbl_contains(excluded_groups, desc:match('%S+'))
      or string.find(v.lhs, '<Plug>')
    then
      goto continue
    end

    heading = capitalize(heading)

    if not tb_to_add[heading] then tb_to_add[heading] = {} end

    local keybind = string.sub(v.lhs, 1, 1) == ' ' and '<leader> +' .. v.lhs
      or v.lhs

    desc = v.desc:match('%s(.+)') -- remove first word from desc
    desc = capitalize(desc)

    table.insert(tb_to_add[heading], { desc, keybind })

    ::continue::
  end
end

local function organize_mappings()
  local tb_to_add = {}
  local modes = { 'n', 'i', 'v', 't' }

  for _, mode in ipairs(modes) do
    local keymaps = api.nvim_get_keymap(mode)
    get_mappings(keymaps, tb_to_add)

    local bufkeymaps = api.nvim_buf_get_keymap(0, mode)
    get_mappings(bufkeymaps, tb_to_add)
  end

  return tb_to_add

  -- remove groups which have only 1 mapping
  -- for key, x in pairs(tb_to_add) do
  --   if #x <= 1 then
  --     tb_to_add[key] = nil
  --   end
  -- end
end

local function autocmds(buf)
  set_cleanbuf_opts('nvcheatsheet', buf)

  local group_id = api.nvim_create_augroup('NvCh', { clear = true })

  api.nvim_create_autocmd('BufWinLeave', {
    group = group_id,
    buffer = buf,
    callback = function()
      vim.g.nvcheatsheet_displayed = false
      api.nvim_del_augroup_by_name('NvCh')
    end,
  })

  api.nvim_create_autocmd({ 'WinResized', 'VimResized' }, {
    group = group_id,
    callback = function()
      config.commands[config.theme](vim.g.nvch_buf, vim.g.nvch_win, 'redraw')
    end,
  })

  vim.keymap.set('n', 'q', '<Cmd>bdel<CR>', { buffer = buf })
  vim.keymap.set('n', '<ESC>', '<Cmd>bdel<CR>', { buffer = buf })

  vim.g.nvch_buf = buf
  vim.g.nvch_win = fn.bufwinid(buf)
end

local function rand_hlgroup()
  local hlgroups = {
    'blue',
    'red',
    'green',
    'yellow',
    'orange',
    'baby_pink',
    'purple',
    'white',
    'cyan',
    'vibrant_green',
    'teal',
  }

  return 'NvChHead' .. hlgroups[math.random(1, #hlgroups)]
end

local function grid(buf, win, action)
  action = action or 'open'

  local ns = api.nvim_create_namespace('nvcheatsheet')

  if action == 'open' then config.state.mappings_tb = organize_mappings() end

  buf = buf or api.nvim_create_buf(false, true)
  win = win or api.nvim_get_current_win()

  api.nvim_set_current_win(win)

  -- add left padding (strs) to ascii so it looks centered
  local ascii_header = vim.tbl_values(config.grid.ascii)
  local ascii_padding = (api.nvim_win_get_width(win) / 2)
    - (#ascii_header[1] / 2)

  for i, str in ipairs(ascii_header) do
    ascii_header[i] = string.rep(' ', ascii_padding) .. str
  end

  local ascii_headerlen = #ascii_header

  vim.bo[buf].ma = true

  local column_width = 0

  for _, section in pairs(config.state.mappings_tb) do
    for _, mapping in pairs(section) do
      local txt = fn.strdisplaywidth(mapping[1] .. mapping[2])
      column_width = column_width > txt and column_width or txt
    end
  end

  -- 10 = space between mapping txt , 4 = 2 & 2 space around mapping txt
  column_width = column_width + 10

  local win_width = vim.o.columns
    - fn.getwininfo(api.nvim_get_current_win())[1].textoff
    - 6
  local columns_qty = math.floor(win_width / column_width)
  columns_qty = (win_width / column_width < 10 and columns_qty == 0) and 1
    or columns_qty
  column_width = math.floor(
    (win_width - (column_width * columns_qty)) / columns_qty
  ) + column_width

  -- add mapping tables with their headings as key names
  local cards = {}
  local emptyline = string.rep(' ', column_width)

  for name, section in pairs(config.state.mappings_tb) do
    name = ' ' .. name .. ' '
    for _, mapping in ipairs(section) do
      if not cards[name] then cards[name] = {} end

      table.insert(cards[name], { { emptyline, 'nvchsection' } })

      local whitespace_len = column_width
        - 4
        - fn.strdisplaywidth(mapping[1] .. mapping[2])
      local pretty_mapping = mapping[1]
        .. string.rep(' ', whitespace_len)
        .. mapping[2]

      table.insert(
        cards[name],
        { { '  ' .. pretty_mapping .. '  ', 'nvchsection' } }
      )
    end
    table.insert(cards[name], { { emptyline, 'nvchsection' } })

    table.insert(cards[name], { { emptyline } })
  end

  -------------------------------------------- distribute cards into columns -------------------------------------------
  local entries = {}

  for key, value in pairs(cards) do
    local headerlen = api.nvim_strwidth(key)
    local pad_l = math.floor((column_width - headerlen) / 2)
    local pad_r = column_width - headerlen - pad_l

    -- center the heading
    key = {
      { string.rep(' ', pad_l), 'nvchsection' },
      { key, rand_hlgroup() },
      { string.rep(' ', pad_r), 'nvchsection' },
    }

    table.insert(entries, { key, unpack(value) }) -- Create a table with the key and its values
  end

  local columns = {}
  local column_line_lens = {}

  for i = 1, columns_qty do
    columns[i] = {}
  end

  for index, entry in ipairs(entries) do
    local columnIndex = (index - 1) % columns_qty + 1
    table.insert(columns[columnIndex], entry)
    column_line_lens[columnIndex] = (column_line_lens[columnIndex] or 0)
      + #entry
  end

  ------------------------------------------ set empty lines & extemarks ------------------------------------------
  local max_col_height = math.max(unpack(column_line_lens)) + ascii_headerlen
  local emptylines = {}

  for _ = 1, max_col_height, 1 do
    local txt = string.rep(' ', win_width)
    table.insert(emptylines, txt)
  end

  if action == 'redraw' then api.nvim_buf_set_lines(buf, 0, -1, false, {}) end

  api.nvim_buf_set_lines(buf, 0, max_col_height, false, emptylines)

  for i, v in ipairs(ascii_header) do
    api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
      virt_text = { { v, 'NvChAsciiHeader' } },
      virt_text_pos = 'overlay',
    })
  end

  for col_i, column in ipairs(columns) do
    local row_i = ascii_headerlen - 1
    local col_start = (col_i - 1) * (column_width + (col_i == 1 and 0 or 2))

    for _, val in ipairs(column) do
      for i, v in ipairs(val) do
        api.nvim_buf_set_extmark(buf, ns, row_i + i, col_start, {
          virt_text = v,
          virt_text_pos = 'overlay',
        })
      end

      row_i = row_i + #val
    end
  end

  if action == 'redraw' then return end

  api.nvim_set_current_buf(buf)
  autocmds(buf)
end

api.nvim_create_autocmd('BufWinLeave', {
  callback = function()
    if vim.bo.ft == 'nvcheatsheet' then vim.g.nvcheatsheet_displayed = false end
  end,
})

local function simple(buf, win, action)
  action = action or 'open'

  local ns = api.nvim_create_namespace('nvcheatsheet')
  local win_w = api.nvim_win_get_width(0)

  if action == 'open' then
    config.state.mappings_tb = organize_mappings()
  else
    vim.bo[buf].ma = true
  end

  buf = buf or api.nvim_create_buf(false, true)
  win = win or api.nvim_get_current_win()

  api.nvim_set_current_win(win)

  -- Find largest string i.e mapping desc among all mappings
  local max_strlen = 0

  for _, section in pairs(config.state.mappings_tb) do
    for _, v in ipairs(section) do
      local curstrlen = strw(v[1]) + strw(v[2])
      max_strlen = max_strlen < curstrlen and curstrlen or max_strlen
    end
  end

  local box_w = max_strlen + gapx + 5

  local function addpadding(str)
    local pad = box_w - strw(str)
    local l_pad = math.floor(pad / 2)
    str = str:gsub('^%l', string.upper)
    return genstr(' ', l_pad) .. str .. genstr(' ', pad - l_pad)
  end

  local lines = {
    { genstr(' ', box_w), 'NvChAsciiHeader' },
    { addpadding(config.simple.heading[1]), 'NvChAsciiHeader' },
    { addpadding(config.simple.heading[2]), 'NvChAsciiHeader' },
    { genstr(' ', box_w), 'NvChAsciiHeader' },
    { '' },
  }

  local sections = vim.tbl_keys(config.state.mappings_tb)
  table.sort(sections)

  for _, name in ipairs(sections) do
    table.insert(lines, { addpadding(name), 'NvChHeading' })
    table.insert(lines, { genstr(' ', box_w), 'NvChSection' })

    for _, val in ipairs(config.state.mappings_tb[name]) do
      local pad = max_strlen - strw(val[1]) - strw(val[2]) + gapx
      local str = '  ' .. val[1] .. genstr(' ', pad) .. val[2] .. '   '

      table.insert(lines, { str, 'NvChSection' })
      table.insert(lines, { genstr(' ', #str), 'NvChSection' })
    end

    table.insert(lines, { '' })
  end

  local start_col = math.floor(win_w / 2) - math.floor(box_w / 2)

  -- make columns drawable
  for i = 1, #lines, 1 do
    api.nvim_buf_set_lines(buf, i, i, false, { string.rep(' ', win_w - 10) })
  end

  for row, val in ipairs(lines) do
    local opts = { virt_text_pos = 'overlay', virt_text = { val } }
    api.nvim_buf_set_extmark(buf, ns, row, start_col, opts)
  end

  if action ~= 'redraw' then
    api.nvim_set_current_buf(buf)
    autocmds(buf)
  end
end

config.commands = {
  grid = grid,
  simple = simple,
}

ar.command('CheatSheet', function(args)
  local theme = vim.trim(args.args or '')
  if theme == '' then theme = config.theme end
  if theme ~= 'grid' and theme ~= 'simple' then
    vim.notify('Invalid theme: ' .. theme, vim.log.levels.ERROR)
    return
  end
  config.theme = theme
  config.commands[config.theme]()
end, {
  nargs = '?',
  desc = 'Open the cheatsheet',
  complete = function() return { 'grid', 'simple' } end,
})

ar.add_to_select_menu('command_palette', {
  ['Cheatsheet (Grid)'] = 'CheatSheet grid',
  ['Cheatsheet (Simple)'] = 'CheatSheet simple',
})
