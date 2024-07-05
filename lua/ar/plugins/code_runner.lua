local ui, highlight = ar.ui, ar.highlight
local border = ui.current.border

return {
  -- Code Runner
  --------------------------------------------------------------------------------
  {
    'trimclain/builder.nvim',
    cond = false,
    cmd = 'Build',
    -- stylua: ignore
    keys = {
      { '<leader>rb', '<Cmd>lua require("builder").build()<CR>', desc = 'builder: run', },
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
    'is0n/jaq-nvim',
    cmd = 'Jaq',
    keys = {
      { '<leader>rb', ':silent only | Jaq<CR>', desc = 'jaq: run' },
    },
    opts = {
      cmds = {
        external = {
          markdown = 'glow %',
          typescript = 'ts-node %',
          javascript = 'node %',
          python = 'python %',
          rust = 'cargo run',
          cpp = 'g++ % -o $fileBase && ./$fileBase',
          go = 'go run %',
          lua = 'lua %',
        },
      },
      behavior = { default = 'float', startinsert = true },
      ui = { float = { border = border } },
      terminal = { position = 'vert', size = 60 },
    },
  },
  {
    'jellydn/quick-code-runner.nvim',
    opts = { debug = true },
    cmd = { 'QuickCodeRunner', 'QuickCodePad' },
    keys = {
      {
        mode = 'v',
        '<leader>rs',
        ':QuickCodeRunner<CR>',
        desc = 'quick-runner: run selection',
      },
      -- { '<leader>rP', ':QuickCodePad<CR>', desc = 'quick-runner: open pad' },
    },
  },
  {
    'razak17/lab.nvim',
    event = { 'BufRead', 'BufNewFile' },
    cond = not ar.plugins.minimal,
    keys = {
      { '<leader>rl', ':Lab code run<CR>', desc = 'lab: run' },
      { '<leader>rq', ':Lab code stop<CR>', desc = 'lab: stop' },
      -- { '<leader>rp', ':Lab code panel<CR>', desc = 'lab: panel' },
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
      require('lab').setup({
        quick_data = {
          enabled = ar.completion.enable,
        },
      })
    end,
  },
  {
    -- 'google/executor.nvim',
    'razak17/executor.nvim',
    -- stylua: ignore
    keys = {
      { '<localleader>xc', '<cmd>ExecutorRun<CR>', desc = 'executor: start' },
      { '<localleader>xs', '<cmd>ExecutorSetCommand<CR>', desc = 'executor: set command', },
      { '<localleader>xd', '<cmd>ExecutorToggleDetail<CR>', desc = 'executor: toggle detail', },
      { '<localleader>xr', '<cmd>ExecutorReset<CR>', desc = 'executor: reset status', },
      { '<localleader>xp', '<cmd>ExecutorShowPresets<CR>', desc = 'executor: show presets', },
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
        ['custom-website'] = { 'npm run dev' },
      },
    },
  },
  {
    'michaelb/sniprun',
    build = 'sh install.sh',
    cmd = { 'SnipRun', 'SnipInfo' },
    init = function()
      require('which-key').register({
        ['<leader>rs'] = { name = 'SnipRun' },
      })
    end,
    keys = {
      { mode = 'v', '<leader>rr', ':SnipRun<CR>', desc = 'sniprun: run code' },
      { '<leader>rsr', ':SnipRun<CR>', desc = 'sniprun: run code' },
      { '<leader>rsi', ':SnipInfo<CR>', desc = 'sniprun: info' },
      { '<leader>rsc', ':SnipReset<CR>', desc = 'sniprun: reset' },
      { '<leader>rsq', ':SnipClose<CR>', desc = 'sniprun: close' },
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
  {
    'ej-shafran/compile-mode.nvim',
    cmd = { 'Compile', 'Recompile' },
    opts = { default_command = '' },
    dependencies = {
      { 'm00qek/baleia.nvim', tag = 'v1.3.0' },
    },
  },
}
