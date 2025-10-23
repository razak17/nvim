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
    local win = vim.api.nvim_get_current_win()
    local params = vim.lsp.util.make_position_params(win, 'utf-16')
    execute({
      command = 'typescript.goToSourceDefinition',
      arguments = { params.textDocument.uri, params.position },
    })
  end, 'Goto Source Definition')
  ts_cmd(
    'FileReferences',
    function()
      execute({
        command = 'typescript.findAllFileReferences',
        arguments = { vim.uri_from_bufnr(0) },
      })
    end,
    'File References'
  )
  ts_cmd(
    'SelectWorkspaceVersion',
    function() execute({ command = 'typescript.selectTypeScriptVersion' }) end,
    'Select TS workspace version'
  )
end

-- vtsls move to file code action
-- https://github.com/LazyVim/LazyVim/issues/3534
-- https://github.com/LazyVim/LazyVim/blob/3a743f7f853bd90894259cd93432d77c688774b4/lua/lazyvim/plugins/extras/lang/typescript.lua?plain=1#L134
if
  vim.tbl_contains(override, 'vtsls') or (falsy(override) and ts_lang['vtsls'])
then
  local function on_attach(client, buffer)
    client.commands['_typescript.moveToFileRefactoring'] = function(
      command,
      ctx
    )
      ---@type string, string, lsp.Range
      local action, uri, range = unpack(command.arguments)

      local function move(newf)
        client:request('workspace/executeCommand', {
          command = command.command,
          arguments = { action, uri, range, newf },
        })
      end

      local fname = vim.uri_to_fname(uri)
      client:request('workspace/executeCommand', {
        command = 'typescript.tsserverRequest',
        arguments = {
          'getMoveToRefactoringFileSuggestions',
          {
            file = fname,
            startLine = range.start.line + 1,
            startOffset = range.start.character + 1,
            endLine = range['end'].line + 1,
            endOffset = range['end'].character + 1,
          },
        },
      }, function(_, result)
        ---@type string[]
        local files = result.body.files
        table.insert(files, 1, 'Enter new path...')
        vim.ui.select(files, {
          prompt = 'Select move destination:',
          format_item = function(f) return vim.fn.fnamemodify(f, ':~:.') end,
        }, function(f)
          if f and f:find('^Enter new path') then
            vim.ui.input({
              prompt = 'Enter move destination:',
              default = vim.fn.fnamemodify(fname, ':h') .. '/',
              completion = 'file',
            }, function(newf) return newf and move(newf) end)
          elseif f then
            move(f)
          end
        end)
      end)
    end
  end

  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (client.name == 'vtsls') then
        return on_attach(client, buffer)
      end
    end,
  })
end
