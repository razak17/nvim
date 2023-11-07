local ui, highlight = rvim.ui, rvim.highlight
local border = ui.current.border

return {
  -- Code Runner
  --------------------------------------------------------------------------------
  {
    'trimclain/builder.nvim',
    cmd = 'Build',
    keys = {
      {
        '<leader>rr',
        '<Cmd>lua require("builder").build()<CR>',
        desc = 'builder: run',
      },
    },
    opts = {
      type = 'float',
      float_border = border,
      commands = {
        c = 'gcc % -o $basename.out && ./$basename.out',
        cpp = 'g++ % -o $basename.out && ./$basename.out',
        go = 'go run %',
        java = 'java %',
        javascript = 'node %',
        -- lua = "lua %", -- this will override the default `:source %` for lua files
        markdown = 'glow %',
        python = 'python %',
        rust = 'cargo run',
        sh = 'sh %',
        typescript = 'ts-node %',
        zsh = 'zsh %',
      },
    },
  },
  {
    'razak17/lab.nvim',
    cond = not rvim.plugins.minimal,
    keys = {
      { '<leader>rl', ':Lab code run<CR>', desc = 'lab: run' },
      { '<leader>rx', ':Lab code stop<CR>', desc = 'lab: stop' },
      { '<leader>rp', ':Lab code panel<CR>', desc = 'lab: panel' },
    },
    build = 'cd js && npm ci',
    config = function()
      highlight.plugin('lab', {
        theme = {
          ['onedark'] = {
            { LabCodeRun = { link = 'DiagnosticVirtualTextInfo' } },
          },
        },
      })
      require('lab').setup()
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'razak17/executor.nvim',
    keys = {
      { '<localleader>xc', '<cmd>ExecutorRun<CR>', desc = 'executor: start' },
      {
        '<localleader>xs',
        '<cmd>ExecutorSetCommand<CR>',
        desc = 'executor: set command',
      },
      {
        '<localleader>xd',
        '<cmd>ExecutorToggleDetail<CR>',
        desc = 'executor: toggle detail',
      },
      {
        '<localleader>xr',
        '<cmd>ExecutorReset<CR>',
        desc = 'executor: reset status',
      },
      {
        '<localleader>xp',
        '<cmd>ExecutorShowPresets<CR>',
        desc = 'executor: show presets',
      },
    },
    opts = {
      input = {
        border = {
          style = 'single',
          padding = {
            top = 0,
            bottom = 0,
            left = 1,
            right = 1,
          },
        },
      },
      notifications = {
        task_started = true,
        task_completed = true,
      },
      preset_commands = {
        ['custom-website'] = {
          'npm run dev',
        },
      },
    },
  },
  {
    'michaelb/sniprun',
    build = 'sh install.sh',
    cmd = { 'SnipRun', 'SnipInfo' },
    keys = {
      {
        mode = 'v',
        '<localleader>rr',
        ':SnipRun<CR>',
        desc = 'sniprun: run code',
      },
      { '<localleader>rr', ':SnipRun<CR>', desc = 'sniprun: run code' },
      { '<localleader>ri', ':SnipInfo<CR>', desc = 'sniprun: info' },
      { '<localleader>rc', ':SnipReset<CR>', desc = 'sniprun: reset' },
      { '<localleader>rq', ':SnipClose<CR>', desc = 'sniprun: close' },
    },
    opts = {},
    config = function(_, opts)
      highlight.plugin('sniprun', {
        theme = {
          ['onedark'] = {
            { SniprunVirtualTextOk = { link = 'DiagnosticVirtualTextInfo' } },
            { SniprunFloatingWinOk = { link = 'DiagnosticVirtualTextInfo' } },
            { SniprunVirtualTextErr = { link = 'DiffDelete' } },
            { SniprunFloatingWinErr = { link = 'DiffDelete' } },
          },
        },
      })
      require('sniprun').setup(opts)
    end,
  },
}