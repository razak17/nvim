local api, lsp = vim.api, vim.lsp
local is_biome = ar_config.lsp.lang.web.biome
  or vim.tbl_contains(ar_config.lsp.override, 'biome')
local conform = ar.has('conform.nvim')

local format_exclusions = {
  format_on_save = { 'zsh' },
  servers = {
    lua = { 'lua_ls' },
    go = { 'null-ls' },
    proto = { 'null-ls' },
    html = { 'html' },
    javascript = { 'quick_lint_js', 'ts_ls', 'vts_ls', 'typescript-tools' },
    json = { 'jsonls' },
    typescript = { 'ts_ls', 'vts_ls', 'typescript-tools' },
    typescriptreact = { 'ts_ls', 'vts_ls', 'typescript-tools' },
    javascriptreact = { 'ts_ls', 'vts_ls', 'typescript-tools' },
    svelte = { 'svelte' },
  },
}

local function formatting_filter(client)
  local exceptions = (format_exclusions.servers)[vim.bo.filetype]
  if not exceptions then return true end
  return not vim.tbl_contains(exceptions, client.name)
end

-- https://github.com/chrisgrieser/.config/blob/main/nvim/after/ftplugin/typescript.lua?plain=1#L13
local function biome_format()
  local bufnr = api.nvim_get_current_buf()
  local client = lsp.get_clients({ bufnr = bufnr, name = 'biome' })[1]

  -- format client filter, to only format items for one single client, so a format operation for biome doesn't drag tsserver in.
  local client_filter = function(formatter) return formatter.name == client.name end

  -- Step 1: Apply fixAll synchronously
  local win = api.nvim_get_current_win()
  local params = lsp.util.make_range_params(win, client.offset_encoding)
  params.context = {
    only = { 'source.fixAll.biome' },
    diagnostics = {},
  }

  local fixall_results = lsp.buf_request_sync(
    bufnr,
    'textDocument/codeAction',
    params,
    1000 -- 1 second timeout
  )

  if fixall_results then
    -- Don't need client id, since only biome is running this action
    for _, result in pairs(fixall_results) do
      if result.result then
        for _, action in ipairs(result.result) do
          if action.edit then
            lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
          elseif action.command then
            client:exec_cmd(action.command)
          end
        end
      end
    end
  end

  -- Step 2: Wait a tiny bit for edits to settle
  vim.cmd('redraw')

  -- Step 3: Format synchronously
  lsp.buf.format({
    async = false,
    filter = client_filter,
    timeout_ms = 3000,
  })

  -- local actions = { 'source.fixAll.biome' }
  -- for i = 1, #actions do
  --   vim.defer_fn(function()
  --     lsp.buf.code_action({
  --       ---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
  --       context = { only = { actions[i] } },
  --       apply = true,
  --     })
  --   end, i * 60)
  -- end
  -- vim.defer_fn(lsp.buf.format, (#actions + 2) * 60)
end

---@param opts {bufnr: integer, async: boolean, filter: fun(lsp.Client): boolean}
local function conform_format(opts)
  local client_names = vim.tbl_map(
    function(client) return client.name end,
    lsp.get_clients({ bufnr = opts.bufnr })
  )
  local lsp_fallback
  local lsp_fallback_inclusions = { 'eslint' }
  for _, c in pairs(client_names) do
    if vim.tbl_contains(lsp_fallback_inclusions, c) then
      lsp_fallback = 'always'
      break
    end
  end
  require('conform').format({
    bufnr = opts.bufnr,
    async = true,
    timeout_ms = 500,
    lsp_fallback = lsp_fallback or true,
  })
end

---@param opts {bufnr: integer, async: boolean, filter: fun(lsp.Client): boolean}
local function format(opts)
  opts = opts or {}
  if is_biome then
    biome_format()
    return
  end
  if conform then
    conform_format(opts)
    return
  end
  lsp.buf.format({
    bufnr = opts.bufnr,
    async = opts.async,
    filter = formatting_filter,
  })
end

-- https://www.reddit.com/r/neovim/comments/1nx21rx/keymap_for_formatting_visually_selected_lines/
local function format_visual_selected_range()
  local esc = api.nvim_replace_termcodes('<Esc>', true, false, true)
  api.nvim_feedkeys(esc, 'x', false)

  local start_row, _ = unpack(api.nvim_buf_get_mark(0, '<'))
  local end_row, _ = unpack(api.nvim_buf_get_mark(0, '>'))

  lsp.buf.format({
    range = {
      ['start'] = { start_row, 0 },
      ['end'] = { end_row, 0 },
    },
    async = true,
  })

  vim.notify('Formatted range (' .. start_row .. ',' .. end_row .. ')')
end

return {
  format = format,
  visual_format = format_visual_selected_range,
}
