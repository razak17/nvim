local M = {
  'nvim-neotest/neotest',
  event = { 'BufRead', 'BufNewFile' },
  dependencies = {
    'rcarriga/neotest-plenary',
    'rcarriga/neotest-vim-test',
    'nvim-neotest/neotest-python',
    'rouge8/neotest-rust',
    'nvim-neotest/neotest-go',
  },
}

function M.init()
  local function neotest_open() require('neotest').output.open({ enter = true, short = false }) end
  local function run_file() require('neotest').run.run(vim.fn.expand('%')) end
  local function run_file_sync()
    require('neotest').run.run({ vim.fn.expand('%'), concurrent = false })
  end
  local function nearest() require('neotest').run.run() end
  local function next_failed() require('neotest').jump.prev({ status = 'failed' }) end
  local function prev_failed() require('neotest').jump.next({ status = 'failed' }) end
  local function toggle_summary() require('neotest').summary.toggle() end
  local function cancel() require('neotest').run.stop({ interactive = true }) end

  rvim.nnoremap('<localleader>ts', toggle_summary, 'neotest: toggle summary')
  rvim.nnoremap('<localleader>to', neotest_open, 'neotest: output')
  rvim.nnoremap('<localleader>tn', nearest, 'neotest: run')
  rvim.nnoremap('<localleader>tf', run_file, 'neotest: run file')
  rvim.nnoremap('<localleader>tF', run_file_sync, 'neotest: run file synchronously')
  rvim.nnoremap('<localleader>tc', cancel, 'neotest: cancel')
  rvim.nnoremap('[n', next_failed, 'jump to next failed test')
  rvim.nnoremap(']n', prev_failed, 'jump to previous failed test')
end

function M.config()
  -- get neotest namespace (api call creates or returns namespace)
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
      require('neotest-go')({
        experimental = {
          test_table = true,
        },
      }),
    },
  })
end

return M
