local border = rvim.style.border.current

rvim.lsp = {
  templates_dir = join_paths(rvim.get_config_dir(), 'after', 'ftplugin'),
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
  document_highlight = true,
  code_lens_refresh = true,
  float = {
    focusable = false,
    style = 'minimal',
    border = border,
  },
  automatic_servers_installation = true,
  hover_diagnostics = false,
  format_on_save_exclusions = { 'zsh', 'tmux', 'gitcommit', 'query' },
  format_exclusions = {
    {
      lua = { 'sumneko_lua' },
      go = { 'null-ls' },
      proto = { 'null-ls' },
      html = { 'html' },
      javascript = { 'quick_lint_js', 'tsserver' },
      typescript = { 'tsserver' },
      typescriptreact = { 'tsserver' },
      javascriptreact = { 'tsserver' },
    },
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
