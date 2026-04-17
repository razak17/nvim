if not ar then return end

local enabled = ar.config.dashboard.variant == 'legacy'

if ar.none or not enabled then return end

-- https://www.reddit.com/r/neovim/comments/1sa19di/can_we_remove_the_ascii_art_from_the_new_intro_in/

local api, fn = vim.api, vim.fn

if vim.fn.argc() > 0 then return end

local vim_version = vim.version()
if vim_version.minor < 12 then return end

local intro_version = vim.split(
  api.nvim_exec2('version', { output = true }).output,
  '\n',
  { plain = true }
)[1]

--[[
The idea is to create a floating window
with the text the same as the old intro,
and then dismiss this floating window when
we enter insert mode, load a file into the buffer,
or move the cursor to another window.
The latter avoids weird behaviour if we open a new
split. The old intro also disappeared when doing this.
]]

vim.opt.shortmess:append('I')

local function set_intro_highlights()
  ar.highlight.plugin('ClassicIntro', {
    { IntroTitle = { link = 'SpecialKey' } },
    { IntroText = { fg = { from = 'Normal', alter = -0.1 } } },
  })
end

local intro = {
  win = nil,
  buf = nil,
  ns = nil,
  text = nil,
  group = nil,
}

intro.ns = api.nvim_create_namespace('IntroOverlayNS')
intro.group = api.nvim_create_augroup('IntroOverlay', { clear = true })

intro.text = {
  { { '' } },
  { { '' } },
  { { '' } },
  { { '' } },
  { { '' } },
  { { '' } },
  { { '' } },
  { { '' } },
  { { '' } },
  { { '' } },
  { { ('     %s'):format(intro_version), 'IntroTitle' } },
  { { '' } },
  { { ' Nvim is open source and freely distributable', 'IntroText' } },
  { { '           https://neovim.io/#chat', 'IntroTitle' } },
  { { '' } },
  {
    { 'type  :help nvim', 'IntroText' },
    { '<Enter>', 'IntroTitle' },
    { '       if you are new!', 'IntroText' },
  },
  {
    { 'type  :checkhealth', 'IntroText' },
    { '<Enter>', 'IntroTitle' },
    { '     to optimize Nvim', 'IntroText' },
  },
  {
    { 'type  :q', 'IntroText' },
    { '<Enter>', 'IntroTitle' },
    { '               to exit', 'IntroText' },
  },
  {
    { 'type  :help', 'IntroText' },
    { '<Enter>', 'IntroTitle' },
    { '            for help', 'IntroText' },
  },
  { { '' } },
  {
    { 'type  :help news', 'IntroText' },
    { '<Enter>', 'IntroTitle' },
    {
      (' to see changes in v%d.%d'):format(
        vim_version.major,
        vim_version.minor
      ),
      'IntroText',
    },
  },
  { { '' } },
  { { '        Help poor children in Uganda!', 'IntroText' } },
  {
    { 'type  :help Kuwasha', 'IntroText' },
    { '<Enter>', 'IntroTitle' },
    { '     for information', 'IntroText' },
  },
}

local function create_intro_buf()
  local buf = api.nvim_create_buf(false, true)

  for i, text in ipairs(intro.text) do
    api.nvim_buf_set_lines(buf, i - 1, i - 1, false, { '' })
    api.nvim_buf_set_extmark(buf, intro.ns, i - 1, 0, {
      virt_text = text,
      virt_text_pos = 'overlay',
    })
  end

  return buf
end

local function create_intro_win(row, col, width, height)
  local win = api.nvim_open_win(intro.buf, false, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'none',
    focusable = false,
    noautocmd = true,
  })
  -- This set the same background color for the intro
  -- floating window as your normal background,
  -- so the floating window appears to be transparent.
  vim.wo[win].winhighlight = 'NormalFloat:Normal'
  return win
end

local function hide_intro()
  if intro.win and api.nvim_win_is_valid(intro.win) then
    api.nvim_win_close(intro.win, true)
    intro.win = nil
  end
end

local function render_intro()
  if not intro.buf or not api.nvim_buf_is_valid(intro.buf) then
    intro.buf = create_intro_buf()
  end

  local width = 0
  for _, line in ipairs(intro.text) do
    local line_width = 0
    for _, chunk in ipairs(line) do
      line_width = line_width + fn.strdisplaywidth(chunk[1])
    end
    width = math.max(width, line_width)
  end
  local height = #intro.text

  -- I'm subtracting one to respect the ~ in the signal column
  local usable_width = vim.o.columns - 1

  -- Hide the intro if terminal is too small.
  -- That + 6 is also kind of magical, and without it,
  -- the intro gets too squished before closing it if the
  -- terminal window gets too short.
  if usable_width < width or vim.o.lines < height + 6 then
    hide_intro()
    return
  end

  local row = math.floor((vim.o.lines - height) / 3)
  local col = math.floor((usable_width - width) / 2) + 2

  if not intro.win or not api.nvim_win_is_valid(intro.win) then
    intro.win = create_intro_win(row, col, width, height)
    return
  end

  api.nvim_win_set_config(intro.win, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
  })
end

local function cleanup_intro()
  hide_intro()

  if intro.group then
    -- When opening some help pages, this augroup deletion
    -- raised some error saying the augroup was already deleted...
    -- But this didn't happend when opening a file or a split or by
    -- typing or by opening standalone :h.
    -- I don't know what causes it, but I wrapped in a pcall to
    -- silently ignore it. Error handling at its finest.
    pcall(api.nvim_del_augroup_by_id, intro.group)
    intro.group = nil
  end

  if intro.buf and api.nvim_buf_is_valid(intro.buf) then
    if intro.ns then
      api.nvim_buf_clear_namespace(intro.buf, intro.ns, 0, -1)
      intro.ns = nil
    end

    api.nvim_buf_delete(intro.buf, { force = true })
    intro.buf = nil
  end

  intro.win = nil
  intro.text = nil
end

api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    set_intro_highlights()
    render_intro()

    api.nvim_create_autocmd('VimResized', {
      group = intro.group,
      callback = render_intro,
    })

    -- If you want to recolor the intro when changing colorscheme,
    -- uncomment the following block of code.
    -- api.nvim_create_autocmd('ColorScheme', {
    --   group = intro.group,
    --   callback = set_intro_highlights,
    -- })

    api.nvim_create_autocmd({
      'InsertCharPre',
      'BufReadPre',
      'CursorMoved',
    }, {
      group = intro.group,
      once = true,
      callback = function()
        -- InsertCharPre raises some error when we try to
        -- close a window during that event, so I used
        -- vim.schedule to avoid the so called "textlock",
        -- as :h vim.schedule itself suggests.
        vim.schedule(cleanup_intro)
      end,
    })
  end,
})
