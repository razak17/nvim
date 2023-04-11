return {
  {
    'folke/which-key.nvim',
    init = function()
      local which_key = require('which-key')

      which_key.setup({
        plugins = {
          spelling = { enabled = true },
        },
        icons = { breadcrumb = rvim.ui.icons.misc.double_chevron_right },
        window = { border = rvim.ui.current.border },
        layout = { align = 'center' },
        hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' },
        show_help = true,
      })

      which_key.register({
        [']'] = {
          name = '+next',
          ['<space>'] = 'add space below',
        },
        ['['] = {
          name = '+prev',
          ['<space>'] = 'add space above',
        },
        ['<leader>'] = {
          a = { name = 'Actions' },
          d = { name = 'Debugprint' },
          f = { name = 'Telescope' },
          fv = { name = 'Vim' },
          g = { name = 'Git' },
          h = { name = 'Gitsigns' },
          i = { name = 'Toggler' },
          l = { name = 'Lsp' },
          lt = { name = 'Toggle' },
          m = { name = 'Marks' },
          n = { name = 'Notify' },
          o = { name = 'Toggle' },
          r = { name = 'Run' },
          s = { name = 'Session' },
          t = { name = 'Test' },
        },
        ['<localleader>'] = {
          c = { name = 'Conceal' },
          d = { name = 'Dap' },
          g = { name = 'Git' },
          l = { name = 'Neogen' },
          n = { name = 'Neorg' },
          r = { name = 'Rest' },
          s = { name = 'Sniprun' },
          w = { name = 'Window' },
        },
      })

      which_key.register({
        l = 'lsp',
      }, { mode = 'x', prefix = '<leader>' })

      which_key.register({
        s = 'Sniprun',
      }, { mode = 'x', prefix = '<localleader>' })

      rvim.augroup('WhichKeyMode', {
        event = { 'FileType' },
        pattern = { 'which_key' },
        command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
      })
    end,
  },
  {
    'anuvyklack/hydra.nvim',
    event = 'VeryLazy',
    config = function()
      local Hydra = require('hydra')
      local border = rvim.ui.current.border
      local hint_opts = { position = 'bottom', border = border, type = 'window' }

      Hydra({
        name = 'Folds',
        mode = 'n',
        body = '<leader>z',
        color = 'teal',
        config = {
          invoke_on_body = true,
          hint = hint_opts,
        },
        heads = {
          { 'j', 'zj', { desc = 'next fold' } },
          { 'k', 'zk', { desc = 'previous fold' } },
          { 'l', require('fold-cycle').open_all, { desc = 'open folds underneath' } },
          { 'h', require('fold-cycle').close_all, { desc = 'close folds underneath' } },
          { '<Esc>', nil, { exit = true, desc = 'Quit' } },
        },
      })

      Hydra({
        name = 'Buffer management',
        mode = 'n',
        body = '<leader>b',
        color = 'teal',
        config = {
          hint = hint_opts,
          invoke_on_body = true,
        },
        heads = {
          { 'a', '<Cmd>CloseAllBuffers<CR>', { desc = 'close all' } },
          { 'c', '<Cmd>CloseUnusedBuffers<CR>', { desc = 'close unused' } },
          { 'd', function() require('mini.bufremove').delete(0, true) end, { desc = 'delete buffer(force)' } },
          { 'h', '<Plug>(CybuPrev)', { desc = 'prev buffer' } },
          { 'l', '<Plug>(CybuNext)', { desc = 'next buffer' } },
          { '<Esc>', nil, { exit = true, desc = 'Quit' } },
        },
      })

      Hydra({
        name = 'Side scroll',
        mode = 'n',
        body = 'z',
        config = {
          hint = hint_opts,
          on_enter = function() vim.cmd('IndentBlanklineDisable') end,
          on_exit = function() vim.cmd('IndentBlanklineEnable') end,
        },
        heads = {
          { 'h', '5zh' },
          { 'l', '5zl', { desc = '←/→' } },
          { 'H', 'zH' },
          { 'L', 'zL', { desc = 'half screen ←/→' } },
        },
      })

      Hydra({
        name = 'Window management',
        config = {
          invoke_on_body = false,
          hint = hint_opts,
        },
        mode = 'n',
        body = '<C-w>',
        heads = {
          -- Split
          { 's', '<C-w>s', { desc = 'split horizontally' } },
          { 'v', '<C-w>v', { desc = 'split vertically' } },
          { 'q', '<C-w>c', { desc = 'close window' } },
          -- Size
          { 'j', '2<C-w>+', { desc = 'increase height' } },
          { 'k', '2<C-w>-', { desc = 'decrease height' } },
          { 'h', '5<C-w>>', { desc = 'increase width' } },
          { 'l', '5<C-w><', { desc = 'decrease width' } },
          { '=', '<C-w>=', { desc = 'equalize' } },
          --
          { '<Esc>', nil, { exit = true } },
        },
      })

      Hydra({
        name = 'Wrap',
        mode = 'n',
        body = '<leader>w',
        color = 'teal',
        config = {
          hint = hint_opts,
          invoke_on_body = true,
        },
        heads = {
          { '"', [[ciw"<c-r>""<esc>]], { desc = 'double quotes' } },
          { "'", [[ciw'<c-r>"'<esc>]], { desc = 'single quotes' } },
          { '`', [[ciw`<c-r>"`<esc>]], { desc = 'backticks' } },
          { '|', [[ciw|<c-r>"|<esc>]], { desc = 'pipe' } },
          { ')', [[ciw(<c-r>")<esc>]], { desc = 'parenthesis' } },
          { '}', [[ciw{<c-r>"}<esc>]], { desc = 'curly bracket' } },
          { ']', [[ciw[<c-r>"]<esc>]], { desc = 'square bracket' } },
          { '<Esc>', nil, { exit = true, desc = 'Quit' } },
        },
      })

      local function run(method, args)
        return function()
          local dap = require('dap')
          if dap[method] then dap[method](args) end
        end
      end

      local hint = [[
   _n_: step over   _s_: Continue/Start   _b_: Breakpoint     _K_: Eval
   _i_: step into   _x_: Quit             ^ ^                 ^ ^
   _o_: step out    _X_: Stop             ^ ^
   _c_: to cursor   _C_: Close UI
   ^
   ^ ^              _q_: exit
  ]]

      Hydra({
        hint = hint,
        config = {
          color = 'pink',
          invoke_on_body = true,
          hint = hint_opts,
        },
        name = 'dap',
        mode = { 'n', 'x' },
        body = '<leader>dh',
        heads = {
          { 'n', run('step_over'), { silent = true } },
          { 'i', run('step_into'), { silent = true } },
          { 'o', run('step_out'), { silent = true } },
          { 'c', run('run_to_cursor'), { silent = true } },
          { 's', run('continue'), { silent = true } },
          { 'x', run('disconnect', { terminateDebuggee = false }), { exit = true, silent = true } },
          { 'X', run('close'), { silent = true } },
          {
            'C',
            ":lua require('dapui').close()<cr>:DapVirtualTextForceRefresh<CR>",
            { silent = true },
          },
          { 'b', run('toggle_breakpoint'), { silent = true } },
          { 'K', ":lua require('dap.ui.widgets').hover()<CR>", { silent = true } },
          { 'q', nil, { exit = true, nowait = true } },
        },
      })
    end,
  },
}
