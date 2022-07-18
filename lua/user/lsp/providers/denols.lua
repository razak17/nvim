local opts = {
  root_dir = require('lspconfig').util.root_pattern('deno.json', 'deno.jsonc'),
  single_file_support = false,
}

return opts
