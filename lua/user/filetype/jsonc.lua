local extension = vim.fn.expand('%:e')
if extension == 'jsonschema' then
  vim.opt_local.shiftwidth = 2
  vim.opt_local.softtabstop = 2
  vim.opt_local.tabstop = 2
end
