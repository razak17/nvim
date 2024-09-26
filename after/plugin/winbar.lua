if
  not ar
  or ar.none
  or not ar.ui.winbar.enable
  or not ar.ui.winbar.variant == 'local'
then
  return
end

-- Ref: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/options.lua?plain=1#L41

local fn, api, opt, bo = vim.fn, vim.api, vim.opt, vim.bo
local decor = ar.ui.decorations

-- Function to get the full path and replace the home directory with ~
local function get_winbar_path()
  local full_path = fn.expand('%:p')
  return full_path:gsub(fn.expand('$HOME'), '~')
end
-- Function to get the number of open buffers using the :ls command
local function get_buffer_count()
  local buffers = fn.execute('ls')
  local count = 0
  -- Match only lines that represent buffers, typically starting with a number followed by a space
  for line in string.gmatch(buffers, '[^\r\n]+') do
    if string.match(line, '^%s*%d+') then count = count + 1 end
  end
  return count
end
-- Function to update the winbar
function ar.ui.winbar.render()
  local home_replaced = get_winbar_path()
  local buffer_count = get_buffer_count()
  return '%#Debug#%m '
    .. '%#Directory#('
    .. buffer_count
    .. ') '
    .. '%#Normal#'
    .. home_replaced
    .. '%*%=%#Normal#'
    .. fn.systemlist('hostname')[1]
end

opt.winbar = [[%!v:lua.ar.ui.winbar.render()]]

api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'FileType' }, {
  callback = function(args)
    local d = decor.get({
      ft = bo[args.buf].ft,
      bt = bo[args.buf].bt,
      fname = fn.bufname(args.buf),
      setting = 'winbar',
    })
    if not d or ar.falsy(d) then return end
    if d.ft == false or d.bt == false or d.fname == false then
      vim.opt_local.winbar = ' '
    end
  end,
})
