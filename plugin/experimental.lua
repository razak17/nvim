if ar.plugins.minimal or not ar.has('nvim-treesitter') then return end

if
  not vim.fn.has('nvim-0.12') == 1 or ar.config.ui.cmdline.variant ~= 'extui'
then
  return
end

require('vim._extui').enable({ enable = true, msg = { target = 'msg' } })
