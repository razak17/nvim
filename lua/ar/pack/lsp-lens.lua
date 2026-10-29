local cond = ar.lsp.enable and ar.plugins.niceties

---@type 'symbol-usage' | 'lensline'
local variant = 'symbol-usage'

local function get_cond(plugin, which)
  local condition = cond and variant == which
  return ar.get_plugin_cond(plugin, condition)
end

ar.pack.add({
  {
    src = 'https://github.com/Wansmer/symbol-usage.nvim',
    desc = 'Display references, definitions and implementations of document symbols',
    cond = get_cond('symbol-usage.nvim', 'symbol-usage'),
    event = 'LspAttach',
    setup = function()
      ar.highlight.plugin('symbol-usage', {
        {
          SymbolUsageRounding = {
            italic = true,
            fg = { from = 'CursorLine', attr = 'bg' },
          },
        },
        {
          SymbolUsageContent = {
            italic = true,
            bg = { from = 'CursorLine' },
            fg = { from = 'Comment' },
          },
        },
        {
          SymbolUsageRef = {
            italic = true,
            bg = { from = 'CursorLine' },
            fg = { from = 'Function' },
          },
        },
        {
          SymbolUsageDef = {
            italic = true,
            bg = { from = 'CursorLine' },
            fg = { from = 'Type' },
          },
        },
        {
          SymbolUsageImpl = {
            italic = true,
            bg = { from = 'CursorLine' },
            fg = { from = '@keyword' },
          },
        },
        {
          SymbolUsageContent = {
            bold = false,
            italic = true,
            bg = { from = 'CursorLine' },
            fg = { from = 'Comment' },
          },
        },
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
    src = 'https://github.com/oribarilan/lensline.nvim',
    desc = 'A lightweight nvim plugin that displays fully customizeable contextual information about functions',
    version = '1.0.0',
    cond = get_cond('lensline.nvim', 'lensline'),
    event = 'LspAttach',
    setup = function() require('lensline').setup() end,
  },
})
