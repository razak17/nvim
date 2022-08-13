if not rvim or not rvim.plugin_loaded('nvim-surround') then return end

local nnoremap = rvim.nnoremap
local fmt = string.format

vim.opt_local.textwidth = 100
vim.opt_local.iskeyword:append('-')
vim.opt_local.formatoptions:remove('o')

local function find(word, ...)
  for _, str in ipairs({ ... }) do
    local match_start, match_end = string.find(word, str)
    if match_start then return str, match_start, match_end end
  end
end

local fn = vim.fn

--- Stolen from nlua.nvim this function attempts to open
--- vim help docs if an api or vim.fn function otherwise it
--- shows the lsp hover doc
--- @param word string
--- @param callback function
local function keyword(word, callback)
  local original_iskeyword = vim.bo.iskeyword

  vim.bo.iskeyword = vim.bo.iskeyword .. ',.'
  word = word or fn.expand('<cword>')

  vim.bo.iskeyword = original_iskeyword

  -- TODO: This is a sub par work around, since I usually rename `vim.api` -> `api` or similar
  -- consider maybe using treesitter in the future
  local api_match = find(word, 'api', 'vim.api')
  local fn_match = find(word, 'fn', 'vim.fn')
  if api_match then
    local _, finish = string.find(word, api_match .. '.')
    local api_function = string.sub(word, finish + 1)

    vim.cmd.help(api_function)
    return
  end
  if fn_match then
    local _, finish = string.find(word, fn_match .. '.')
    if not finish then return end
    local api_function = string.sub(word, finish + 1) .. '()'

    vim.cmd.help(api_function)
    return
  end
  if callback then
    callback()
    return
  end
  vim.lsp.buf.hover()
end

rvim.ftplugin_conf('nvim-surround', function(surround)
  local get_input = function(prompt)
    local ok, input = pcall(vim.fn.input, fmt('%s: ', prompt))
    if not ok then return end
    return input
  end
  surround.buffer_setup({
    surrounds = {
      l = {
        add = { 'function () ', ' end' },
      },
      F = {
        add = function()
          return {
            { fmt('local function %s() ', get_input('Enter a function name')) },
            { ' end' },
          }
        end,
      },
      i = {
        add = function()
          return {
            { fmt('if %s then ', get_input('Enter a condition')) },
            { ' end' },
          }
        end,
      },
      t = {
        add = function()
          return {
            { fmt('{ %s = { ', get_input('Enter a field name')) },
            { ' }}' },
          }
        end,
      },
    },
  })
end)

nnoremap('gK', keyword, { buffer = 0, desc = 'goto keyword' })
nnoremap('<leader>so', function()
  vim.cmd.luafile('%')
  vim.notify('Sourced ' .. fn.expand('%'))
end, 'source current file')
