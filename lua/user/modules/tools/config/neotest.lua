return function()
  local neotest = require('neotest')
  neotest.setup({
    diagnostic = {
      enabled = false,
    },
    icons = {
      running = rvim.style.icons.misc.clock,
    },
    floating = {
      border = rvim.style.border.current,
    },
    adapters = {
      require('neotest-plenary'),
    },
  })
  local function open()
    neotest.output.open({ enter = true, short = false })
  end

  local function run_file()
    neotest.run.run(vim.fn.expand('%'))
  end
  local nnoremap  = rvim.nnoremap

  nnoremap('<localleader>ts', neotest.summary.toggle, 'neotest: run suite')
  nnoremap('<localleader>to', open, 'neotest: output')
  nnoremap('<localleader>tn', neotest.run.run, 'neotest: run')
  nnoremap('<localleader>tf', run_file, 'neotest: run file')
end
