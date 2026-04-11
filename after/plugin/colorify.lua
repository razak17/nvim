-- All credits to the original code in nvchad/ui
-- Ref; https://github.com/NvChad/ui/blob/ec5b1f8e591b2e8f1cd3653b41bb14d9cd43dfd1/lua/nvchad/colorify/init.lua?plain=1#L9

if not ar then return end

local enabled = ar.config.plugin.custom.colorify.enable and not ar.lsp.enable

if ar.none or not enabled then return end

local api, fn = vim.api, vim.fn
local L = vim.log.levels
local get_extmarks = api.nvim_buf_get_extmarks
local set_extmark = api.nvim_buf_set_extmark

local ns = api.nvim_create_namespace('Colorify')

local M = {}

local config = {
  enabled = true,
  mode = 'virtual', -- fg, bg, virtual
  virt_text = ar.ui.icons.misc.block_medium .. ' ',
  highlight = { hex = true, lspvars = true },
}

local modes = { 'virtual', 'fg', 'bg' }

local function is_dark(hex)
  hex = hex:gsub('#', '')

  local r, g, b =
    tonumber(hex:sub(1, 2), 16),
    tonumber(hex:sub(3, 4), 16),
    tonumber(hex:sub(5, 6), 16)
  local brightness = (r * 299 + g * 587 + b * 114) / 1000

  return brightness < 128
end

local function add_hl(hex)
  local name = string.format('hex_%s_%s', config.mode, hex:sub(2))

  if api.nvim_get_hl(0, { name = name }).fg then return name end

  local fg, bg = hex, hex

  if config.mode == 'bg' then
    fg = is_dark(hex) and 'white' or 'black'
  else
    bg = 'none'
  end

  api.nvim_set_hl(0, name, { fg = fg, bg = bg, default = true })
  return name
end

local function needs_hl(buf, linenr, col, hl_group, opts)
  local ms = get_extmarks(
    buf,
    ns,
    { linenr, col },
    { linenr, opts.end_col },
    { details = true }
  )

  if #ms == 0 then return true end

  ms = ms[1]
  opts.id = ms[1]
  return hl_group ~= (ms[4].hl_group or ms[4].virt_text[1][2])
end

local function del_extmarks_on_textchange(buf)
  vim.b[buf].colorify_attached = true

  api.nvim_buf_attach(buf, false, {
    -- s = start, e == end
    -- stylua: ignore
    on_bytes = function(_, b, _, s_row, s_col, _, old_e_row, old_e_col, _, _, new_e_col, _)
      -- old_e_row = old deleted lines!
      -- new_e_col isnt 0 when cursor pos has changed
      if old_e_row == 0 and new_e_col == 0 and old_e_col == 0 then
        return
      end

      local row1, col1, row2, col2

      if old_e_row > 0 then
        row1, col1, row2, col2 = s_row, 0, s_row + old_e_row, 0
      else
        row1, col1, row2, col2 = s_row, s_col, s_row, s_col + old_e_col
      end

      if api.nvim_get_mode().mode ~= "i" then
        col1, col2 = 0, -1
      end

      local ms = get_extmarks(b, ns, { row1, col1 }, { row2, col2 }, { overlap = true })

      for _, mark in ipairs(ms) do
        api.nvim_buf_del_extmark(b, ns, mark[1])
      end
    end,
    on_detach = function() vim.b[buf].colorify_attached = false end,
  })
end

local function set_hex(buf, line, str)
  for col, hex in str:gmatch('()(#%x%x%x%x%x%x)') do
    col = col - 1
    local hl_group = add_hl(hex)
    local end_col = col + 7

    local opts = { end_col = end_col, hl_group = hl_group }

    if config.mode == 'virtual' then
      opts.hl_group = nil
      opts.virt_text_pos = 'inline'
      opts.virt_text = { { config.virt_text, hl_group } }
    end

    if needs_hl(buf, line, col, hl_group, opts) then
      set_extmark(buf, ns, line, col, opts)
    end
  end
end

local function lsp_var(buf, line, min, max)
  local param = { textDocument = vim.lsp.util.make_text_document_params(buf) }

  for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
    local m = vim.lsp.protocol.Methods
    if client:supports_method(m.textDocument_documentColor) then
      client:request(m.textDocument_documentColor, param, function(_, resp)
        if resp and line then
          resp = vim.tbl_filter(
            function(v) return v.range['start'].line == line end,
            resp
          )
        end

        if resp and min then
          resp = vim.tbl_filter(
            function(v)
              return v.range['start'].line >= min and v.range['end'].line <= max
            end,
            resp
          )
        end

        for _, match in ipairs(resp or {}) do
          local color = match.color
          local r, g, b, a = color.red, color.green, color.blue, color.alpha
          if a > 1 then a = a / 255 end
          local hex = string.format(
            '#%02x%02x%02x',
            r * a * 255,
            g * a * 255,
            b * a * 255
          )

          local hl_group = add_hl(hex)

          local range_start = match.range.start
          local range_end = match.range['end']

          local opts = { end_col = range_end.character, hl_group = hl_group }

          if config.mode == 'virtual' then
            opts.hl_group = nil
            opts.virt_text_pos = 'inline'
            opts.virt_text = { { config.virt_text, hl_group } }
          end

          if
            needs_hl(
              buf,
              range_start.line,
              range_start.character,
              hl_group,
              opts
            )
          then
            pcall(
              set_extmark,
              buf,
              ns,
              range_start.line,
              range_start.character,
              opts
            )
          end
        end
      end, buf)
    end
  end
end

M.attach = function(buf, event)
  local winid = vim.fn.bufwinid(buf)

  local min = fn.line('w0', winid) - 1
  local max = fn.line('w$', winid) + 1

  if event == 'TextChangedI' then
    local cur_linenr = fn.line('.', winid) - 1

    if config.highlight.hex then
      set_hex(buf, cur_linenr, api.nvim_get_current_line())
    end

    if config.highlight.lspvars then lsp_var(buf, cur_linenr) end
    return
  end

  local lines = api.nvim_buf_get_lines(buf, min, max, false)

  if config.highlight.hex then
    for i, str in ipairs(lines) do
      set_hex(buf, min + i - 1, str)
    end
  end

  if config.highlight.lspvars then lsp_var(buf, nil, min, max) end

  if not vim.b[buf].colorify_attached then del_extmarks_on_textchange(buf) end
end

local function clear_colors()
  for _, buf in ipairs(api.nvim_list_bufs()) do
    api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
end

local function set_colors()
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    if vim.bo[buf].bl then M.attach(buf) end
  end
end

local function disable()
  config.enabled = false
  clear_colors()
  vim.notify('Colorify disabled', L.INFO, {
    title = 'Colorify',
  })
end

local function enable()
  config.enabled = true
  set_colors()
  vim.notify('Colorify enabled', L.INFO, {
    title = 'Colorify',
  })
end

local function toggle()
  if config.enabled then
    disable()
  else
    enable()
  end
end

local function refresh()
  clear_colors()
  set_colors()
end

local function set_mode(mode)
  if not vim.tbl_contains(modes, mode) then
    vim.notify('Invalid mode: ' .. mode, L.ERROR, {
      title = 'Colorify',
    })
    return
  end
  config.mode = mode
  refresh()
  vim.notify('Colorify mode: ' .. config.mode, L.INFO, {
    title = 'Colorify',
  })
end

local function cycle_mode()
  local idx = 1
  for i, mode in ipairs(modes) do
    if mode == config.mode then
      idx = i
      break
    end
  end
  set_mode(modes[(idx % #modes) + 1])
end

local function select_colorify_mode()
  vim.ui.select(modes, {
    prompt = 'Select Colorify Mode',
    format_item = function(item) return item end,
  }, function(choice)
    if choice then set_mode(choice) end
  end)
end

ar.command('Colorify', function(args)
  local action = args.fargs[1]

  if not action or action == 'toggle' then
    toggle()
    return
  end

  if action == 'cycle' then
    cycle_mode()
    return
  end

  if action == 'select' then
    select_colorify_mode()
    return
  end

  if action == 'mode' then
    local mode = args.fargs[2]

    if not mode then
      vim.notify('Usage: Colorify mode <mode>', L.ERROR, {
        title = 'Colorify',
      })
      return
    end

    set_mode(mode)
    return
  end

  vim.notify('Usage: Colorify [toggle|cycle|select|mode <mode>]', L.ERROR, {
    title = 'Colorify',
  })
end, {
  nargs = '*',
  desc = 'toggle colorify, cycle mode, or set a mode',
  complete = function(arg, line)
    local actions = { 'toggle', 'cycle', 'select', 'mode' }
    local items = actions

    if line:match('^%S+%s+mode%s+') then items = modes end

    return vim.tbl_filter(function(item) return item:find(arg) == 1 end, items)
  end,
})

ar.augroup('Colorify', {
  event = {
    'TextChanged',
    'TextChangedI',
    'TextChangedP',
    'VimResized',
    'LspAttach',
    'WinScrolled',
    'BufEnter',
    'BufRead',
  },
  command = function(args)
    if not config.enabled then return end
    if vim.bo[args.buf].bl then M.attach(args.buf, args.event) end
  end,
})
