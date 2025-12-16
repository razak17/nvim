if
  not ar
  or ar.none
  or not ar.config.ui.winbar.enable
  or (ar.config.ui.winbar.variant ~= 'local' and not ar.plugins.minimal)
then
  return
end

-- Ref: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/options.lua?plain=1#L41

local config = {
  show_hostname = false,
  show_buffer_count = true,
  pretty_path = true,
}

ar.ui.winbar = {}

local fn, bo = vim.fn, vim.bo
local decor = ar.ui.decorations

local function get_winbar_path()
  local full_path = fn.expand('%:p')
  return full_path:gsub(fn.expand('$HOME'), '~')
end

local function get_buffer_count()
  local buffers = fn.execute('ls')
  local count = 0
  -- Match only lines that represent buffers, typically starting with a number followed by a space
  for line in string.gmatch(buffers, '[^\r\n]+') do
    if string.match(line, '^%s*%d+') then count = count + 1 end
  end
  return count
end

function ar.ui.winbar.render()
  local home_replaced = get_winbar_path()
  local pretty_path = require('ar.pretty_path').pretty_path()
  local buffer_count = get_buffer_count()
  local host = fn.systemlist('hostname')[1]

  local left = '%#Debug#%m '
  local buf_count = '%#Directory#(' .. buffer_count .. ') '
  local file_path = '%#Normal#' .. home_replaced .. '%*%='
  if config.pretty_path and pretty_path ~= '' then
    file_path = '%#Normal#' .. pretty_path.dir .. pretty_path.name .. '%*%='
  end
  local hostname = '%#Normal#' .. host

  return table.concat({
    left,
    config.show_buffer_count and buf_count or '',
    file_path,
    config.show_hostname and hostname or '',
  }, '')
end

-- vim.opt.winbar = [[%!v:lua.ar.ui.winbar.render()]]

ar.augroup('Winbar', {
  event = { 'BufEnter', 'WinEnter', 'FileType' },
  command = function(args)
    local ft = bo[args.buf].ft
    if not ft or ft == '' then return end
    local d = decor.get({
      ft = bo[args.buf].ft,
      bt = bo[args.buf].bt,
      fname = fn.bufname(args.buf),
      setting = 'winbar',
    })
    if not d or ar.falsy(d) then
      vim.wo.winbar = ar.ui.winbar.render()
      return
    end
    if d.ft == false or d.bt == false or d.fname == false then
      vim.wo.winbar = ''
    end
  end,
})
