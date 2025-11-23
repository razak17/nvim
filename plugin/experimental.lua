if ar.plugins.minimal or not ar.has('nvim-treesitter') then return end

if vim.fn.has('nvim-0.12') == 1 then
  require('vim._extui').enable({ enable = true, msg = { target = 'msg' } })
end
