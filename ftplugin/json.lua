-- require'lsp.json'.format()
-- require'lsp.json'.lint()
-- require'lsp.json'.init()

-- require"lspconfig".jsonls.setup {
--   cmd = {rvim.lang.lsp.binary.json, '--stdio'},
--   -- Set the schema so that it can be completed in settings json file.
--   settings = {json = {schemas = require'nlspsettings.jsonls'.get_default_schemas()}},
-- }

require("lsp").setup "json"
