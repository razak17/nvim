local nnoremap = require'keymap.map'.nnoremap

require 'modules.dbg.dap.typescript'

-- dap
nnoremap('<leader>dc', '<cmd>lua require"dap".continue()<CR>')
nnoremap('<leader>dsv', '<cmd>lua require"dap".step_over()<CR>')
nnoremap('<leader>dsi', '<cmd>lua require"dap".step_into()<CR>')
nnoremap('<leader>dso', '<cmd>lua require"dap".step_out()<CR>')
nnoremap('<leader>dtb', '<cmd>lua require"dap".toggle_breakpoint()<CR>')
nnoremap('<leader>dsbr',
         '<cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
nnoremap('<leader>dsbm',
         '<cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>')
nnoremap('<leader>dro', '<cmd>lua require"dap".repl.open()<CR>')
nnoremap('<leader>drl', '<cmd>lua require"dap".repl.run_last()<CR>')

-- telescope-dap
nnoremap('<leader>fdcc',
         '<cmd>lua require"telescope".extensions.dap.commands{}<CR>')
nnoremap('<leader>fdco',
         '<cmd>lua require"telescope".extensions.dap.configurations{}<CR>')
nnoremap('<leader>fdlb',
         '<cmd>lua require"telescope".extensions.dap.list_breakpoints{}<CR>')
nnoremap('<leader>fdv',
         '<cmd>lua require"telescope".extensions.dap.variables{}<CR>')
nnoremap('<leader>df', '<cmd>lua require"telescope".extensions.dap.frames{}<CR>')
