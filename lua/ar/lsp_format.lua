local api, lsp = vim.api, vim.lsp
local is_biome = ar.config.lsp.lang.web.biome
  or vim.tbl_contains(ar.config.lsp.override, 'biome')
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

---@param client vim.lsp.Client
local function formatting_filter(client)
  local exceptions = (format_exclusions.servers)[vim.bo.filetype]
  if not exceptions then return true end
  return not vim.tbl_contains(exceptions, client.name)
end

-- https://github.com/biomejs/biome/discussions/7931
---@param client vim.lsp.Client
---@param bufnr number
local function biome_format(client, bufnr)
  local win = api.nvim_get_current_win()
  local params = lsp.util.make_range_params(win, client.offset_encoding)
  ---@diagnostic disable-next-line: inject-field
  params.context = { only = { 'source.fixAll.biome' }, diagnostics = {} }

  local fixall_results =
    lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params, 1000)

  if fixall_results then
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

  vim.cmd('redraw')

  lsp.buf.format({
    bufnr = bufnr,
    async = false,
    filter = function(formatter) return formatter.name == client.name end,
    timeout_ms = 3000,
  })
end

---@param bufnr number
local function conform_format(bufnr)
  local client_names = vim.tbl_map(
    function(client) return client.name end,
    lsp.get_clients({ bufnr = bufnr })
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
    bufnr = bufnr,
    async = true,
    lsp_fallback = lsp_fallback or true,
    timeout_ms = 500,
  })
end

---@param opts {bufnr: integer, async: boolean, filter: fun(vim.lsp.Client): boolean}
local function format(opts)
  opts = opts
    or {
      async = opts and opts.async or false,
      bufnr = opts and opts.bufnr or api.nvim_get_current_buf(),
    }

  local has_biome = is_biome
  if not ar.falsy(ar.config.lsp.override) then
    has_biome = vim.tbl_contains(ar.config.lsp.override, 'biome')
  end
  if has_biome then
    local client = lsp.get_clients({ bufnr = opts.bufnr, name = 'biome' })
    if client and client[1] then biome_format(client[1], opts.bufnr) end
    return
  end
  if conform then
    conform_format(opts.bufnr)
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
