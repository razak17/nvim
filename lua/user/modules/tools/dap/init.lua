return function()
  local fn = vim.fn
  local config = require('user.modules.tools.dap.config')

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

  rvim.nnoremap('<localleader>da', attach, 'dap: attach')
  rvim.nnoremap('<localleader>dA', attach_to_remote, 'dap: attach to remote')
  rvim.nnoremap('<localleader>db', toggle_breakpoint, 'dap: toggle breakpoint')
  rvim.nnoremap('<localleader>dB', set_breakpoint, 'dap: set breakpoint')
  rvim.nnoremap('<localleader>dc', continue, 'dap: continue or start debugging')
  rvim.nnoremap('<localleader>dh', step_back, 'dap: step back')
  rvim.nnoremap('<localleader>de', step_out, 'dap: step out')
  rvim.nnoremap('<localleader>di', step_into, 'dap: step into')
  rvim.nnoremap('<localleader>do', step_over, 'dap: step over')
  rvim.nnoremap('<localleader>dl', run_last, 'dap REPL: run last')
  rvim.nnoremap('<localleader>dt', repl_toggle, 'dap REPL: toggle')

  require('dap').defaults.fallback.terminal_win_cmd = '50vsplit new'

  -- DON'T automatically stop at exceptions
  require('dap').defaults.fallback.exception_breakpoints = {}

  config.setup()
end
