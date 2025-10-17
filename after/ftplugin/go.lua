if not ar or ar.none then return end

local bo, fmt = vim.bo, string.format

bo.tabstop = 4
bo.shiftwidth = 4
bo.expandtab = false

-- @see: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/keymaps.lua?plain=1#L180
local function run_file()
  if vim.env.TMUX == nil then
    vim.notify('Not in tmux.')
    return
  end
  local file = vim.fn.expand('%')
  if string.match(file, '%.go$') then
    local file_dir = vim.fn.expand('%:p:h')
    local command_to_run = 'go run *.go'
    local cmd = "silent !tmux split-window -h -Z 'cd "
      .. file_dir
      .. ' && echo "'
      .. command_to_run
      .. '\\n" && bash -c "'
      .. command_to_run
      .. '; echo; echo Press enter to exit...; read _"\''
    vim.cmd(cmd)
  else
    vim.cmd("echo 'Not a Go file.'")
  end
end

map('n', '<leader>rr', run_file, { desc = 'execute file', buffer = 0 })

if not ar.plugins.enable or ar.plugins.minimal then return end

if ar.lsp.enable then
  local function with_desc(desc)
    return { buffer = 0, desc = fmt('gopher: %s', desc) }
  end

  map('n', '<localleader>gb', '<Cmd>GoBuild<CR>', with_desc('build'))
  map(
    'n',
    '<localleader>gfs',
    '<Cmd>GoFillStruct<CR>',
    with_desc('fill struct')
  )
  map(
    'n',
    '<localleader>gfp',
    '<Cmd>GoFixPlurals<CR>',
    with_desc('fix plurals')
  )
  map('n', '<localleader>gie', '<Cmd>GoIfErr<CR>', with_desc('if err'))
end

if not ar.has('nvim-dap') then return end

local dap = require('dap')
local dlv_path = ar.get_pkg_path('delve', 'dlv')

dap.adapters.go = {
  type = 'server',
  port = '${port}',
  executable = {
    command = dlv_path,
    args = { 'dap', '-l', '127.0.0.1:${port}' },
  },
}
dap.configurations.go = {
  {
    type = 'go',
    name = 'Debug',
    request = 'launch',
    program = '${file}',
  },
  {
    type = 'go',
    name = 'Debug test (go.mod)',
    request = 'launch',
    mode = 'test',
    program = './${relativeFileDirname}',
  },
  {
    type = 'go',
    name = 'Attach (Pick Process)',
    mode = 'local',
    request = 'attach',
    processId = require('dap.utils').pick_process,
  },
  {
    type = 'go',
    name = 'Attach (127.0.0.1:9080)',
    mode = 'remote',
    request = 'attach',
    port = '9080',
  },
}
