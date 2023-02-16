local function neotest() return require('neotest') end
local function open() neotest().output.open({ enter = true, short = false }) end
local function run_file() neotest().run.run(vim.fn.expand('%')) end
local function run_file_sync() neotest().run.run({ vim.fn.expand('%'), concurrent = false }) end
local function nearest() neotest().run.run() end
local function next_failed() neotest().jump.prev({ status = 'failed' }) end
local function prev_failed() neotest().jump.next({ status = 'failed' }) end
local function toggle_summary() neotest().summary.toggle() end
local function cancel() neotest().run.stop({ interactive = true }) end

local M = {
  'nvim-neotest/neotest',
  event = { 'BufRead', 'BufNewFile' },
  dependencies = {
    { 'rcarriga/neotest-plenary', dependencies = { 'nvim-lua/plenary.nvim' } },
    'rcarriga/neotest-vim-test',
    'nvim-neotest/neotest-python',
    'rouge8/neotest-rust',
    'nvim-neotest/neotest-go',
  },
  keys = {
    { '<localleader>ts', toggle_summary, desc = 'neotest: toggle summary' },
    { '<localleader>to', open, desc = 'neotest: output' },
    { '<localleader>tn', nearest, desc = 'neotest: run' },
    { '<localleader>tf', run_file, desc = 'neotest: run file' },
    { '<localleader>tF', run_file_sync, desc = 'neotest: run file synchronously' },
    { '<localleader>tc', cancel, desc = 'neotest: cancel' },
    { '[n', next_failed, desc = 'jump to next failed test' },
    { ']n', prev_failed, desc = 'jump to previous failed test' },
  },
}

function M.config()
  local neotest_ns = vim.api.nvim_create_namespace('neotest')
  vim.diagnostic.config({
    virtual_text = {
      format = function(diagnostic)
        local message =
          diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
        return message
      end,
    },
  }, neotest_ns)
  require('neotest').setup({
    discovery = { enabled = true },
    diagnostic = { enabled = true },
    icons = { running = rvim.style.icons.misc.clock },
    floating = { border = rvim.style.current.border },
    adapters = {
      require('neotest-plenary'),
      require('neotest-python'),
      require('neotest-rust'),
      require('neotest-go')({ experimental = { test_table = true } }),
    },
  })
end

return M
