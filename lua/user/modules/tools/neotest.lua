local function neotest() return require('neotest') end
local function open() neotest().output.open({ enter = true, short = false }) end
local function run_file() neotest().run.run(vim.fn.expand('%')) end
local function run_file_sync() neotest().run.run({ vim.fn.expand('%'), concurrent = false }) end
local function nearest() neotest().run.run() end
local function next_failed() neotest().jump.prev({ status = 'failed' }) end
local function prev_failed() neotest().jump.next({ status = 'failed' }) end
local function toggle_summary() neotest().summary.toggle() end
local function cancel() neotest().run.stop({ interactive = true }) end

return {
  'nvim-neotest/neotest',
  event = { 'BufRead', 'BufNewFile' },
  keys = {
    { '<leader>ts', toggle_summary, desc = 'neotest: toggle summary' },
    { '<leader>to', open, desc = 'neotest: output' },
    { '<leader>tn', nearest, desc = 'neotest: run' },
    { '<leader>tf', run_file, desc = 'neotest: run file' },
    { '<leader>tF', run_file_sync, desc = 'neotest: run file synchronously' },
    { '<leader>tc', cancel, desc = 'neotest: cancel' },
    { '[n', next_failed, desc = 'jump to next failed test' },
    { ']n', prev_failed, desc = 'jump to previous failed test' },
  },
  config = function()
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
      icons = { running = rvim.ui.icons.misc.clock },
      floating = { border = rvim.ui.current.border },
      adapters = {
        require('neotest-plenary'),
        require('neotest-python'),
        require('neotest-rust'),
        require('neotest-go')({ experimental = { test_table = true } }),
        require('neotest-jest')({
          jestCommand = 'npm test --',
          jestConfigFile = 'jest.config.js',
        }),
      },
    })
  end,
  dependencies = {
    'rouge8/neotest-rust',
    'nvim-neotest/neotest-go',
    'haydenmeade/neotest-jest',
    'nvim-neotest/neotest-python',
    { 'rcarriga/neotest-plenary', dependencies = { 'nvim-lua/plenary.nvim' } },
  },
}
