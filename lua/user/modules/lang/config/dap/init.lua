return function()
  local fn = vim.fn
  local config = require('user.modules.lang.config.dap.config')

  local function repl_toggle() require('dap').repl.toggle(nil, 'botright split') end
  local function continue() require('dap').continue() end
  local function step_out() require('dap').step_out() end
  local function step_into() require('dap').step_into() end
  local function step_over() require('dap').step_over() end
  local function step_back() require('dap').step_back() end
  local function run_last() require('dap').run_last() end
  local function toggle_breakpoint() require('dap').toggle_breakpoint() end
  local function set_breakpoint() require('dap').set_breakpoint(fn.input('Breakpoint condition: ')) end

  local function attach()
    print('attaching')
    require('dap').run({
      type = 'node2',
      request = 'attach',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      skipFiles = { '<node_internals>/**/*.js' },
    })
  end

  local function attach_to_remote()
    print('attaching')
    require('dap').run({
      type = 'node2',
      request = 'attach',
      address = '127.0.0.1',
      port = 9229,
      localRoot = vim.fn.getcwd(),
      remoteRoot = '/home/vcap/app',
      sourceMaps = true,
      protocol = 'inspector',
      skipFiles = { '<node_internals>/**/*.js' },
    })
  end

  require('which-key').register({
    ['<leader>d'] = {
      name = '+Debug',
      a = { attach, 'attach' },
      A = { attach_to_remote, 'attach remote' },

      H = { step_back, 'dap: step back' },
      i = { step_into, 'dap: step into' },
      o = { step_over, 'dap: step over' },
      u = { step_out, 'dap: step out' },

      b = { toggle_breakpoint, 'dap: toggle breakpoint' },
      B = { set_breakpoint, 'dap: set breakpoint' },
      c = { continue, 'dap: continue or start debugging' },
      l = { run_last, 'dap REPL: run last' },
      t = { repl_toggle, 'dap REPL: toggle' },
    },
  })

  require('dap').defaults.fallback.terminal_win_cmd = '50vsplit new'

  -- DON'T automatically stop at exceptions
  require('dap').defaults.fallback.exception_breakpoints = {}

  config.setup()
end
