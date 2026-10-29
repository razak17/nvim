local minimal = ar.plugins.minimal

ar.select.testing = {
  title = 'Testing actions',
  options = {},
}

local function neotest()
  ar.pack.load('https://github.com/nvim-neotest/neotest')
  return require('neotest')
end
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
local function debug_nearest() neotest().run.run({ strategy = 'dap' }) end
local function attach() neotest().run.attach() end

local testing_menu = function()
  ar.create_select_menu(
    ar.select['testing'].title,
    ar.select['testing'].options
  )()
end

map(
  'n',
  '<leader>ot',
  testing_menu,
  { desc = '[t]esting [a]ctions: open menu for testing' }
)

ar.pack.add({
  {
    src = 'https://github.com/nvim-neotest/neotest',
    cond = function() return ar.get_plugin_cond('neotest', not minimal) end,
    init = function()
      vim.g.whichkey_add_spec({
        { '<leader>t', group = 'Testing' },
        { '<leader>tn', group = 'Neotest' },
      })
      ar.add_to_select('testing', {
        ['Neotest'] = function()
          ar.create_select_menu('Neotest', {
            ['Toggle summary'] = function() toggle_summary() end,
            ['Open output'] = open,
            ['Run nearest'] = nearest,
            ['Run last'] = run_last,
            ['Debug nearest'] = debug_nearest,
            ['Run file'] = run_file,
            ['Run file synchronously'] = run_file_sync,
            ['Cancel'] = cancel,
            ['Jump to next failed test'] = next_failed,
            ['Jump to previous failed test'] = prev_failed,
          })()
        end,
      })
    end,
    keys = {
      { '<leader>tna', attach, desc = 'neotest: attach to test' },
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
    dependencies = {
      { src = 'https://github.com/nvim-lua/plenary.nvim' },
      { src = 'https://github.com/nvim-neotest/nvim-nio' },
      { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
      { src = 'https://github.com/stevearc/overseer.nvim' },
      { src = 'https://github.com/rouge8/neotest-rust' },
      { src = 'https://github.com/nvim-neotest/neotest-go' },
      { src = 'https://github.com/haydenmeade/neotest-jest' },
      { src = 'https://github.com/nvim-neotest/neotest-python' },
      { src = 'https://github.com/nvim-neotest/neotest-vim-test' },
      { src = 'https://github.com/rcarriga/neotest-plenary' },
      { src = 'https://github.com/marilari88/neotest-vitest' },
    },
    setup = function()
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
        icons = { running = ar.ui.codicons.misc.clock },
        floating = { border = vim.o.winborder },
        quickfix = { enabled = false, open = true },
        adapters = {
          require('neotest-plenary'),
          require('neotest-python'),
          require('neotest-rust')({ args = { '--verbose' } }),
          require('neotest-go'),
          require('neotest-jest')({
            jestCommand = 'npm test --',
            jestConfigFile = 'jest.config.js',
          }),
          require('neotest-vim-test')({
            ignore_file_types = { 'python', 'vim', 'lua' },
          }),
          require('neotest-vitest'),
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
  },
  {
    src = 'https://github.com/vim-test/vim-test',
    cond = function() return ar.get_plugin_cond('vim-test', not minimal) end,
    init = function()
      vim.g.whichkey_add_spec({
        { '<leader>tv', group = 'Vim-test' },
      })

      ar.add_to_select('testing', {
        ['Vim-test'] = function()
          ar.create_select_menu('Vim-test', {
            ['Class'] = 'TestClass',
            ['File'] = 'TestFile',
            ['Last'] = 'TestLast',
            ['Nearest'] = 'TestNearest',
            ['Suite'] = 'TestSuite',
            ['Visit'] = 'TestVisit',
          })()
        end,
      })
    end,
    keys = {
      { '<leader>tvc', '<cmd>TestClass<cr>', desc = 'vim-test: class' },
      { '<leader>tvf', '<cmd>TestFile<cr>', desc = 'vim-test: file' },
      { '<leader>tvl', '<cmd>TestLast<cr>', desc = 'vim-test: last' },
      { '<leader>tvn', '<cmd>TestNearest<cr>', desc = 'vim-test: nearest' },
      { '<leader>tvs', '<cmd>TestSuite<cr>', desc = 'vim-test: suite' },
      { '<leader>tvv', '<cmd>TestVisit<cr>', desc = 'vim-test: visit' },
    },
    setup = function()
      vim.g['test#strategy'] = 'neovim'
      vim.g['test#neovim#term_position'] = 'belowright'
      vim.g['test#neovim#preserve_screen'] = 1
      vim.g['test#python#runner'] = 'pyunit'
    end,
  },
  {
    src = 'https://github.com/stevearc/overseer.nvim',
    cond = function() return ar.get_plugin_cond('overseer.nvim', not minimal) end,
    init = function()
      vim.g.whichkey_add_spec({
        { '<leader>to', group = 'Overseer' },
      })
    end,
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
        '<leader>tok',
        '<cmd>OverseerClearCache<cr>',
        desc = 'overseer: clear cache',
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
      {
        '<leader>tox',
        function()
          local overseer = require('overseer')
          local tasks = overseer.list_tasks({
            status = {
              overseer.STATUS.SUCCESS,
              overseer.STATUS.CANCELED,
              overseer.STATUS.FAILURE,
            },
          })
          for i, task in ipairs(tasks) do
            task:dispose()
          end
        end,
        desc = 'overseer: dispose completed jobs',
      },
      { '<leader>tor', '<cmd>OverseerRun<cr>', desc = 'overseer: run' },
      {
        '<leader>tos',
        '<cmd>OverseerSaveBundle<cr>',
        desc = 'overseer: save bundle',
      },
      { '<leader>tot', '<cmd>OverseerToggle<cr>', desc = 'overseer: toggle' },
    },
    setup = function() require('overseer').setup() end,
  },
  {
    src = 'https://github.com/andythigpen/nvim-coverage',
    cond = function() return ar.get_plugin_cond('nvim-coverage', not minimal) end,
    init = function()
      vim.g.whichkey_add_spec({
        { '<leader>tc', group = 'Coverage' },
      })

      ar.add_to_select('testing', {
        ['Coverage'] = function()
          ar.pack.load('https://github.com/andythigpen/nvim-coverage')
          ar.create_select_menu('Coverage', {
            ['Load'] = function()
              ar.pack.load('https://github.com/andythigpen/nvim-coverage')
              require('coverage').load(true)
            end,
            ['Clear'] = function()
              ar.pack.load('https://github.com/andythigpen/nvim-coverage')
              require('coverage').clear()
            end,
            ['Toggle'] = function()
              ar.pack.load('https://github.com/andythigpen/nvim-coverage')
              require('coverage').toggle()
            end,
            ['Summary'] = function()
              ar.pack.load('https://github.com/andythigpen/nvim-coverage')
              require('coverage').summary()
            end,
            ['Jump next'] = function()
              ar.pack.load('https://github.com/andythigpen/nvim-coverage')
              require('coverage').jump_next('uncovered')
            end,
            ['Jump previous'] = function()
              ar.pack.load('https://github.com/andythigpen/nvim-coverage')
              require('coverage').jump_prev('uncovered')
            end,
          })()
        end,
      })
    end,
    keys = {
      {
        '<leader>tcl',
        function() require('coverage').load(true) end,
        desc = 'coverage: load',
      },
      {
        '<leader>tcc',
        function() require('coverage').clear() end,
        desc = 'coverage: clear',
      },
      {
        '<leader>tct',
        function() require('coverage').toggle() end,
        desc = 'coverage: toggle',
      },
      {
        '<leader>tcs',
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
    setup = function()
      require('coverage').setup({
        auto_reload = true,
        load_coverage_cb = function(ftype)
          vim.notify(
            'Loaded ' .. ftype .. ' coverage',
            vim.log.levels.INFO,
            { render = 'minimal', timeout = 1000, hide_from_history = true }
          )
        end,
        highlights = {
          summary_normal = { link = 'Normal' },
          summary_cursor_line = { link = 'NormalFloat' },
        },
      })
    end,
  },
  {
    src = 'https://github.com/quolpr/quicktest.nvim',
    cond = function() return ar.get_plugin_cond('quicktest.nvim', not minimal) end,
    init = function()
      vim.g.whichkey_add_spec({
        { '<leader>tq', group = 'Quicktest' },
      })

      ar.add_to_select('testing', {
        ['Quicktest'] = function()
          ar.pack.load('https://github.com/quolpr/quicktest.nvim')
          ar.create_select_menu('Quicktest', {
            ['Run line'] = function()
              ar.pack.load('https://github.com/quolpr/quicktest.nvim')
              require('quicktest').run_line('auto', 'auto', {
                additional_args = { '-count=5' },
              })
            end,
            ['Run file'] = function()
              ar.pack.load('https://github.com/quolpr/quicktest.nvim')
              require('quicktest').run_file()
            end,
            ['Run dir'] = function()
              ar.pack.load('https://github.com/quolpr/quicktest.nvim')
              require('quicktest').run_dir()
            end,
            ['Run all'] = function()
              ar.pack.load('https://github.com/quolpr/quicktest.nvim')
              require('quicktest').run_all()
            end,
            ['Run previous'] = function()
              ar.pack.load('https://github.com/quolpr/quicktest.nvim')
              require('quicktest').run_previous()
            end,
            ['Toggle window'] = function()
              ar.pack.load('https://github.com/quolpr/quicktest.nvim')
              require('quicktest').toggle_win('split')
            end,
            ['Cancel run'] = function()
              ar.pack.load('https://github.com/quolpr/quicktest.nvim')
              require('quicktest').cancel_current_run()
            end,
          })()
        end,
      })
    end,
    keys = {
      {
        '<leader>tql',
        function()
          local qt = require('quicktest')
          qt.run_line('auto', 'auto', { additional_args = { '-count=5' } })
        end,
        desc = 'quicktest: test run line',
      },
      {
        '<leader>tqf',
        function() require('quicktest').run_file() end,
        desc = 'quicktest: test run file',
      },
      {
        '<leader>tqd',
        function() require('quicktest').run_dir() end,
        desc = 'quicktest: test run dir',
      },
      {
        '<leader>tqa',
        function() require('quicktest').run_all() end,
        desc = 'quicktest: test run all',
      },
      {
        '<leader>tqp',
        function() require('quicktest').run_previous() end,
        desc = 'quicktest: test run previous',
      },
      {
        '<leader>tqt',
        function() require('quicktest').toggle_win('split') end,
        desc = 'quicktest: test toggle window',
      },
      {
        '<leader>tqc',
        function() require('quicktest').cancel_current_run() end,
        desc = 'quicktest: test cancel run',
      },
    },
    dependencies = {
      { src = 'https://github.com/nvim-lua/plenary.nvim' },
      { src = 'https://github.com/MunifTanjim/nui.nvim' },
    },
    setup = function()
      require('quicktest').setup((function()
        return {
          adapters = {
            require('quicktest.adapters.golang')({
              args = function(bufnt, args)
                vim.list_extend(args, { '-count=1' })
                return args
              end,
            }),
            require('quicktest.adapters.vitest'),
            require('quicktest.adapters.elixir'),
            require('quicktest.adapters.dart'),
            require('quicktest.adapters.playwright'),
          },
          default_win_mode = 'split',
          use_experimental_colorizer = true,
        }
      end)(nil, {}) or {})
    end,
  },
})
