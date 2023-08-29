if rvim and rvim.none then return end

local bo, fmt = vim.bo, string.format

bo.tabstop = 4
bo.shiftwidth = 4
bo.expandtab = false
vim.opt_local.iskeyword:append('-')

if not rvim or not rvim.lsp.enable or not rvim.plugins.enable then return end

if rvim.is_available('which-key.nvim') then
  require('which-key').register({ ['<localleader>g'] = { name = 'Gopher' } })
end

local function with_desc(desc) return { buffer = 0, desc = fmt('gopher: %s', desc) } end

map('n', '<localleader>gb', '<Cmd>GoBuild<CR>', with_desc('build'))
map('n', '<localleader>gfs', '<Cmd>GoFillStruct<CR>', with_desc('fill struct'))
map('n', '<localleader>gfp', '<Cmd>GoFixPlurals<CR>', with_desc('fix plurals'))
map('n', '<localleader>gie', '<Cmd>GoIfErr<CR>', with_desc('if err'))

if rvim.plugins.minimal then return end

local dap = require('dap')
local mason_registry = require('mason-registry')
local dlv_path = mason_registry.get_package('delve'):get_install_path() .. '/dlv'

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
