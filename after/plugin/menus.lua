local enabled = ar.ui_select.enable

if not ar or ar.none or not ar.plugins.enable or not enabled then return end

--------------------------------------------------------------------------------
-- Toggles
--------------------------------------------------------------------------------
ar.add_to_menu('toggle', {
  ['Toggle Wrap'] = 'lua require"ar.menus.toggle".toggle_opt("wrap")',
  ['Toggle Cursorline'] = 'lua require"ar.menus.toggle".toggle_opt("cursorline")',
  ['Toggle Spell'] = 'lua require"ar.menus.toggle".toggle_opt("spell")',
  ['Toggle Conceal Level'] = 'lua require"ar.menus.toggle".toggle_conceal_level()',
  ['Toggle Conceal Cursor'] = 'lua require"ar.menus.toggle".toggle_conceal_cursor()',
  ['Toggle Statusline'] = 'lua require"ar.menus.toggle".toggle_statusline()',
})

local toggle_menu = function()
  ar.create_select_menu(ar.menu['toggle'].title, ar.menu['toggle'].options)()
end

map(
  'n',
  '<leader>oo',
  toggle_menu,
  { desc = '[t]oggle [a]ctions: open menu for toggle actions' }
)

--------------------------------------------------------------------------------
-- Git
--------------------------------------------------------------------------------
if ar.is_git_repo() or ar.is_git_env() then
  ar.add_to_menu('git', {
    ['Browse Branches'] = "lua require'ar.menus.git'.browse_branches()",
    ['Stash Changes'] = "lua require'ar.menus.git'.do_stash()",
    ['Browse Stashes'] = "lua require'ar.menus.git'.list_stashes()",
    ['Browse Commits'] = "lua require'ar.menus.git'.browse_commits()",
    ['Show Buffer Commits'] = "lua require'ar.menus.git'.browse_bcommits()",
    ['Show Commit At Line'] = "lua require'ar.menus.git'.show_commit_at_line()",
    ['Show Commit From Hash'] = "lua require'ar.menus.git'.display_commit_from_hash()",
    ['Open File From Branch'] = "lua require'ar.menus.git'.open_file_from_branch()",
    ['Search In Another Branch'] = "lua require'ar.menus.git'.search_in_another_branch()",
    ['Time Machine'] = "lua require'ar.menus.git'.time_machine()",
    ['Browse Project History'] = "lua require'ar.menus.git'.project_history()",
    ['Pull Latest Changes'] = "lua require'ar.menus.git'.git_pull()",
    ['Fetch Orign'] = "lua require'ar.menus.git'.fetch_origin()",
    ['Conflict Show Base'] = "lua require'ar.menus.git'.diffview_conflict('base')",
    ['Conflict Show Ours'] = "lua require'ar.menus.git'.diffview_conflict('ours')",
    ['Conflict Show Theirs'] = "lua require'ar.menus.git'.diffview_conflict('theirs')",
    ['List Branches'] = "lua require'ar.menus.git'.list_branches()",
    ['Browse File Commit History'] = 'DiffviewFileHistory %',
    ['List Authors'] = 'CoAuthor',
    ['Conflict Choose Ours'] = 'GitConflictChooseOurs',
    ['Conflict Choose Theirs'] = 'GitConflictChooseTheirs',
    ['Conflict Choose None'] = 'GitConflictChooseNone',
    ['Conflict Choose Both'] = 'GitConflictChooseBoth',
    ['Toggle Current Line Blame'] = 'Gitsigns toggle_current_line_blame',
    ['Reset Buffer'] = 'Gitsigns reset_buffer',
    ['Open File In GitHub'] = 'OpenInGHFile',
    ['Open Line In GitHub'] = 'OpenInGHFileLines',
    ['Open Repo In GitHub'] = 'OpenInGHRepo',
    ['View Branch Graph'] = 'Flog',
    ['Git Search'] = 'AdvancedGitSearch',
    ['Toggle Blame'] = 'BlameToggle',
  })

  local git_menu = function()
    ar.create_select_menu(ar.menu['git'].title, ar.menu['git'].options)()
  end

  map(
    'n',
    '<leader>og',
    git_menu,
    { desc = '[g]it [a]ctions: open menu for git commands' }
  )
end

--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------
if ar.lsp.enable then
  ar.add_to_menu('lsp', {
    ['Format Code'] = "lua require'ar.menus.lsp'.format_buf()",
    ['Eslint Fix'] = "lua require'ar.menus.lsp'.eslint_fix()",
    ['LSP references'] = "lua require'ar.menus.lsp'.display_lsp_references()",
    ['Call Heirarchy'] = "lua require'ar.menus.lsp'.display_call_hierarchy()",
    ['Restart All LSPs'] = "lua require'ar.menus.lsp'.lsp_restart_all()",
    ['Toggle Linting Globally'] = "lua require'ar.menus.lsp'.toggle_linting()",
    ['Toggle Virtual Text'] = "lua require'ar.menus.lsp'.toggle_virtual_text()",
    ['Toggle Virtual Lines'] = "lua require'ar.menus.lsp'.toggle_virtual_lines()",
    ['Toggle Diagnostic Signs'] = "lua require'ar.menus.lsp'.toggle_signs()",
    ['Toggle Diagnostics'] = "lua require'ar.menus.lsp'.toggle_diagnostics()",
    ['Toggle Hover Diagnostics'] = "lua require'ar.menus.lsp'.toggle_hover_diagnostics()",
    ['Toggle Hover Diagnostics (go_to)'] = "lua require'ar.menus.lsp'.toggle_hover_diagnostics_go_to()",
    ['Toggle Format On Save'] = "lua require'ar.menus.lsp'.toggle_format_on_save()",
    ['Goto Workspace Symbol'] = "lua require'ar.menus.lsp'.filter_lsp_workspace_symbols()",
    ['Goto Workspace Symbol Under Cursor'] = "lua require'ar.menus.lsp'.ws_symbol_under_cursor()",
    ['Preview Code Actions'] = 'lua require("actions-preview").code_actions()',
    ['Organize Imports'] = "lua require'ar.menus.lsp'.organize_imports()",
    ['Add Missing Imports'] = "lua require'ar.menus.lsp'.add_missing_imports()",
    ['Remove Unused Imports'] = "lua require'ar.menus.lsp'.remove_unused_imports()",
    ['Remove Unused'] = "lua require'ar.menus.lsp'.remove_unused()",
    ['Fix All'] = "lua require'ar.menus.lsp'.fix_all()",
    ['Toggle Tailwind Conceal'] = 'TailwindConcealEnable',
    ['Toggle Tailwind Colors'] = 'TailwindColorToggle',
    ['Sort Tailwind Classes'] = 'TailwindSort',
    ['TSC'] = 'TSC',
  })

  local lsp_menu = function()
    if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
      vim.notify_once('there is no lsp server attached to the current buffer')
    else
      ar.create_select_menu(ar.menu['lsp'].title, ar.menu['lsp'].options)() --> extra paren to execute!
    end
  end

  map(
    'n',
    '<leader>ol',
    lsp_menu,
    { desc = '[l]sp [a]ctions: open menu for lsp features' }
  )
end

--------------------------------------------------------------------------------
-- A.I.
--------------------------------------------------------------------------------
if ar.ai.enable then
  local function execute_if_available(plugin, command, visual)
    if not ar.plugin_available(plugin) then return end
    if visual then
      ar.visual_cmd(command)
    else
      vim.cmd(command)
    end
  end

  ar.add_to_menu('ai', {
    ['Toggle Copilot Auto Trigger'] = function()
      execute_if_available(
        'copilot.lua',
        'lua require("copilot.suggestion").toggle_auto_trigger()'
      )
    end,
    ['Toggle Copilot Chat'] = function()
      execute_if_available('CopilotChat.nvim', 'CopilotChatToggle')
    end,
    ['Clear Copilot Chat'] = function()
      execute_if_available('CopilotChat.nvim', 'CopilotChatReset')
    end,
    ['Copilot Chat Inline'] = function()
      execute_if_available('CopilotChat.nvim', 'CopilotChatInline', true)
    end,
    ['Toggle Avante Chat'] = function()
      execute_if_available('avante.nvim', 'AvanteToggle')
    end,
    ['Clear Avante Chat'] = function()
      execute_if_available('avante.nvim', 'AvanteClear')
    end,
    ['Toggle Codecompanion Chat'] = function()
      execute_if_available('codecompanion.nvim', 'CodeCompanionToggle')
    end,
    ['Codecompanion Actions'] = function()
      execute_if_available('codecompanion.nvim', 'CodeCompanionActions')
    end,
    ['Codecompanion Add Selection'] = function()
      execute_if_available('codecompanion.nvim', 'CodeCompanionAdd', true)
    end,
    ['Toggle Gp Chat'] = function()
      execute_if_available('gp.nvim', 'GpChatToggle vsplit')
    end,
    ['Clear Gp Chat'] = function()
      execute_if_available('gp.nvim', 'GpChatToggle vsplit')
    end,
    ['New Gp Chat'] = function() execute_if_available('gp.nvim', 'GpChatNew') end,
    ['New Gp Buffer Chat'] = function()
      execute_if_available('gp.nvim', 'GpBufferChatNew')
    end,
    ['Gp Act As'] = function() execute_if_available('gp.nvim', 'GpActAs') end,
    ['ChatGPT Prompt'] = function()
      execute_if_available('ChatGPT.nvim', 'ChatGPT')
    end,
    ['ChatGPT Fix Bugs'] = function()
      execute_if_available('ChatGPT.nvim', 'ChatGPTRun fix_bugs')
    end,
    ['ChatGPT Explain Code'] = function()
      execute_if_available('ChatGPT.nvim', 'ChatGPTRun explain_code')
    end,
    ['ChatGPT Optimize Code'] = function()
      execute_if_available('ChatGPT.nvim', 'ChatGPTRun optimize_code')
    end,
  })

  local ai_menu = function()
    ar.create_select_menu(ar.menu['ai'].title, ar.menu['ai'].options)()
  end

  map(
    { 'n', 'v' },
    '<leader>oa',
    ai_menu,
    { desc = '[A.I]. [a]ctions: open menu for A.I. actions' }
  )
end

--------------------------------------------------------------------------------
-- CopilotChat
--------------------------------------------------------------------------------
if ar.is_available('CopilotChat.nvim') then
  local copilot_chat_menu = function()
    ar.create_select_menu(
      ar.menu['copilot_chat'].title,
      ar.menu['copilot_chat'].options
    )()
  end

  map(
    'n',
    '<leader>acc',
    copilot_chat_menu,
    { desc = '[c]opilotChat [a]ctions: open menu for copilotChat actions' }
  )
end

--------------------------------------------------------------------------------
-- w3m
--------------------------------------------------------------------------------
if ar.is_available('w3m.vim') then
  local w3m_menu = function()
    ar.create_select_menu(ar.menu['w3m'].title, ar.menu['w3m'].options)()
  end

  map(
    'n',
    '<leader>ow',
    w3m_menu,
    { desc = '[w]3m [a]ctions: open menu for w3m actions' }
  )
end

--------------------------------------------------------------------------------
-- Command Palette
--------------------------------------------------------------------------------
ar.add_to_menu('command_palette', {
  ['Copy File Path'] = "lua require'ar.menus.command_palette'.copy_file_path()",
  ['Copy File Name'] = "lua require'ar.menus.command_palette'.copy_path('file_name')",
  ['Copy File Absolute Path'] = "lua require'ar.menus.command_palette'.copy_path('absolute_path')",
  ['Copy File Absolute Path (No File Name)'] = "lua require'ar.menus.command_palette'.copy_path('absolute_path_no_file_name')",
  ['Copy File Home Path'] = "lua require'ar.menus.command_palette'.copy_path('home_path')",
  ['Format Code'] = "lua require'ar.menus.command_palette'.format_buf()",
  ['Generate Plugins'] = 'lua require"ar.menus.command_palette".generate_plugins()',
  ['Open Buffer in Float'] = 'lua require"ar.menus.command_palette".open_file_in_centered_popup()',
  ['Close Invalid Buffers'] = 'lua require"ar.menus.command_palette".close_nonvisible_buffers()',
  ['Toggle Autosave'] = "lua require'ar.menus.command_palette'.toggle_minipairs()",
  ['Toggle Large File'] = "lua require'ar.menus.command_palette'.toggle_large_file()",
  ['Change Filetype'] = "lua require'ar.menus.command_palette'.quick_set_ft()",
  ['Search Code Deps'] = "lua require'ar.menus.command_palette'.search_code_deps()",
  ['Toggle File Diff'] = "lua require'ar.menus.command_palette'.toggle_file_diff()",
  ['Yank Last Message'] = [[let @+=substitute(execute('messages'), '\n\+', '\n', 'g')]],
  ['Clear Messages'] = function() vim.cmd('messages clear') end,
  ['Yank Last Ex Command'] = 'let @+=@:',
  ['Restart Editor'] = 'cq',
})

local command_palette_menu = function()
  ar.create_select_menu(
    ar.menu['command_palette'].title,
    ar.menu['command_palette'].options
  )()
end

map(
  'n',
  '<leader>op',
  command_palette_menu,
  { desc = '[c]ommand [p]alette: open menu for command palette actions' }
)

--------------------------------------------------------------------------------
-- Frecency Setup
--------------------------------------------------------------------------------
local frecency = require('ar.frecency')
for _, option in pairs(ar.menu) do
  for key, _ in pairs(option.options) do
    frecency.update_item(key, { prompt = option.title })
  end
end
