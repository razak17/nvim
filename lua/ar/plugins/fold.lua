local minimal = ar.plugins.minimal
local coding = ar.plugins.coding

return {
  {
    'chrisgrieser/nvim-origami',
    cond = function() return ar.get_plugin_cond('nvim-origami', not minimal) end,
    keys = {
      -- { 'h', function() require('origami').h() end, desc = 'close fold' },
      { 'l', function() require('origami').l() end, desc = 'open fold' },
    },
    init = function()
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
    end,
    event = 'UIEnter', -- needed for folds to load in time and comments being closed
    opts = {
      useLspFoldsWithTreesitterFallback = false, -- required for `autoFold`
      foldtext = {
        enabled = true,
        padding = 2,
        lineCount = { template = ' %d', hlgroup = 'Comment' },
        diagnosticsCount = false,
        gitsignsCount = false,
      },
      foldKeymaps = {
        setup = false, -- modifies `h` and `l`
        hOnlyOpensOnFirstColumn = false,
      },
    },
  },
  {
    'kevinhwang91/nvim-ufo',
    cond = function()
      local condition = not ar_config.plugin.custom.custom_fold.enable
        and not minimal
      return ar.get_plugin_cond('nvim-ufo', condition)
    end,
    event = 'UIEnter', -- needed for folds to load in time and comments being closed
    init = function() vim.opt.foldexpr = '0' end,
    -- stylua: ignore
    keys = {
		  { '<leader>uf', vim.cmd.UfoInspect, desc = 'ufo: fold info' },
      {
        'zr',
        function() require('ufo').openFoldsExceptKinds { 'comment', 'imports' } end,
        desc = 'ufo: open regular folds',
      },
      { 'zR', '<Cmd>lua require("ufo").openAllFolds()<CR>', desc = 'ufo: open all folds' },
      { 'zm', '<Cmd>lua require("ufo").closeFoldsWith()<CR>', desc = 'ufo: close folds with' },
      { 'zM', '<Cmd>lua require("ufo").closeAllFolds()<CR>', desc = 'ufo: close all folds' },
      { 'zK', '<Cmd>lua require("ufo").peekFoldedLinesUnderCursor()<CR>', desc = 'ufo: preview fold' },
      { 'z1', '<Cmd>lua require("ufo").closeFoldsWith(1)<CR>', desc = 'ufo: close L1 folds' },
      { 'z2', '<Cmd>lua require("ufo").closeFoldsWith(2)<CR>', desc = 'ufo: close L2 folds' },
      { 'z3', '<Cmd>lua require("ufo").closeFoldsWith(3)<CR>', desc = 'ufo: close L3 folds' },
      { 'z4', '<Cmd>lua require("ufo").closeFoldsWith(4)<CR>', desc = 'ufo: close L4 folds' },
      { 'zc' },
      { 'zo' },
      { 'zC' },
      { 'zO' },
      { 'za' },
      { 'zA' },
    },
    opts = function()
      local ft_map = { rust = 'lsp' }
      return {
        open_fold_hl_timeout = 0,
        preview = {
          win_config = {
            border = ar.ui.current.border.default,
            winhighlight = 'NormalFloat:FloatBorder,FloatBorder:FloatBorder',
            winblend = ar_config.ui.transparent.enable and 0 or 12,
          },
          mappings = {
            scrollB = '',
            scrollF = '',
            scrollU = '',
            scrollD = '',
            scrollE = '<C-e>',
            scrollY = '<C-y>',
            jumpTop = '',
            jumpBot = '',
            close = 'q',
            switch = '<Tab>',
            trace = '<CR>',
          },
        },
        enable_get_fold_virt_text = true,
        close_fold_kinds_for_ft = {
          default = { 'imports', 'comment' },
          c = { 'comment', 'region' },
          json = { 'array' },
          markdown = {}, -- avoid everything becoming folded
        },
        provider_selector = function(_, ft, _)
          return ft_map[ft] or { 'treesitter' }
        end,
        -- Ref: https://github.com/chrisgrieser/.config/blob/e33627772b472e28e852a00f0339d1d0d9787c73/nvim/lua/plugin-specs/ufo.lua?plain=1#L44
        -- show folds with number of folded lines instead of just the icon
        fold_virt_text_handler = function(
          virt_text,
          lnum,
          end_lnum,
          width,
          truncate
        )
          local hlgroup = 'NonText'
          local icon = ''
          local new_virt_text = {}
          local suffix = ('  %s %d'):format(icon, end_lnum - lnum)
          local suf_width = vim.fn.strdisplaywidth(suffix)
          local target_width = width - suf_width
          local cur_width = 0
          for _, chunk in ipairs(virt_text) do
            local chunk_text = chunk[1]
            local chunk_width = vim.fn.strdisplaywidth(chunk_text)
            if target_width > cur_width + chunk_width then
              table.insert(new_virt_text, chunk)
            else
              chunk_text = truncate(chunk_text, target_width - cur_width)
              local hl_group = chunk[2]
              table.insert(new_virt_text, { chunk_text, hl_group })
              chunk_width = vim.fn.strdisplaywidth(chunk_text)
              if cur_width + chunk_width < target_width then
                suffix = suffix
                  .. (' '):rep(target_width - cur_width - chunk_width)
              end
              break
            end
            cur_width = cur_width + chunk_width
          end
          table.insert(new_virt_text, { suffix, hlgroup })
          return new_virt_text
        end,
      }
    end,
    config = function(_, opts)
      ar.highlight.plugin('ufo', {
        theme = {
          ['onedark'] = {
            { UfoCursorFoldedLine = { link = 'Folded' } },
          },
        },
      })
      require('ufo').setup(opts)
    end,
    dependencies = 'kevinhwang91/promise-async',
  },
  {
    'dmtrKovalenko/fold-imports.nvim',
    cond = function() return ar.get_plugin_cond('fold-imports.nvim', coding) end,
    event = 'BufRead',
    opts = {},
  },
}
