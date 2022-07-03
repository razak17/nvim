return function()
  rvim.autopairs = {
    setup = {
      active = true,
      on_config_done = nil,
      ---@usage auto insert after select function or method item
      map_complete = true,
      ---@usage  modifies the function or method delimiter by filetypes
      map_char = {
        all = '(',
        tex = '{',
      },
      ---@usage check bracket in same line
      enable_check_bracket_line = false,
      ---@usage check treesitter
      close_triple_quotes = true,
      check_ts = true,
      ts_config = {
        java = false,
        lua = { 'string', 'source' },
        javascript = { 'string', 'template_string' },
        fast_wrap = {
          map = '<c-e>',
        },
      },
      disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
      ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], '%s+', ''),
      enable_moveright = true,
      ---@usage disable when recording or executing a macro
      disable_in_macro = false,
      ---@usage add bracket pairs after quote
      enable_afterquote = true,
      ---@usage map the <BS> key
      map_bs = true,
      ---@usage map <c-w> to delete a pair if possible
      map_c_w = false,
      ---@usage disable when insert after visual block mode
      disable_in_visualblock = false,
      ---@usage  change default fast_wrap
      fast_wrap = {
        map = '<M-e>',
        chars = { '{', '[', '(', '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
        offset = 0, -- Offset from pattern match
        end_key = '$',
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        check_comma = true,
        highlight = 'Search',
        highlight_grey = 'Comment',
      },
    },
  }
  local autopairs = require('nvim-autopairs')
  local Rule = require('nvim-autopairs.rule')
  local cond = require('nvim-autopairs.conds')

  autopairs.setup({
    check_ts = rvim.autopairs.setup.check_ts,
    enable_check_bracket_line = rvim.autopairs.setup.enable_check_bracket_line,
    ts_config = rvim.autopairs.setup.ts_config,
    disable_filetype = rvim.autopairs.setup.disable_filetype,
    disable_in_macro = rvim.autopairs.setup.disable_in_macro,
    ignored_next_char = rvim.autopairs.setup.ignored_next_char,
    enable_moveright = rvim.autopairs.setup.enable_moveright,
    enable_afterquote = rvim.autopairs.setup.enable_afterquote,
    map_c_w = rvim.autopairs.setup.map_c_w,
    map_bs = rvim.autopairs.setup.map_bs,
    disable_in_visualblock = rvim.autopairs.setup.disable_in_visualblock,
    fast_wrap = rvim.autopairs.setup.fast_wrap,
  })

  autopairs.add_rule(Rule('$$', '$$', 'tex'))
  autopairs.add_rules({
    Rule('$', '$', { 'tex', 'latex' }) -- don't add a pair if the next character is %
      :with_pair(cond.not_after_regex_check('%%')) -- don't add a pair if  the previous character is xxx
      :with_pair(cond.not_before_regex_check('xxx', 3)) -- don't move right when repeat character
      :with_move(cond.none()) -- don't delete if the next character is xx
      :with_del(cond.not_after_regex_check('xx')) -- disable  add newline when press <cr>
      :with_cr(cond.none()),
  })
  autopairs.add_rules({
    Rule('$$', '$$', 'tex'):with_pair(function(opts)
      print(vim.inspect(opts))
      if opts.line == 'aa $$' then
        -- don't add pair on that line
        return false
      end
    end),
  })

  require('nvim-treesitter.configs').setup({ autopairs = { enable = true } })

  local ts_conds = require('nvim-autopairs.ts-conds')

  -- TODO: can these rules be safely added from "config.lua" ?
  -- press % => %% is only inside comment or string
  autopairs.add_rules({
    Rule('%', '%', 'lua'):with_pair(ts_conds.is_ts_node({ 'string', 'comment' })),
    Rule('$', '$', 'lua'):with_pair(ts_conds.is_not_ts_node({ 'function' })),
  })
end
