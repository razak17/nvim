local border = rvim.style.border.current

rvim.lsp = {
  templates_dir = join_paths(rvim.get_runtime_dir(), 'site/after/ftplugin'),
  diagnostics = {
    signs = { active = true },
    underline = true,
    border = border,
    update_in_insert = false,
    severity_sort = true,
    virtual_text_spacing = 1,
    float = {
      border = border,
      focusable = true,
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
    format_on_save = { 'zsh', 'tmux', 'gitcommit', 'query' },
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
    Text = 'String',
    Method = 'TSMethod',
    Function = 'Function',
    Constructor = 'TSConstructor',
    Field = 'TSField',
    Variable = 'TSVariable',
    Class = 'TSStorageClass',
    Interface = 'Constant',
    Module = 'Include',
    Property = 'TSProperty',
    Unit = 'Constant',
    Value = 'Variable',
    Enum = 'Type',
    Keyword = 'Keyword',
    File = 'Directory',
    Reference = 'PreProc',
    Constant = 'Constant',
    Struct = 'Type',
    Snippet = 'Label',
    Event = 'Variable',
    Operator = 'Operator',
    TypeParameter = 'Type',
    Namespace = 'TSNamespace',
    Package = 'Include',
    String = 'String',
    Number = 'Number',
    Boolean = 'Boolean',
    Array = 'StorageClass',
    Object = 'Type',
    Key = 'TSField',
    Null = 'ErrorMsg',
    EnumMember = 'TSField',
  },
}
