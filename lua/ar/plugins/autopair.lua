local api = vim.api
local minimal = ar.plugins.minimal
local coding = ar.plugins.coding
local enabled = not minimal and coding
local get_cond = ar.get_plugin_cond
local is_blink = ar.has('blink.cmp')
local is_cmp = ar.has('nvim-cmp')

return {
  {
    'windwp/nvim-autopairs',
    cond = function()
      local condition = enabled and ar_config.completion.variant ~= 'omnifunc'
      return get_cond('nvim-autopairs', condition)
    end,
    event = 'InsertEnter',
    config = function()
      local autopairs = require('nvim-autopairs')
      if ar.completion.enable and (is_blink or is_cmp) then
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
      end
      autopairs.setup({
        close_triple_quotes = true,
        disable_filetype = { 'neo-tree-popup' },
        check_ts = true,
        fast_wrap = { map = '<c-e>' },
        ts_config = {
          lua = { 'string' },
          dart = { 'string' },
          javascript = { 'template_string' },
        },
      })
    end,
  },
  {
    'altermo/ultimate-autopair.nvim',
    cond = function() return get_cond('ultimate-autopair.nvim', enabled) end,
    event = { 'InsertEnter', 'CmdlineEnter' },
    init = function()
      ar.augroup('UltimateAutoPair', {
        event = { 'RecordingEnter' },
        command = function() require('ultimate-autopair').disable() end,
      }, {
        event = { 'RecordingLeave' },
        command = function() require('ultimate-autopair').enable() end,
      })
      ar.add_to_select_menu('command_palette', {
        ['Toggle Auto-pairing'] = function()
          require('ultimate-autopair').toggle()
          local mode = require('ultimate-autopair').isenabled() and 'enabled'
            or 'disabled'
          vim.notify(mode, nil, { title = 'Auto-pairing', icon = '' })
        end,
      })
    end,
    -- https://github.com/chrisgrieser/.config/blob/788aa7dc619410086e972d6da4177af29827d3e9/nvim/lua/plugin-specs/ultimate-autopair.lua?plain=1#L30
    opts = {
      bs = {
        space = 'balance',
        cmap = false, -- keep my `<BS>` mapping for the cmdline
      },
      fastwarp = {
        map = '<M-f>',
        rmap = '<M-F>', -- backwards
        hopout = true,
        nocursormove = true,
        multiline = false,
      },
      cr = { autoclose = false },
      tabout = { enable = false, map = '<Nop>' },
      extensions = { -- disable in these filetypes
        filetype = {
          nft = { 'TelescopePrompt', 'snacks_picker_input', 'rip-substitute' },
        },
      },
      config_internal_pairs = {
        { "'", "'", nft = { 'markdown', 'gitcommit' } }, -- used as apostrophe
        { '"', '"', nft = { 'vim' } }, -- uses as comments in vimscript
        { -- disable codeblocks, see https://github.com/Saghen/blink.cmp/issues/1692
          '`',
          '`',
          cond = function()
            local mdCodeblock = vim.bo.ft == 'markdown'
              and api.nvim_get_current_line():find('^[%s`]*$')
            return not mdCodeblock
          end,
        },
        { '```', '```', nft = { 'markdown' } },
      },
      -- INFO custom keys need to be "appended" to the opts as a list
      { '**', '**', ft = { 'markdown' } }, -- bold
      { [[\"]], [[\"]], ft = { 'zsh', 'json', 'applescript' } }, -- escaped quote
      -- commit scope (= only first word) for commit messages
      {
        '(',
        '): ',
        ft = { 'gitcommit' },
        cond = function(_) return not api.nvim_get_current_line():find(' ') end,
      },
      -- for keymaps like `<C-a>`
      { '<', '>', ft = { 'vim' } },
      {
        '<',
        '>',
        ft = { 'lua' },
        cond = function(fn)
          -- FIX https://github.com/altermo/ultimate-autopair.nvim/issues/88
          local in_lua_lua =
            vim.endswith(api.nvim_buf_get_name(0), '/ftplugin/lua.lua')
          return not in_lua_lua and fn.in_string()
        end,
      },
    },
  },
}
