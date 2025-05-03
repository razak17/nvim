-- https://gist.github.com/MariaSolOs/2e44a86f569323c478e5a078d0cf98cc
---For replacing certain <C-x>... keymaps.
---@param keys string
local function feedkeys(keys)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(keys, true, false, true),
    'n',
    true
  )
end

---Is the completion menu open?
local function pumvisible() return tonumber(vim.fn.pumvisible()) ~= 0 end

local M = vim.lsp.protocol.Methods

---@param client vim.lsp.Client
---@param bufnr integer
return function(client, bufnr)
  -- Enable completion and configure keybindings.
  if client:supports_method(M.textDocument_completion) then
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

    -- Use enter to accept completions.
    map(
      'i',
      '<CR>',
      function() return pumvisible() and '<C-y>' or '<cr>' end,
      { expr = true, buffer = bufnr }
    )

    -- Use slash to dismiss the completion menu.
    map(
      'i',
      '/',
      function() return pumvisible() and '<C-e>' or '/' end,
      { expr = true, buffer = bufnr }
    )

    -- Use <C-n> to navigate to the next completion or:
    -- - Trigger LSP completion.
    -- - If there's no one, fallback to vanilla omnifunc.
    map('i', '<C-n>', function()
      if pumvisible() then
        feedkeys('<C-n>')
      else
        if next(vim.lsp.get_clients({ bufnr = 0 })) then
          vim.lsp.completion.get()
        else
          if vim.bo.omnifunc == '' then
            feedkeys('<C-x><C-n>')
          else
            feedkeys('<C-x><C-o>')
          end
        end
      end
    end, { desc = 'Trigger/select next completion' })

    -- Buffer completions.
    map(
      'i',
      '<C-u>',
      '<C-x><C-n>',
      { desc = 'Buffer completions', buffer = bufnr }
    )

    -- Use <Tab> to accept a Copilot suggestion, navigate between snippet tabstops,
    -- or select the next completion.
    -- Do something similar with <S-Tab>.
    map({ 'i', 's' }, '<Tab>', function()
      local copilot = require('copilot.suggestion')

      if copilot.is_visible() then
        copilot.accept()
      elseif pumvisible() then
        feedkeys('<C-n>')
      elseif vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
      else
        feedkeys('<Tab>')
      end
    end, { buffer = bufnr })

    map({ 'i', 's' }, '<S-Tab>', function()
      if pumvisible() then
        feedkeys('<C-p>')
      elseif vim.snippet.active({ direction = -1 }) then
        vim.snippet.jump(-1)
      else
        feedkeys('<S-Tab>')
      end
    end, { buffer = bufnr })

    -- Inside a snippet, use backspace to remove the placeholder.
    map('s', '<BS>', '<C-o>s', { buffer = bufnr })
  end
end
