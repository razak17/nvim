vim.bo.textwidth = 100
vim.opt.spell = true

local interface_to_type = require('ar.interface_to_type').interface_to_type

map(
  'n',
  '<leader><leader>ti',
  interface_to_type,
  { buffer = true, desc = 'interface to type' }
)
map('i', 't', require('ar.async_func').add, { buffer = true })

ar.command('InterfaceToType', interface_to_type, {})

ar.add_to_select_menu('command_palette', {
  ['Interface to Type'] = interface_to_type,
})

if not ar.lsp.enable then return end

local falsy = ar.falsy
local override = ar_config.lsp.override
local ts_lang = ar_config.lsp.lang.typescript

if
  vim.tbl_contains(override, 'ts_ls') or (falsy(override) and ts_lang['ts_ls'])
then
  local sources = {
  add_missing_imports = 'source.addMissingImports.ts',
  organize_imports = 'source.organizeImports',
  remove_unused = 'source.removeUnused',
  fix_all = 'source.fixAll.ts',
  }

  local function action(source)
  return function()
    vim.lsp.buf.code_action({
      apply = true,
      context = {
        only = { source },
        diagnostics = {},
      },
    })
  end
  end

  local function execute(opts)
  local params = {
    command = opts.command,
    arguments = opts.arguments,
  }
  return vim.lsp.buf_request(
    0,
    'workspace/executeCommand',
    params,
    opts.handler
  )
  end

  ---@param name string
  ---@param cb function
  ---@param desc string
  local function ts_cmd(name, cb, desc)
  vim.api.nvim_buf_create_user_command(0, name, cb, { desc = desc })
  end

  ts_cmd(
  'AddMissingImports',
  action(sources.add_missing_imports),
  'Add missing imports'
  )
  ts_cmd(
    'OrganizeImports',
    action(sources.organize_imports),
    'Organize imports'
  )
  ts_cmd('RemoveUnused', action(sources.remove_unused), 'Remove unused')
  ts_cmd('FixAll', action(sources.fix_all), 'Fix All')
  ts_cmd('GotoSourceDefinition', function()
  local params = vim.lsp.util.make_position_params()
  execute({
    command = 'typescript.goToSourceDefinition',
    arguments = { params.textDocument.uri, params.position },
  })
  end, 'Goto Source Definition')
  ts_cmd(
  'FileReferences',
  execute({
    command = 'typescript.findAllFileReferences',
    arguments = { vim.uri_from_bufnr(0) },
  }),
  'File References'
  )
  ts_cmd(
  'SelectWorkspaceVersion',
  execute({ command = 'typescript.selectTypeScriptVersion' }),
  'Select TS workspace version'
  )
end
