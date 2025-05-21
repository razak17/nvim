local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties
local border = ar.ui.current.border

local buffer_hint = [[
_a_: close all         _d_: delete buffer                _l_: last buffer
_n_: next buffer       _N_: next buffer in history       _o_: delete others
_p_: previous buffer   _P_: previous buffer in history   _r_: reload buffer
_H_: previous tab      _L_: next tab
^
^ ^                 _<Esc>_: quit              _q_: exit
]]

local chatgpt_hint = [[
_a_: add tests      _c_: complete code    _d_: docstring
_e_: explain code   _f_: fix bugs         _g_: grammar correction
_k_: keywords       _o_: optimize code    _r_: code readability analysis
_t_: translate
^
              _<Esc>_: quit              _q_: exit
]]

local fold_hint = [[
_j_: next fold     _k_: previous fold
_l_: toggle fold   _h_: toggle fold
^
^ ^   _<Esc>_: quit      _q_: exit
]]

local side_scroll_hint = [[
_h_: left               _l_: right
_H_: half screen left   _L_: half screen right
^
^ ^   _<Esc>_: quit            _q_: exit
]]

local text_case_hint = [[
_-_: to dashcase      _/_: to pathcase       _._: to dotcase
_c_: to camelcase     _C_: to constantcase   _l_: to lowercase
_p_: to pascalcase    _s_: to snakecase      _t_: to titlecase
_u_: to upper case
^
^ ^         _<Esc>_: quit            _q_: exit
]]

local wrap_hint = [[
_"_: double quotes    _'_: single_quotes
_`_: backticks        _|_: pipe
_)_: parenthesis      _}_: curly bracket
_]_: square bracket   _/_: slash
^
^ ^   _<Esc>_: quit        _q_: exit
]]

local window_hint = [[
^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split
^^^^^^^^^^^^-------------  ^^-----------^^   ^^---------------
^ ^ _k_ ^ ^  ^ ^ _K_ ^ ^   ^   _<C-k>_   ^   _s_: horizontally
_h_ ^ ^ _l_  _H_ ^ ^ _L_   _<C-h>_ _<C-l>_   _v_: vertically
^ ^ _j_ ^ ^  ^ ^ _J_ ^ ^   ^   _<C-j>_   ^   _q_: close
focus^^^^^^  window^^^^^^  ^_=_: equalize^   _o_: remain only
^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^   _t_: move to new tab
^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^
]]

return {
  'smoka7/hydra.nvim',
  cond = not minimal,
  event = 'VeryLazy',
  config = function()
    local Hydra = require('hydra')
    local cmd = require('hydra.keymap-util').cmd
    local pcmd = require('hydra.keymap-util').pcmd
    local hint_opts = { position = 'bottom', border = border, type = 'window' }

    local splits = ar.reqcall('smart-splits')
    local bufdelete = ar.reqcall('snacks.bufdelete')
    local textcase = ar.reqcall('textcase')

    local base_config = function(opts)
      opts = opts or {}
      local default_opts = {
        invoke_on_body = true,
        hint = hint_opts,
      }
      if opts.hint then
        opts.hint = vim.tbl_extend('force', hint_opts, opts.hint)
      end
      return vim.tbl_extend('force', default_opts, opts)
    end

    Hydra({
      name = 'Folds',
      hint = fold_hint,
      mode = 'n',
      body = '<leader>z',
      color = 'teal',
      config = base_config(),
      heads = {
        { 'j', 'zj', { desc = 'next fold' } },
        { 'k', 'zk', { desc = 'previous fold' } },
        { 'l', 'za', { desc = 'toggle folds underneath' } },
        { 'h', 'za', { desc = 'toggle folds underneath' } },
        { 'q', nil, { exit = true, desc = 'Quit' } },
        { '<Esc>', nil, { exit = true, desc = 'Quit' } },
      },
    })

    Hydra({
      name = 'Buffer management',
      hint = buffer_hint,
      mode = 'n',
      body = '<leader>b',
      config = base_config({
        hint = { position = 'top' },
      }),
      heads = {
        { 'a', function() bufdelete.all() end, { desc = 'close all' } },
        { 'd', function() bufdelete.delete() end, { desc = 'delete buffer' } },
        { 'H', '<Cmd>tabprev<CR>', { desc = 'prev tab' } },
        { 'l', '<Cmd>e #<CR>', { desc = 'last buffer' } },
        { 'L', '<Cmd>tabnext<CR>', { desc = 'next tab' } },
        { 'n', '<Plug>(CybuNext)', { desc = 'next buffer' } },
        {
          'N',
          '<Plug>(buf-surf-forward)',
          { desc = 'next buffer (in history)' },
        },
        { 'o', function() bufdelete.other() end, { desc = 'delete others' } },
        { 'p', '<Plug>(CybuPrev)', { desc = 'prev buffer' } },
        { 'P', '<Plug>(buf-surf-back)', { desc = 'prev buffer (in history)' } },
        {
          'r',
          function()
            vim.cmd('edit!')
            print('Buffer reloaded')
          end,
          { desc = 'reload buffer' },
        },
        { 'q', nil, { exit = true, desc = 'Quit' } },
        { '<Esc>', nil, { exit = true, desc = 'Quit' } },
      },
    })

    Hydra({
      name = 'Side scroll',
      hint = side_scroll_hint,
      mode = 'n',
      body = 'z',
      config = base_config({
        invoke_on_body = false,
      }),
      heads = {
        { 'h', '5zh' },
        { 'l', '5zl', { desc = '←/→' } },
        { 'H', 'zH' },
        { 'L', 'zL', { desc = 'half screen ←/→' } },
        { 'q', nil, { exit = true, desc = 'Quit' } },
        { '<Esc>', nil, { exit = true, desc = 'Quit' } },
      },
    })

    Hydra({
      name = 'Window management',
      hint = window_hint,
      config = base_config({ invoke_on_body = false }),
      mode = 'n',
      body = '<C-w>',
      heads = {
        --- Move
        { 'h', '<C-w>h' },
        { 'j', '<C-w>j' },
        { 'k', pcmd('wincmd k', 'E11', 'close') },
        { 'l', '<C-w>l' },
        { 'N', '<Cmd>tabnew<CR>' },
        { 't', '<C-w>T' },

        { 'o', '<C-w>o', { exit = true, desc = 'remain only' } },
        { '<C-o>', '<C-w>o', { exit = true, desc = false } },
        -- Resize
        { '<C-h>', function() splits.resize_left(2) end },
        { '<C-j>', function() splits.resize_down(2) end },
        { '<C-k>', function() splits.resize_up(2) end },
        { '<C-l>', function() splits.resize_right(2) end },
        { '=', '<C-w>=', { desc = 'equalize' } },
        -- Split
        { 's', pcmd('split', 'E36') },
        { '<C-s>', pcmd('split', 'E36'), { desc = false } },
        { 'v', pcmd('vsplit', 'E36') },
        { '<C-v>', pcmd('vsplit', 'E36'), { desc = false } },
        -- Size
        { 'H', function() splits.swap_buf_left() end },
        { 'J', function() splits.swap_buf_down() end },
        { 'K', function() splits.swap_buf_up() end },
        { 'L', function() splits.swap_buf_right() end },

        -- { 'c', pcmd('close', 'E444') },
        { 'q', pcmd('close', 'E444'), { desc = 'close window' } },
        { '<C-c>', pcmd('close', 'E444'), { desc = false } },
        { '<C-q>', pcmd('close', 'E444'), { desc = false } },
        { 'q', nil, { exit = true, desc = 'Quit' } },
        { '<Esc>', nil, { exit = true } },
      },
    })

    local function change_case(word)
      return function() textcase.current_word(word) end
    end

    Hydra({
      name = 'TextCase',
      hint = text_case_hint,
      mode = 'n',
      body = '<localleader>w',
      color = 'chartreuse',
      config = base_config({ hint = { position = 'top' } }),
      heads = {
        { '-', change_case('to_dash_case'), { desc = 'to dashcase' } },
        { '/', change_case('to_path_case'), { desc = 'to pathcase' } },
        { '.', change_case('to_dot_case'), { desc = 'to dotcase' } },
        { 'c', change_case('to_camel_case'), { desc = 'to camelcase' } },
        { 'C', change_case('to_constant_case'), { desc = 'to constantcase' } },
        { 'l', change_case('to_lower_case'), { desc = 'to lowercase' } },
        { 'p', change_case('to_pascal_case'), { desc = 'to pascalcase' } },
        { 's', change_case('to_snake_case'), { desc = 'to snakecase' } },
        { 't', change_case('to_title_case'), { desc = 'to titlecase' } },
        { 'u', change_case('to_upper_case'), { desc = 'to uppercase' } },
        { 'q', nil, { exit = true, desc = 'Quit' } },
        { '<Esc>', nil, { exit = true, desc = 'Quit' } },
      },
    })

    Hydra({
      name = 'Wrap',
      hint = wrap_hint,
      mode = 'n',
      body = '<localleader>W',
      color = 'yellow',
      config = base_config({ hint = { position = 'top' } }),
      heads = {
        { '"', [[ciw"<c-r>""<esc>]], { desc = 'double quotes' } },
        { "'", [[ciw'<c-r>"'<esc>]], { desc = 'single quotes' } },
        { '`', [[ciw`<c-r>"`<esc>]], { desc = 'backticks' } },
        { '|', [[ciw|<c-r>"|<esc>]], { desc = 'pipe' } },
        { ')', [[ciw(<c-r>")<esc>]], { desc = 'parenthesis' } },
        { '}', [[ciw{<c-r>"}<esc>]], { desc = 'curly bracket' } },
        { ']', [[ciw[<c-r>"]<esc>]], { desc = 'square bracket' } },
        { '/', [[ciw/<c-r>"/<esc>]], { desc = 'square bracket' } },
        { '<Esc>', nil, { exit = true, desc = 'Quit' } },
        { 'q', nil, { exit = true, desc = 'Quit' } },
      },
    })

    if not minimal and niceties and ar.is_available('flirt.nvim') then
      local flirt = require('flirt')
      Hydra({
        name = 'Flirt',
        mode = 'n',
        body = '<leader>wf',
        color = 'lime',
        config = base_config({
          hint = { position = 'middle' },
        }),
        heads = {
          { 'k', function() flirt.move('up') end, { desc = 'move up' } },
          { 'j', function() flirt.move('down') end, { desc = 'move down' } },
          { 'h', function() flirt.move('left') end, { desc = 'move left' } },
          { 'l', function() flirt.move('right') end, { desc = 'move right' } },
          { '<Esc>', nil, { exit = true, desc = 'Quit' } },
          { 'q', nil, { exit = true, desc = 'Quit' } },
        },
      })
    end

    if ar.is_available('ChatGPT.nvim') then
      Hydra({
        name = 'ChatGPT',
        hint = chatgpt_hint,
        mode = { 'n', 'x' },
        body = '<leader>aa',
        config = base_config({
          color = 'teal',
          hint = { position = 'middle' },
        }),
        -- stylua: ignore
        heads = {
          { 'a', cmd 'ChatGPTRun add_tests', { desc = 'add tests' } },
          { 'c', cmd 'ChatGPTRun complete_code', { desc = 'complete code' } },
          { 'd', cmd 'ChatGPTRun docstring', { desc = 'docstring' } },
          { 'e', cmd 'ChatGPTRun explain_code', { desc = 'explain code' } },
          { 'f', cmd 'ChatGPTRun fix_bugs', { desc = 'fix bugs' } },
          { 'g', cmd 'ChatGPTRun grammar_correction', { desc = 'grammar correction' } },
          { 'k', cmd 'ChatGPTRun keywords', { desc = 'keywords' } },
          { 'o', cmd 'ChatGPTRun optimize_code', { desc = 'optimize code' } },
          { 'r', cmd 'ChatGPTRun code_readability_analysis', { desc = 'code readability analysis' } },
          { 't', cmd 'ChatGPTRun translate', { desc = 'translate' } },
          { 'q', nil, { exit = true, nowait = true } },
          { '<Esc>', nil, { exit = true, nowait = true } },
        },
      })
    end
  end,
}
