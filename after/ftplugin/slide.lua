if not rvim or vim.env.RVIM_LSP_ENABLED == '0' or vim.env.RVIM_PLUGINS_ENABLED == '0' then return end

local fmt = string.format
local function with_desc(desc) return { buffer = 0, desc = fmt('slides: %s', desc) } end

map('n', '<localleader>aa', '<Cmd>SlideAscii term<CR>', with_desc('ascii term'))
map('n', '<localleader>aA', '<Cmd>SlideAscii bigascii12<CR>', with_desc('ascii bigascii12'))
map('n', '<localleader>ab', '<Cmd>SlideAscii bfraktur<CR>', with_desc('ascii bfraktur'))
map('n', '<localleader>ae', '<Cmd>SlideAscii emboss<CR>', with_desc('ascii emboss'))
map('n', '<localleader>aE', '<Cmd>SlideAscii emboss2<CR>', with_desc('ascii emboss2'))
map('n', '<localleader>al', '<Cmd>SlideAscii letter<CR>', with_desc('ascii letter'))
map('n', '<localleader>am', '<Cmd>SlideAscii bigmono12<CR>', with_desc('ascii bigmono12'))
map('n', '<localleader>aw', '<Cmd>SlideAscii wideterm<CR>', with_desc('ascii wideterm'))
