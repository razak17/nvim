if not rvim then return end

if not vim.o.statuscolumn then return end

local fn, v = vim.fn, vim.v

rvim.statuscolumn = { separator = '│' }

function rvim.statuscolumn.fdm()
  local is_folded = fn.foldlevel(v.lnum) > fn.foldlevel(v.lnum - 1)
  return is_folded and (fn.foldclosed(v.lnum) == -1 and '▼' or '') or ' '
end

function rvim.statuscolumn.nr() return (not rvim.empty(v.relnum) and v.relnum or v.lnum) end

local excluded = {
  'neo-tree',
  'NeogitStatus',
  'NeogitCommitMessage',
  'undotree',
  'log',
  'lazy',
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

vim.o.statuscolumn = ' %=%{v:lua.rvim.statuscolumn.nr()} │ %s%{v:lua.rvim.statuscolumn.fdm()} ' -- %C for folds

rvim.augroup('StatusCol', {
  {
    event = { 'BufEnter', 'FileType' },
    command = function(args)
      local buf = vim.bo[args.buf]
      if buf.bt ~= '' or vim.tbl_contains(excluded, buf.ft) then vim.opt_local.statuscolumn = '' end
    end,
  },
})

if not vim.o.statuscolumn then return end
