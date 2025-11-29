local niceties = ar.plugins.niceties

return {
  {
    desc = 'Display references, definitions and implementations of document symbols',
    'Wansmer/symbol-usage.nvim',
    cond = function()
      local condition = ar.lsp.enable and niceties
      return ar.get_plugin_cond('symbol-usage.nvim', condition)
    end,
    event = 'LspAttach',
    config = function()
          -- stylua: ignore
      ar.highlight.plugin('symbol-usage', {
            { SymbolUsageRounding = { italic = true, fg = { from = 'CursorLine', attr = 'bg' }, }, },
            { SymbolUsageContent = { italic = true, bg = { from = 'CursorLine' }, fg = { from = 'Comment' }, }, },
            { SymbolUsageRef = { italic = true, bg = { from = 'CursorLine' }, fg = { from = 'Function' }, }, },
            { SymbolUsageDef = { italic = true, bg = { from = 'CursorLine' }, fg = { from = 'Type' }, }, },
            { SymbolUsageImpl = { italic = true, bg = { from = 'CursorLine' }, fg = { from = '@keyword' }, }, },
            { SymbolUsageContent = { bold = false, italic = true, bg = { from = 'CursorLine' }, fg = { from = 'Comment' }, }, },
      })

      local function text_format(symbol)
        local res = {}

        local round_start = { '', 'SymbolUsageRounding' }
        local round_end = { '', 'SymbolUsageRounding' }

        if symbol.references then
          local usage = symbol.references <= 1 and 'usage' or 'usages'
          local num = symbol.references == 0 and 'no' or symbol.references
          table.insert(res, round_start)
          table.insert(res, { '󰌹 ', 'SymbolUsageRef' })
          table.insert(
            res,
            { ('%s %s'):format(num, usage), 'SymbolUsageContent' }
          )
          table.insert(res, round_end)
        end

        if symbol.definition then
          if #res > 0 then table.insert(res, { ' ', 'NonText' }) end
          table.insert(res, round_start)
          table.insert(res, { '󰳽 ', 'SymbolUsageDef' })
          table.insert(
            res,
            { symbol.definition .. ' defs', 'SymbolUsageContent' }
          )
          table.insert(res, round_end)
        end

        if symbol.implementation then
          if #res > 0 then table.insert(res, { ' ', 'NonText' }) end
          table.insert(res, round_start)
          table.insert(res, { '󰡱 ', 'SymbolUsageImpl' })
          table.insert(
            res,
            { symbol.implementation .. ' impls', 'SymbolUsageContent' }
          )
          table.insert(res, round_end)
        end

        return res
      end

      require('symbol-usage').setup({
        text_format = text_format,
      })
    end,
  },
  {
    desc = 'A lightweight nvim plugin that displays fully customizeable contextual information about functions',
    'oribarilan/lensline.nvim',
    tag = '1.0.0',
    cond = function()
      local condition = ar.lsp.enable and niceties
      return ar.get_plugin_cond('lensline.nvim', condition)
    end,
    event = 'LspAttach',
    config = function() require('lensline').setup() end,
  },
}
