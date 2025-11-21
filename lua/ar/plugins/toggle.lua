local coding = ar.plugins.coding
local get_cond = ar.get_plugin_cond

return {
  ------------------------------------------------------------------------------
  -- Toggle Text
  ------------------------------------------------------------------------------
  {
    'nguyenvukhang/nvim-toggler',
    cond = function() return get_cond('nvim-toggler', coding) end,
    -- stylua: ignore
    keys = {
      { '<leader>ii', function() require("nvim-toggler").toggle() end, desc = 'nvim-toggler: toggle', },
    },
    opts = {
      remove_default_keybinds = true,
      inverses = {
        ['=='] = '~=',
        ['==='] = '!==',
        ['vim'] = 'emacs',
        ['let'] = 'const',
        ['margin'] = 'padding',
        ['-'] = '+',
        ['onClick'] = 'onSubmit',
        ['public'] = 'private',
        ['string'] = 'int',
        ['leader'] = 'localleader',
        ['chore'] = 'feat',
        ['double'] = 'single',
        ['config'] = 'opts',
        ['pre'] = 'post',
        ['column'] = 'row',
        ['before'] = 'after',
        ['end'] = 'start',
        ['high'] = 'low',
        ['open'] = 'close',
        ['and'] = 'or',
        ['GET'] = 'POST',
      },
    },
  },
}
