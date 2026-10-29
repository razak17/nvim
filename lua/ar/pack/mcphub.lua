ar.pack.add({
  {
    src = 'https://github.com/ravitemer/mcphub.nvim',
    cond = function() return ar.get_plugin_cond('mcphub.nvim', ar.ai.enable) end,
    cmd = { 'MCPHub' },
    dependencies = { { src = 'https://github.com/nvim-lua/plenary.nvim' } },
    keys = { { '<leader>am', '<Cmd>MCPHub<CR>', desc = 'mcphub: toggle' } },
    build = {
      vim.v.progpath,
      '--clean',
      '--headless',
      '-l',
      'bundled_build.lua',
    },
    setup = function()
      require('mcphub').setup({
        port = 37373,
        config = vim.fn.expand('~/.config/mcphub/servers.json'),
        use_bundled_binary = true, -- Use local `mcp-hub` binary (set this to true when using build = "bundled_build.lua"
        extensions = {
          avante = { make_slash_commands = true },
        },
        ui = { window = { border = ar.ui.current.border.default } },
        log = {
          level = vim.log.levels.INFO,
          to_file = true,
          file_path = vim.fn.stdpath('state') .. '/mcphub.log',
          prefix = 'MCPHub',
        },
      })
    end,
  },
})
