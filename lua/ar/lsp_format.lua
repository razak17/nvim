local lsp = vim.lsp
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
  local actions = { 'source.fixAll.biome' }
  for i = 1, #actions do
    vim.defer_fn(function()
      lsp.buf.code_action({
        ---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
        context = { only = { actions[i] } },
        apply = true,
      })
    end, i * 60)
  end
  vim.defer_fn(lsp.buf.format, (#actions + 2) * 60)
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
return function(opts)
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
