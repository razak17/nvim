local config = {}

function config.nvim_treesitter()
  require('modules.lang.ts').setup()
end

return config


