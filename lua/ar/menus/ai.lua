local M = {
  CopilotChat = {},
}

function M.CopilotChat.help_actions()
  local actions = require('CopilotChat.actions')
  local integrations = require('CopilotChat.integrations.telescope')
  integrations.pick(actions.help_actions())
end

function M.CopilotChat.prompt_actions()
  local actions = require('CopilotChat.actions')
  local integrations = require('CopilotChat.integrations.telescope')
  integrations.pick(actions.prompt_actions())
end

function M.CopilotChat.save_chat()
  local date = os.date('%Y-%m-%d_%H-%M-%S')
  vim.cmd('CopilotChatSave ' .. date)
end

function M.CopilotChat.quick_chat()
  local input = vim.fn.input('Quick Chat: ')
  if input ~= '' then vim.cmd('CopilotChatBuffer ' .. input) end
end

function M.CopilotChat.ask_input()
  local input = vim.fn.input('Ask Copilot: ')
  if input ~= '' then vim.cmd('CopilotChat ' .. input) end
end

return M
