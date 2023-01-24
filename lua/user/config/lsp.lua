local border = rvim.style.current.border

rvim.lsp = {
  templates_dir = join_paths(rvim.get_runtime_dir(), 'site', 'after', 'ftplugin'),
  diagnostics = {
    signs = { active = true },
    underline = true,
    border = border,
    update_in_insert = false,
    severity_sort = true,
    virtual_text_spacing = 1,
    float = {
      border = border,
      focusable = false,
      style = 'minimal',
      source = 'always',
      header = '',
      format = function(d)
        local t = vim.deepcopy(d)
        local code = d.code or (d.user_data and d.user_data.lsp.code)
        if code then t.message = string.format('%s [%s]', t.message, code):gsub('1. ', '') end
        return t.message
      end,
    },
  },
  automatic_servers_installation = true,
  hover_diagnostics = true,
  format_exclusions = {
    format_on_save = { 'zsh' },
    servers = {
      lua = { 'sumneko_lua' },
      go = { 'null-ls' },
      proto = { 'null-ls' },
      html = { 'html' },
      javascript = { 'quick_lint_js', 'tsserver' },
      typescript = { 'tsserver' },
      typescriptreact = { 'tsserver' },
      javascriptreact = { 'tsserver' },
      sql = { 'sqls' },
    },
  },
  configured_filetypes = {
    'lua',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'python',
    'go',
    'rust',
    'yaml',
    'vue',
    'vim',
    'json',
    'jsonc',
    'html',
    'css',
    'sh',
    'zsh',
    'markdown',
    'graphql',
    'sql',
    'prisma',
  },
  kind_highlights = {
    Text = '@string',
    Method = '@method',
    Function = '@function',
    Constructor = '@constructor',
    Field = '@field',
    Variable = '@variable',
    Class = '@storageclass',
    Interface = '@constant',
    Module = '@include',
    Property = '@property',
    Unit = '@constant',
    Value = '@variable',
    Enum = '@type',
    Keyword = '@keyword',
    File = 'Directory',
    Reference = '@preProc',
    Constant = '@constant',
    Struct = '@type',
    Snippet = '@label',
    Event = '@variable',
    Operator = '@operator',
    TypeParameter = '@type',
    Namespace = '@namespace',
    Package = '@include',
    String = '@string',
    Number = '@number',
    Boolean = '@boolean',
    Array = '@storageclass',
    Object = '@type',
    Key = '@field',
    Null = '@error',
    EnumMember = '@field',
  },
}
