local path = vim.split(package.path, ';')
table.insert(path, 'lua/?.lua')
table.insert(path, 'lua/?/init.lua')

return {
  settings = {
    Lua = {
      runtime = {
        path = path,
        version = 'LuaJIT',
      },
      format = { enable = false },
      diagnostics = {
        globals = {
          'vim',
          'describe',
          'it',
          'before_each',
          'after_each',
          'packer_plugins',
          'rvim',
          'notify_opts',
          'pairs',
          'R',
          'join_paths',
        },
      },
      workspace = {
        library = {
          [join_paths(rvim.get_config_dir(), 'lua')] = true,
          [join_paths(rvim.get_runtime_dir(), 'site/pack/packer/start/emmylua-nvim')] = true,
        },
        telemetry = {
          enable = false,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}
