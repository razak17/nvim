local M = {}

function M.move_to_file(client, buffer)
  client.commands['_typescript.moveToFileRefactoring'] = function(command, ctx)
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
return M
