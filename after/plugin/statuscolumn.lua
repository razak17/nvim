if not rvim  or not vim.o.statuscolumn then return end

local fn, v, api = vim.fn, vim.v, vim.api

local space = ' '
local separator = '▏' -- '│'

rvim.statuscolumn = {}

---@return {name:string, text:string, texthl:string}[]
local function get_signs()
  local buf = api.nvim_win_get_buf(vim.g.statusline_winid)
  return vim.tbl_map(
    function(sign) return fn.sign_getdefined(sign.name)[1] end,
    fn.sign_getplaced(buf, { group = '*', lnum = v.lnum })[1].signs
  )
end

local function fdm()
  local is_folded = fn.foldlevel(v.lnum) > fn.foldlevel(v.lnum - 1)
  return is_folded and (fn.foldclosed(v.lnum) == -1 and '▼' or '⏵') or ' '
end

local function nr()
  local num = (not rvim.empty(v.relnum) and v.relnum or v.lnum)
  return fn.substitute(num, '\\d\\zs\\ze\\' .. '%(\\d\\d\\d\\)\\+$', ',', 'g')
end

-- Format the git sign i.e. remove the extra padding that is added
---@param sign {texthl: string, text: string}
---@return string
local function format_git_sign(sign)
  if not sign then return ' ' end
  return '%#' .. sign.texthl .. '#' .. sign.text:gsub(' ', '') .. '%*'
end

function rvim.statuscolumn.render()
  local sign, git_sign
  -- This is dependent on using normal signs (rather than extmarks) for git signs
  for _, s in ipairs(get_signs()) do
    if s.name:find('GitSign') then
      git_sign = s
    else
      sign = s
    end
  end
  local components = {
    sign and ('%#' .. sign.texthl .. '#' .. sign.text .. '%*') or ' ',
    [[%=]],
    nr(),
    space,
    format_git_sign(git_sign),
    separator,
    fdm(),
    space,
  }
  return table.concat(components, '')
end

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

vim.o.statuscolumn = [[%!v:lua.rvim.statuscolumn.render()]]

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
