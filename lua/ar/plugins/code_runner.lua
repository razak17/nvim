local ui, highlight = ar.ui, ar.highlight
local border = ui.current.border
local preview_cmd = '/usr/bin/zathura'
local minimal = ar.plugins.minimal

return {
  -- Code Runner
  --------------------------------------------------------------------------------
  {
    'razak17/builder.nvim',
    cond = false,
    cmd = 'Build',
    -- stylua: ignore
    keys = {
      { '<leader>rb', '<Cmd>lua require("builder").build()<CR>', desc = 'builder: run', },
    },
    init = function()
      ar.add_to_menu('command_palette', { ['Run Code'] = 'Build' })
    end,
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
    'razak17/jaq-nvim',
    cond = not minimal,
    cmd = 'Jaq',
    keys = {
      { '<leader>rb', ':silent only | Jaq<CR>', desc = 'jaq: run' },
    },
    opts = {
      cmds = {
        external = {
          c = 'gcc % -o $fileBase && ./$fileBase',
          cpp = 'g++ % -o $fileBase && ./$fileBase',
          go = 'go run %',
          java = 'java %',
          javascript = 'node %',
          lua = 'lua %',
          markdown = 'glow %',
          python = 'python %',
          rust = 'cargo run',
          sh = 'sh %',
          typescript = 'ts-node %',
          zsh = 'zsh %',
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
    init = function()
      ar.add_to_menu('command_palette', { ['Code Pad'] = 'QuickCodePad' })
    end,
    cmd = { 'QuickCodeRunner', 'QuickCodePad' },
    cond = not minimal,
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
    event = { 'InsertEnter' },
    cond = not minimal,
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
    cond = not minimal,
    init = function()
      require('which-key').add({ { '<leader><leader>x', group = 'Executor' } })
    end,
    -- stylua: ignore
    keys = {
      { '<leader><leader>xc', '<cmd>ExecutorRun<CR>', desc = 'executor: start' },
      { '<leader><leader>xs', '<cmd>ExecutorSetCommand<CR>', desc = 'executor: set command', },
      { '<leader><leader>xd', '<cmd>ExecutorToggleDetail<CR>', desc = 'executor: toggle detail', },
      { '<leader><leader>xr', '<cmd>ExecutorReset<CR>', desc = 'executor: reset status', },
      { '<leader><leader>xp', '<cmd>ExecutorShowPresets<CR>', desc = 'executor: show presets', },
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
    cond = not minimal,
    init = function()
      require('which-key').add({
        { '<leader>rs', group = 'SnipRun' },
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
    cond = not minimal,
    cmd = { 'Compile', 'Recompile' },
    opts = { default_command = '' },
    dependencies = {
      { 'm00qek/baleia.nvim', tag = 'v1.3.0' },
    },
  },
  -- https://github.com/CRAG666/dotfiles/blob/main/config/nvim/lua/plugins/dev/code_runner.lua
  {
    'CRAG666/code_runner.nvim',
    cond = not minimal,
    -- stylua: ignore
    keys = {
      { '<leader>rc', function() require('code_runner').run_code() end, desc = 'code runner: run code' },
    },
    opts = {
      mode = 'float',
      filetype = {
        v = 'v run',
        tex = function(...)
          if vim.g.tectonic == nil then
            vim.system({ 'tectonic', '-X', 'build', '--open' })
            vim.fn.jobstart(
              "tectonic -X watch -x 'build --keep-intermediates --keep-logs'"
            )
            -- vim.system { "tectonic", "-X", "watch", "-x", "'build --keep-intermediates --keep-logs'" }
            vim.g.tectonic = 1
          end
        end,
        markdown = function(...)
          local hook = require('code_runner.hooks.preview_pdf')
          require('code_runner.hooks.ui').select({
            Marp = function()
              require('code_runner.commands').run_from_fn(
                'marp --theme-set $MARPT -w -p . &$end'
              )
            end,
            Latex = function()
              hook.run({
                command = 'pandoc',
                args = { '$fileName', '-o', '$tmpFile', '-t pdf' },
                preview_cmd = preview_cmd,
              })
            end,
            Beamer = function()
              hook.run({
                command = 'pandoc',
                args = { '$fileName', '-o', '$tmpFile', '-t beamer' },
                preview_cmd = preview_cmd,
              })
            end,
            Eisvogel = function()
              hook.run({
                command = 'bash',
                args = { './build.sh' },
                preview_cmd = preview_cmd,
                overwrite_output = '.',
              })
            end,
          })
        end,
        javascript = 'node',
        java = 'cd $dir && javac $fileName && java $fileNameWithoutExt',
        kotlin = 'cd $dir && kotlinc-native $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt.kexe',
        c = function(...)
          local c_base = {
            'cd $dir &&',
            'gcc $fileName -o',
            '/tmp/$fileNameWithoutExt',
          }
          local c_exec = {
            '&& /tmp/$fileNameWithoutExt &&',
            'rm /tmp/$fileNameWithoutExt',
          }
          vim.ui.input({ prompt = 'Add more args:' }, function(input)
            c_base[4] = input
            vim.print(vim.tbl_extend('force', c_base, c_exec))
            require('code_runner.commands').run_from_fn(
              vim.list_extend(c_base, c_exec)
            )
          end)
        end,
        cpp = {
          'cd $dir &&',
          'g++ $fileName',
          '-o /tmp/$fileNameWithoutExt &&',
          '/tmp/$fileNameWithoutExt',
        },
        python = "python -u '$dir/$fileName'",
        sh = 'bash',
        typescript = 'deno run',
        typescriptreact = 'yarn dev$end',
        rust = 'cd $dir && rustc $fileName && $dir$fileNameWithoutExt',
        dart = 'dart',
        cs = function(...)
          local root_dir =
            require('null-ls.utils').root_pattern('*.csproj')(vim.loop.cwd())
          return 'cd ' .. root_dir .. ' && dotnet run$end'
        end,
      },
      -- project_path = vim.fn.expand('~/.config/nvim/project_manager.json'),
    },
  },
}
