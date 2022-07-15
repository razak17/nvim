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
  format_exclusions = { 'sumneko_lua', 'html', 'jsonls', 'quick_lint_js' },
  sqls_fts = { 'sql', 'mysql' },
  emmet_ft = {
    'html',
    'css',
    'javascriptreact',
    'javascript.jsx',
    'typescriptreact',
    'typescript.tsx',
  },
  override_servers = {
    'rust_analyzer',
  },
  configured_servers = {
    'astro',
    'bashls',
    'clangd',
    'clojure_lsp',
    'cmake',
    'cssls',
    'denols',
    'dockerls',
    'emmet_ls',
    'gopls',
    'grammarly',
    'graphql',
    'html',
    'jsonls',
    'marksman',
    'prismals',
    'pyright',
    'quick_lint_js',
    'rust_analyzer',
    'sumneko_lua',
    'svelte',
    'tailwindcss',
    'tsserver',
    'vimls',
    'vuels',
    'yamlls',
  },
  skipped_filetypes = {
    'edn',
    'dhall',
    'objcpp',
    'objc',
    'cuda',
    'rst',
    'plaintext',
    'blade',
    'aspnetcorerazor',
    'edge',
    'eelixir',
    'erb',
    'eruby',
    'haml',
    'handlebars',
    'hbs',
    'heex',
    'html-eex',
    'jade',
    'leaf',
    'liquid',
    'mustache',
    'njk',
    'nunjucks',
    'php',
    'razor',
    'reason',
    'rescript',
    'slim',
    'stylus',
    'sugarss',
    'twig',
  },
  kind_highlights = {
    Text = 'String',
    Method = 'Method',
    Function = 'Function',
    Constructor = 'TSConstructor',
    Field = 'Field',
    Variable = 'Variable',
    Class = 'Class',
    Interface = 'Constant',
    Module = 'Include',
    Property = 'Property',
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
    Key = 'Field',
    Null = 'ErrorMsg',
    EnumMember = 'Field',
  },
}
