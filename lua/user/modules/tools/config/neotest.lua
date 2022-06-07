return function()
  local neotest = require('neotest')
  neotest.setup({
    adapters = {
      require('neotest-plenary'),
      require('neotest-vim-test')({ ignore_filetypes = { "python", "lua" } })
    },
    floating = {
      border = rvim.style.border.current,
    },
  })
  local function open()
    neotest.output.open({ enter = false })
  end
  local function run_file()
    neotest.run.run(vim.fn.expand('%'))
  end
  rvim.nnoremap('<localleader>ts', neotest.summary.toggle, 'neotest: run suite')
  rvim.nnoremap('<localleader>to', open, 'neotest: output')
  rvim.nnoremap('<localleader>tn', neotest.run.run, 'neotest: run')
  rvim.nnoremap('<localleader>tf', run_file, 'neotest: run file')
end
