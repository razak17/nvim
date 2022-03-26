setlocal shiftwidth=4
setlocal softtabstop=0
setlocal tabstop=4
setlocal noexpandtab
setlocal textwidth=100
setlocal iskeyword+="
setlocal shiftwidth=4

lua << EOF
if not rvim then
  return
end
local ok, whichkey = rvim.safe_require 'which-key'
if not ok then
  return
end

whichkey.register {
  ['<leader>g'] = {
    name = '+Go',
    b = { '<Cmd>GoBuild<CR>', 'build' },
    f = {
      name = '+fix/fill',
      s = { '<Cmd>GoFillStruct<CR>', 'fill struct' },
      p = { '<Cmd>GoFixPlurals<CR>', 'fix plurals' },
    },
    ie = { '<Cmd>GoIfErr<CR>', 'if err' },
  },
}
EOF
