local ui, highlight = ar.ui, ar.highlight
local border = ui.current.border.default
local preview_cmd = '/usr/bin/zathura'
local coding = ar.plugins.coding

return {
  --------------------------------------------------------------------------------
  -- Code Runner
  --------------------------------------------------------------------------------
  {
    'razak17/jaq-nvim',
    cond = function() return ar.get_plugin_cond('jaq-nvim', coding) end,
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
    'CRAG666/code_runner.nvim',
    cond = function() return ar.get_plugin_cond('code_runner.nvim', coding) end,
    -- stylua: ignore
    keys = {
      { '<leader>rc', function() require('code_runner').run_code() end, desc = 'code runner: run code' },
    },
    opts = {
      -- https://github.com/CRAG666/dotfiles/blob/main/config/nvim/lua/plugins/dev/code_runner.lua
      mode = 'float',
      filetype = {
        v = 'v run',
        tex = function()
          require('code_runner.hooks.tectonic').build(
            preview_cmd,
            { '--keep-logs' }
          )
        end,
        markdown = function()
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
        c = function()
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
        cs = function()
          local root_dir =
            require('null-ls.utils').root_pattern('*.csproj')(vim.uv.cwd())
          return 'cd ' .. root_dir .. ' && dotnet run$end'
        end,
      },
      -- project_path = vim.fn.expand('~/.config/nvim/project_manager.json'),
    },
  },
  {
    'valonmulolli/zignite.nvim',
    cond = function() return ar.get_plugin_cond('zignite.nvim', coding) end,
    build = 'cd zig && zig build',
    -- stylua: ignore
    keys = {
      { '<localleader>rr', ':RunFile<CR>', desc = 'zignite: run file' },
      { '<localleader>rb', ':RunBuildSelect<CR>', desc = 'zignite: select build command' },
      { '<localleader>rq', ':RunClose<CR>', desc = 'zignite: close runner' },
      { '<localleader>rp', ':RunProject<CR>', desc = 'zignite: run project' },
    },
    opts = {
      float = {
        border = 'single',
        border_hl = 'FloatBorder', -- Highlight group for the border
        border_hl_success = 'FloatBorder', -- Border color on success (exit 0)
        border_hl_error = 'FloatBorder', -- Border color on error (exit != 0)
      },
      keymaps = {
        { 'n', '<localleader>rr', ':RunFile<CR>', { desc = 'Run file' } },
        {
          'n',
          '<localleader>rb',
          ':RunBuildSelect<CR>',
          { desc = 'Select build command' },
        },
        { 'n', '<localleader>rq', ':RunClose<CR>', { desc = 'Close runner' } },
        { 'n', '<localleader>rp', ':RunProject<CR>', { desc = 'Run project' } },
      },
    },
    config = function(_, opts) require('zignite.config').setup(opts) end,
  },
  --------------------------------------------------------------------------------
  -- Snip Runner
  --------------------------------------------------------------------------------
  {
    'jellydn/quick-code-runner.nvim',
    cond = function()
      return ar.get_plugin_cond('quick-code-runner.nvim', coding)
    end,
    opts = { debug = true },
    init = function()
      ar.add_to_select('command_palette', { ['Code Pad'] = 'QuickCodePad' })
    end,
    cmd = { 'QuickCodeRunner', 'QuickCodePad' },
    keys = {
      {
        mode = 'v',
        '<leader>rs',
        ':QuickCodeRunner<CR>',
        desc = 'quick-runner: run selection',
      },
    },
  },
  {
    'michaelb/sniprun',
    build = 'sh install.sh',
    cmd = { 'SnipRun', 'SnipInfo' },
    cond = function() return ar.get_plugin_cond('sniprun', coding) end,
    init = function()
      vim.g.whichkey_add_spec({ '<leader>rs', group = 'SnipRun' })
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
        { SniprunVirtualTextOk = { link = 'DiagnosticVirtualTextInfo' } },
        { SniprunFloatingWinOk = { link = 'DiagnosticVirtualTextInfo' } },
        { SniprunVirtualTextErr = { link = 'DiffDelete' } },
        { SniprunFloatingWinErr = { link = 'DiffDelete' } },
      })
      require('sniprun').setup(opts)
    end,
  },
}
