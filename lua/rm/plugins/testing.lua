local function neotest() return require('neotest') end
local function open() neotest().output.open({ enter = true, short = false }) end
local function run_file() neotest().run.run(vim.fn.expand('%')) end
local function run_file_sync()
  neotest().run.run({ vim.fn.expand('%'), concurrent = false })
end
local function nearest() neotest().run.run() end
local function next_failed() neotest().jump.prev({ status = 'failed' }) end
local function prev_failed() neotest().jump.next({ status = 'failed' }) end
local function toggle_summary() neotest().summary.toggle() end
local function cancel() neotest().run.stop({ interactive = true }) end
local function run_last() neotest().run.run_last() end
local function debug_nearest() require('neotest').run.run({ strategy = 'dap' }) end

return {
  {
    'nvim-neotest/neotest',
    enabled = not rvim.plugins.minimal,
    keys = {
      { '<leader>tns', toggle_summary, desc = 'neotest: toggle summary' },
      { '<leader>tno', open, desc = 'neotest: output' },
      { '<leader>tnn', nearest, desc = 'neotest: run' },
      { '<leader>tnl', run_last, desc = 'neotest: run last' },
      { '<leader>tnd', debug_nearest, desc = 'neotest: debug nearest' },
      { '<leader>tnf', run_file, desc = 'neotest: run file' },
      {
        '<leader>tnF',
        run_file_sync,
        desc = 'neotest: run file synchronously',
      },
      { '<leader>tnc', cancel, desc = 'neotest: cancel' },
      { '[n', next_failed, desc = 'jump to next failed test' },
      { ']n', prev_failed, desc = 'jump to previous failed test' },
    },
    config = function()
      local neotest_ns = vim.api.nvim_create_namespace('neotest')
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message
              :gsub('\n', ' ')
              :gsub('\t', ' ')
              :gsub('%s+', ' ')
              :gsub('^%s+', '')
            return message
          end,
        },
      }, neotest_ns)
      require('neotest').setup({
        discovery = { enabled = true },
        diagnostic = { enabled = true },
        icons = { running = rvim.ui.codicons.misc.clock },
        floating = { border = rvim.ui.current.border },
        quickfix = { enabled = false, open = true },
        adapters = {
          require('neotest-plenary'),
          require('neotest-python'),
          require('neotest-rust')({
            args = { '--verbose' },
          }),
          require('neotest-go'),
          require('neotest-jest')({
            jestCommand = 'npm test --',
            jestConfigFile = 'jest.config.js',
          }),
          require('neotest-vim-test')({
            ignore_file_types = { 'python', 'vim', 'lua' },
          }),
        },
        consumers = {
          overseer = require('neotest.consumers.overseer'),
        },
        overseer = {
          enabled = true,
          force_default = true,
        },
      })
    end,
    dependencies = {
      'rouge8/neotest-rust',
      'nvim-neotest/neotest-go',
      'haydenmeade/neotest-jest',
      'nvim-neotest/neotest-python',
      'nvim-neotest/neotest-vim-test',
      {
        'rcarriga/neotest-plenary',
        dependencies = { 'nvim-lua/plenary.nvim' },
      },
    },
  },
  {
    'vim-test/vim-test',
    keys = {
      { '<leader>tvc', '<cmd>TestClass<cr>', desc = 'vim-test: class' },
      { '<leader>tvf', '<cmd>TestFile<cr>', desc = 'vim-test: file' },
      { '<leader>tvl', '<cmd>TestLast<cr>', desc = 'vim-test: last' },
      { '<leader>tvn', '<cmd>TestNearest<cr>', desc = 'vim-test: nearest' },
      { '<leader>tvs', '<cmd>TestSuite<cr>', desc = 'vim-test: suite' },
      { '<leader>tvv', '<cmd>TestVisit<cr>', desc = 'vim-test: visit' },
    },
    config = function()
      vim.g['test#strategy'] = 'neovim'
      vim.g['test#neovim#term_position'] = 'belowright'
      vim.g['test#neovim#preserve_screen'] = 1
      vim.g['test#python#runner'] = 'pyunit' -- pytest
    end,
  },
  {
    'stevearc/overseer.nvim',
    keys = {
      {
        '<leader>toR',
        '<cmd>OverseerRunCmd<cr>',
        desc = 'overseer: run command',
      },
      {
        '<leader>toa',
        '<cmd>OverseerTaskAction<cr>',
        desc = 'overseer: task action',
      },
      { '<leader>tob', '<cmd>OverseerBuild<cr>', desc = 'overseer: build' },
      { '<leader>toc', '<cmd>OverseerClose<cr>', desc = 'overseer: close' },
      {
        '<leader>tod',
        '<cmd>OverseerDeleteBundle<cr>',
        desc = 'overseer: delete bundle',
      },
      {
        '<leader>tol',
        '<cmd>OverseerLoadBundle<cr>',
        desc = 'overseer: load bundle',
      },
      { '<leader>too', '<cmd>OverseerOpen<cr>', desc = 'overseer: open' },
      {
        '<leader>toq',
        '<cmd>OverseerQuickAction<cr>',
        desc = 'overseer: quick action',
      },
      { '<leader>tor', '<cmd>OverseerRun<cr>', desc = 'overseer: run' },
      {
        '<leader>tos',
        '<cmd>OverseerSaveBundle<cr>',
        desc = 'overseer: save bundle',
      },
      { '<leader>tot', '<cmd>OverseerToggle<cr>', desc = 'overseer: toggle' },
    },
    opts = {},
  },
  {
    'andythigpen/nvim-coverage',
    keys = {
      {
        '<leader>tl',
        function() require('coverage').load(true) end,
        desc = 'coverage: load',
      },
      {
        '<leader>tc',
        function() require('coverage').clear() end,
        desc = 'coverage: clear',
      },
      {
        '<leader>tt',
        function() require('coverage').toggle() end,
        desc = 'coverage: toggle',
      },
      {
        '<leader>ts',
        function() require('coverage').summary() end,
        desc = 'coverage: summary',
      },
      {
        ']u',
        function() require('coverage').jump_next('uncovered') end,
        'coverage: jump next uncovered',
      },
      {
        '[u',
        function() require('coverage').jump_prev('uncovered') end,
        'coverage: jump prev uncovered',
      },
    },
    opts = {
      auto_reload = true,
      load_coverage_cb = function(ftype)
        require('notify')(
          'Loaded ' .. ftype .. ' coverage',
          vim.log.levels.INFO,
          { render = 'minimal', timeout = 1000, hide_from_history = true }
        )
      end,
      highlights = {
        summary_normal = { link = 'Normal' },
        summary_cursor_line = { link = 'NormalFloat' },
      },
    },
    dependencies = 'nvim-lua/plenary.nvim',
  },
}
