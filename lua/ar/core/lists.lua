if not ar then return end

local enabled = ar.config.plugin.core.lists.enable

if ar.none or not enabled then return end

---------------------------------------------------------------------------------
-- Quickfix and Location List
---------------------------------------------------------------------------------
local api, fn, cmd = vim.api, vim.fn, vim.cmd

ar.list = { qf = {}, loc = {} }

local silence = { mods = { silent = true, emsg_silent = true } }

---@param callback fun(...)
local function preserve_window(callback, ...)
  local win = api.nvim_get_current_win()
  local ok, err = pcall(callback, ...)
  if api.nvim_win_is_valid(win) and win ~= api.nvim_get_current_win() then
    api.nvim_set_current_win(win)
  end
  if not ok then error(err, 0) end
end

local list_adapters = {
  qf = {
    get = function(what) return what and fn.getqflist(what) or fn.getqflist() end,
    replace = function(value) fn.setqflist({}, 'r', value) end,
    open = cmd.copen,
    close = cmd.cclose,
    forward = cmd.cnext,
    backward = cmd.cprev,
  },
  loc = {
    get = function(what)
      return what and fn.getloclist(0, what) or fn.getloclist(0)
    end,
    replace = function(value) fn.setloclist(0, {}, 'r', value) end,
    open = cmd.lopen,
    close = cmd.lclose,
    forward = cmd.lnext,
    backward = cmd.lprev,
  },
}

local function toggle_list(adapter)
  local list = adapter.get({ size = 0, winid = 0 })
  if list.winid > 0 then
    adapter.close(silence)
  elseif list.size > 0 then
    preserve_window(adapter.open, silence)
  end
end

local function jump_list(adapter, forward)
  if adapter.get({ size = 0 }).size <= 1 then return end
  local jump = forward and adapter.forward or adapter.backward
  pcall(jump, { count = vim.v.count1 })
end

function ar.list.qf.toggle() toggle_list(list_adapters.qf) end

function ar.list.loc.toggle() toggle_list(list_adapters.loc) end

---@param forward boolean
function ar.list.qf.jump(forward) jump_list(list_adapters.qf, forward) end

---@param forward boolean
function ar.list.loc.jump(forward) jump_list(list_adapters.loc, forward) end

---@return table?
function ar.list.current_entry()
  local list_type = fn.win_gettype()
  local adapter = list_type == 'loclist' and list_adapters.loc
    or list_type == 'quickfix' and list_adapters.qf
  if not adapter then return end
  return adapter.get()[api.nvim_win_get_cursor(0)[1]]
end

-- @see: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/after/ftplugin/qf.lua#L13
-- using range-aware function
function ar.list.qf.delete(opts)
  local adapter = fn.win_gettype() == 'loclist' and list_adapters.loc
    or list_adapters.qf
  local what = { items = 0, title = 0 }
  local list = adapter.get(what)
  if #list.items > 0 then
    local row, col = unpack(api.nvim_win_get_cursor(0))
    for pos = opts.line2, opts.line1, -1 do
      table.remove(list.items, pos)
    end
    local replacement = { items = list.items, title = list.title }
    if #list.items > 0 then replacement.idx = math.min(row, #list.items) end
    adapter.replace(replacement)
    row = math.min(row, fn.line('$'))
    col = math.min(col, #fn.getline(row))
    api.nvim_win_set_cursor(0, { row, col })
  end
end

map('n', '<leader>Lq', ar.list.qf.toggle, { desc = 'toggle quickfix list' })
map('n', '<leader>Ll', ar.list.loc.toggle, { desc = 'toggle location list' })
local function repeatable_list_jump(list, opts)
  return ar.jump(function(o) list.jump(o.forward) end, opts)
end
map(
  'n',
  '<leader>j',
  repeatable_list_jump(ar.list.qf, { forward = true }),
  { desc = 'qflist next' }
)
map(
  'n',
  '<leader>k',
  repeatable_list_jump(ar.list.qf, { forward = false }),
  { desc = 'qflist prev' }
)
map(
  'n',
  '<localleader>j',
  repeatable_list_jump(ar.list.loc, { forward = true }),
  { desc = 'loclist next' }
)
map(
  'n',
  '<localleader>k',
  repeatable_list_jump(ar.list.loc, { forward = false }),
  { desc = 'loclist prev' }
)

ar.filetype_settings({
  qf = {
    opt = {
      wrap = false,
      number = false,
      signcolumn = 'yes',
      buflisted = false,
      winfixheight = true,
    },
    -- stylua: ignore
    mappings = {
      { 'n', 'dd', '<Cmd>QfListDelete<CR>', { buffer = 0, desc = 'delete current quickfix entry' } },
      { 'x', 'd', ':QfListDelete<CR>', { buffer = 0, desc = 'delete selected quickfix entry' } },
      {
        'n',
        'w',
        function()
          local qf_entry = ar.list.current_entry()
          if not qf_entry or qf_entry.bufnr == 0 then return end
          ar.open_with_window_picker(function()
            api.nvim_set_current_buf(qf_entry.bufnr)
          end)
        end,
        { buffer = 0, desc = 'open entry with window picker' },
      },
      { 'n', 'H', ':colder<CR>', { buffer = 0 } },
      { 'n', 'L', ':cnewer<CR>', { buffer = 0 } },
    },
    function()
      -- force quickfix to open beneath all other splits
      vim.cmd.wincmd('J')
      ar.adjust_split_height(5, 10)
      -- stylua: ignore
      api.nvim_buf_create_user_command(0, 'QfListDelete', ar.list.qf.delete, { range = true })
    end,
  },
})
