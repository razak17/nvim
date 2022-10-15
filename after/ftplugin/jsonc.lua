local extension = vim.fn.expand('%:e')
if extension == 'jsonschema' then
  vim.bo.shiftwidth = 2
  vim.bo.softtabstop = 2
  vim.bo.tabstop = 2
end
