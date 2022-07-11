return function()
  require('neotest').setup({
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
    require('neotest').output.open({ enter = true, short = false })
  end
  local function run_file()
    require('neotest').run.run(vim.fn.expand('%'))
  end
  local function nearest()
    require('neotest').run.run()
  end
  local function next_failed()
    require('neotest').jump.prev({ status = 'failed' })
  end
  local function prev_failed()
    require('neotest').jump.next({ status = 'failed' })
  end
  local function toggle_summary()
    require('neotest').summary.toggle()
  end
  rvim.nnoremap('<localleader>ts', toggle_summary, 'neotest: run suite')
  rvim.nnoremap('<localleader>to', open, 'neotest: output')
  rvim.nnoremap('<localleader>tn', nearest, 'neotest: run')
  rvim.nnoremap('<localleader>tf', run_file, 'neotest: run file')
  rvim.nnoremap('[n', next_failed, 'jump to next failed test')
  rvim.nnoremap(']n', prev_failed, 'jump to previous failed test')
end
