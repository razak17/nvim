local enabled = ar.config.plugin.custom.replace_word.enable

if not ar or ar.none or not enabled then return end

local fn = vim.fn

local function replace_word(transform_fn, prompt_suffix, edit)
  return function()
    local value = fn.expand('<cword>')
    local default_value = transform_fn(value)
    vim.ui.input({
      prompt = 'Replace word with ' .. prompt_suffix,
      default = edit and default_value or '',
    }, function(new_value)
      if not new_value then return end
      vim.cmd('%s/' .. value .. '/' .. transform_fn(new_value) .. '/gI')
    end)
  end
end

map(
  'n',
  '<leader>[[',
  replace_word(function(x) return x end, ''),
  { desc = 'replace word in file' }
)
map(
  'n',
  '<leader>[e',
  replace_word(function(x) return x end, '', true),
  { desc = 'edit word in file' }
)
map(
  'n',
  '<leader>[u',
  replace_word(fn.toupper, 'UPPERCASE'),
  { desc = 'replace word in file with UPPERCASE' }
)
map(
  'n',
  '<leader>[l',
  replace_word(fn.tolower, 'lowercase'),
  { desc = 'replace word in file with lowercase' }
)
