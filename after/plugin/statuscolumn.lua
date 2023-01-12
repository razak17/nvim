if not vim.o.statuscolumn then return end

local api, fn, v = vim.api, vim.fn, vim.v

rvim.statuscolumn = {}

function rvim.statuscolumn.fdm()
  return fn.foldlevel(v.lnum) > fn.foldlevel(v.lnum - 1)
      and (fn.foldclosed(v.lnum) == -1 and '▼' or '')
    or ' '
end

function rvim.statuscolumn.nr() return (not rvim.empty(v.relnum) and v.relnum or v.lnum) end

local excluded = {
  'NeogitStatus',
  'NeogitCommitMessage',
  'undotree',
  'log',
  'man',
  'dap-repl',
  'markdown',
  'vimwiki',
  'vim-plug',
  'gitcommit',
  'toggleterm',
  'fugitive',
  'list',
  'NvimTree',
  'startify',
  'help',
  'orgagenda',
  'org',
  'himalaya',
  'Trouble',
  'NeogitCommitMessage',
  'NeogitRebaseTodo',
}

rvim.augroup('StatusCol', {
  {
    event = { 'WinEnter', 'BufEnter', 'VimEnter', 'WinNew', 'WinClosed', 'FileType' },
    command = function()
      for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
        local value = ''
        local buf, config = vim.bo[api.nvim_win_get_buf(win)], api.nvim_win_get_config(win)
        if buf.bt == '' and not vim.tbl_contains(excluded, buf.ft) and config.relative == '' then
          value = ' %=%{v:lua.rvim.statuscolumn.nr()} │ %s%{v:lua.rvim.statuscolumn.fdm()} ' -- %C for folds
        end
        api.nvim_set_option_value('statuscolumn', value, { scope = 'local', win = win })
      end
    end,
  },
})
