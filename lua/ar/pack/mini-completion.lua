local enabled = ar.config.completion.variant == 'mini.completion'
if not ar.get_plugin_cond('mini.completion', enabled) then return end

local loaded = false
local function load()
  if loaded then return end
  vim.pack.add(
    { 'https://github.com/nvim-mini/mini.completion' },
    { confirm = false }
  )
  local opts =
    { lsp_completion = { source_func = 'omnifunc', auto_setup = false } }
  -- Customize post-processing of LSP responses for a better user experience.
  -- Don't show 'Text' suggestions (usually noisy) and show snippets last.
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end

  opts.lsp_completion.process_items = process_items

  require('mini.completion').setup(opts)

  vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })

  ar.augroup('MiniCompletionDisable', {
    event = { 'FileType' },
    desc = 'Disable completion for popups',
    command = function()
      if vim.fn.win_gettype() ~= 'popup' then return end
      vim.b.minicompletion_disable = true
    end,
  })
  loaded = true
end

if vim.v.vim_did_enter == 1 then
  vim.schedule(load)
else
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function() vim.schedule(load) end,
  })
end
