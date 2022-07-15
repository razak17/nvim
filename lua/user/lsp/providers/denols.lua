local opts = {
  root_dir = function(fname)
    local util = require('lspconfig/util')
    return util.root_pattern('deno.json')(fname) or util.root_pattern('deno.jsonc')(fname)
  end,
}

return opts
