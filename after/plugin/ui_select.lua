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
  ['Toggle Sunglasses'] = 'lua require"ar.menus.toggle".toggle_sunglasses()',
  ['Toggle Aerial'] = 'AerialToggle',
  ['Toggle Ccc'] = 'CccHighlighterToggle',
  ['Toggle Colors'] = 'HighlightColors Toggle',
  ['Toggle Pick'] = 'CccPick',
  ['Toggle Cloak'] = 'CloakToggle',
  ['Toggle SpOnGeBoB'] = 'SpOnGeBoBiFy',
  ['Toggle Lengthmatters'] = 'LengthmattersToggle',
  ['Toggle Twilight'] = 'Twilight',
  ['Toggle ZenMode'] = 'ZenMode',
  ['Toggle Zoom'] = 'lua require("mini.misc").zoom()',
  ['Toggle Relative Number'] = 'ToggleRelativeNumber',
  ['Toggle Undo Tree'] = 'UndotreeToggle',
  ['Toggle Precognition'] = 'Precognition toggle',
  ['Toggle TS Context'] = 'TSContextToggle',
  ['Toggle Helpview'] = 'Helpview toggleAll',
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
-- Custom
--------------------------------------------------------------------------------
ar.add_to_menu('custom', {
  ['Open Local Postgres DB'] = 'lua require("ar.menus.database").pick_local_pg_db()',
  ['Open Saved Query'] = 'lua require("ar.menus.database").open_saved_query()',
  ['Open Json'] = 'lua require("ar.menus.database").open_json()',
})

local custom_menu = function()
  ar.create_select_menu(ar.menu['custom'].title, ar.menu['custom'].options)() --> extra paren to execute!
end

map(
  'n',
  '<leader>oc',
  custom_menu,
  { desc = '[c]ustom [a]ctions: open menu for custom actions' }
)

if not ar.plugins.enable then return end

--------------------------------------------------------------------------------
-- Files
--------------------------------------------------------------------------------
ar.add_to_menu('file', {
  ['Open File From Current Dir'] = "lua require'ar.menus.file'.open_file_cur_dir(false)",
  ['Open File From Current Dir And Children'] = "lua require'ar.menus.file'.open_file_cur_dir(true)",
  ['Change Filetype'] = "lua require'ar.menus.file'.quick_set_ft()",
  ['Search Code Deps'] = "lua require'ar.menus.file'.search_code_deps()",
  ['Toggle File Diff'] = "lua require'ar.menus.file'.toggle_file_diff()",
  ['Reload All Files From Disk'] = 'lua ar.reload_all()',
  ['Copy File Path'] = "lua require'ar.menus.file'.copy_file_path()",
  ['Copy Full File Path'] = 'let @+ = expand("%:p")',
  ['Yank Last Ex Command'] = 'let @+=@:',
  ['Yank Last Message'] = [[let @+=substitute(execute('messages'), '\n\+', '\n', 'g')]],
  ['Toggle Interceptor'] = 'InterceptToggle',
  ['Re-open File With Sudo Permissions'] = 'SudaRead',
  ['Write File With Sudo Permissions'] = 'SudaWrite',
})

local file_menu = function()
  ar.create_select_menu(ar.menu['file'].title, ar.menu['file'].options)()
end

map(
  'n',
  '<leader>of',
  file_menu,
  { desc = '[f]ile [a]ctions: open menu for file actions' }
)
-- TODO: Figure out what to do with these
map(
  'n',
  '<leader>Ff',
  ":lua require'ar.menus.file'.open_file_cur_dir(true)<CR>",
  { desc = 'find files' }
)
map(
  'n',
  '<leader>Fs',
  ":lua require'ar.menus.file'.live_grep_in_cur_dir(true)<CR>",
  { desc = 'live grep' }
)
map(
  'n',
  '<leader>Fw',
  ":lua require'ar.menus.file'.find_word_in_cur_dir(true)<CR>",
  { desc = 'find word' }
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
  ar.add_to_menu('ai', {
    ['Clear Buffer and Chat History'] = 'CopilotChatReset',
    ['Toggle Copilot Chat Vsplit'] = 'CopilotChatToggle',
    ['Help Actions'] = "lua require'ar.menus.ai'.help_actions()",
    ['Prompt Actions'] = "lua require'ar.menus.ai'.prompt_actions()",
    ['Save Chat'] = "lua require'ar.menus.ai'.save_chat()",
    ['Explain Code'] = 'CopilotChatExplain',
    ['Generate Tests'] = 'CopilotChatTests',
    ['Review Code'] = 'CopilotChatReview',
    ['Refactor Code'] = 'CopilotChatRefactor',
    ['Better Naming'] = 'CopilotChatBetterNamings',
    ['Quick Chat'] = "lua require'ar.menus.ai'.quick_chat()",
    ['Ask Input'] = "lua require'ar.menus.ai'.ask_input()",
    ['Generate Commit Message'] = 'CopilotChatCommit',
    ['Generate Commit Message For Staged Changes'] = 'CopilotChatCommitStaged',
    ['Debug Info'] = 'CopilotChatDebugInfo',
    ['Fix Diagnostic'] = 'CopilotChatFixDiagnostic',
  })

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
  local function w3m_input(cmd)
    vim.ui.input({ prompt = 'Enter url:', kind = 'center_win' }, function(input)
      if input ~= nil then vim.cmd(cmd .. ' ' .. input) end
    end)
  end

  ar.add_to_menu('ai', {
    ['Search in vsplit'] = function() w3m_input('W3mVSplit') end,
    ['Search in split'] = function() w3m_input('W3mVSplit') end,
    ['DuckDuckGo Search'] = function() w3m_input('W3m duck') end,
    ['Google Search'] = function() w3m_input('W3m google') end,
    ['Copy URL'] = 'W3mCopyUrl',
    ['Reload Page'] = 'W3mReload',
    ['Change URL'] = 'W3mAddressBar',
    ['Search History'] = 'W3mHistory',
    ['Open In External Browser'] = 'W3mShowExtenalBrowser',
    ['Clear Search History'] = 'W3mHistoryClear',
  })

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
  ['Clear Messages'] = function() vim.cmd('messages clear') end,
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
