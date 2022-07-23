local opts = {
  root_dir = require('lspconfig').util.root_pattern(
    'tailwind.config.js',
    'tailwind.config.ts',
    'postcss.config.js',
    'postcss.config.ts'
  ),
  single_file_support = false,
}

return opts
