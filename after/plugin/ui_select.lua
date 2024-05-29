local enabled = rvim.plugin.ui_select.enable

if not rvim or rvim.none or not rvim.plugins.enable or not enabled then
  return
end

local fn = vim.fn
local frecency = require('ar.frecency')

local M = {
  options = {},
  prompts = {
    toggles = 'Toggle actions',
    custom = 'Custom actions',
    files = 'File actions',
    git = 'Git commands',
    lsp = 'Code/LSP actions',
    gpt = 'ChatGPTRun actions',
    command_palette = 'Command Palette actions',
  },
}

--------------------------------------------------------------------------------
-- Toggles
--------------------------------------------------------------------------------
M.options.toggles = {
  ['Toggle Wrap'] = 'lua require"ar.menus.toggle".toggle_opt("wrap")',
  ['Toggle Cursorline'] = 'lua require"ar.menus.toggle".toggle_opt("cursorline")',
  ['Toggle Spell'] = 'lua require"ar.menus.toggle".toggle_opt("spell")',
  ['Toggle Conceal Level'] = 'lua require"ar.menus.toggle".toggle_conceal_level()',
  ['Toggle Conceal Cursor'] = 'lua require"ar.menus.toggle".toggle_conceal_cursor()',
  ['Toggle Statusline'] = 'lua require"ar.menus.toggle".toggle_statusline()',
  ['Toggle Sunglasses'] = 'lua require"rm.toggle".toggle_sunglasses()',
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
}

local toggle_menu = function()
  rvim.create_select_menu(M.prompts['toggles'], M.options.toggles)()
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
M.options.custom = {
  ['Open Local Postgres DB'] = 'lua require("ar.menus.database").pick_local_pg_db()',
  ['Open Saved Query'] = 'lua require("ar.menus.database").open_saved_query()',
  ['Open Json'] = 'lua require("ar.menus.database").open_json()',
}

local custom_menu = function()
  rvim.create_select_menu(M.prompts['custom'], M.options.custom)() --> extra paren to execute!
end

map(
  'n',
  '<leader>oc',
  custom_menu,
  { desc = '[c]ustom [a]ctions: open menu for custom actions' }
)

if not rvim.plugins.enable then return end

--------------------------------------------------------------------------------
-- Files
--------------------------------------------------------------------------------
M.options.file = {
  ['Open File From Current Dir'] = "lua require'ar.menus.file'.open_file_cur_dir(false)",
  ['Open File From Current Dir And Children'] = "lua require'ar.menus.file'.open_file_cur_dir(true)",
  ['Change Filetype'] = "lua require'ar.menus.file'.quick_set_ft()",
  ['Search Code Deps'] = "lua require'ar.menus.file'.search_code_deps()",
  ['Toggle File Diff'] = "lua require'ar.menus.file'.toggle_file_diff()",
  ['Reload All Files From Disk'] = 'lua rvim.reload_all()',
  ['Copy File Path'] = "lua require'ar.menus.file'.copy_file_path()",
  ['Copy Full File Path'] = 'let @+ = expand("%:p")',
  ['Yank Last Ex Command'] = 'let @+=@:',
  ['Yank Last Message'] = [[let @+=substitute(execute('messages'), '\n\+', '\n', 'g')]],
  ['Toggle Interceptor'] = 'InterceptToggle',
  ['Re-open File With Sudo Permissions'] = 'SudaRead',
  ['Write File With Sudo Permissions'] = 'SudaWrite',
}

local file_menu = function()
  rvim.create_select_menu(M.prompts['file'], M.options.file)()
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
if rvim.is_git_repo() then
  M.options.git = {
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
  }

  local git_menu = function()
    rvim.create_select_menu(M.prompts['git'], M.options.git)()
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
if rvim.lsp.enable then
  M.options.lsp = {
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
    ['Add Missing Imports'] = function()
      if rvim.is_available('typescript-tools.nvim') then
        vim.cmd('TSToolsAddMissingImports')
        return
      end
      vim.notify(
        'typescript-tools.nvim is not available',
        'error',
        { title = 'Error' }
      )
    end,
    ['Remove Unused Imports'] = function()
      if rvim.is_available('typescript-tools.nvim') then
        vim.cmd('TSToolsRemoveUnusedImports')
      else
        vim.cmd('RemoveUnusedImports')
      end
    end,
    ['Toggle Tailwind Conceal'] = 'TailwindConcealEnable',
    ['Toggle Tailwind Colors'] = 'TailwindColorToggle',
    ['Sort Tailwind Classes'] = 'TailwindSort',
    ['TSC'] = 'TSC',
  }

  local lsp_menu = function()
    if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
      vim.notify_once('there is no lsp server attached to the current buffer')
    else
      rvim.create_select_menu(M.prompts['lsp'], M.options.lsp)() --> extra paren to execute!
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
-- ChatGPTRun
--------------------------------------------------------------------------------
if rvim.is_available('ChatGPT.nvim') then
  M.options.gpt = {
    ['Add Tests'] = 'ChatGPTRun add_tests',
    ['Complete Code'] = 'ChatGPTRun complete_code',
    ['Docstring'] = 'ChatGPTRun docstring',
    ['Explain Code'] = 'ChatGPTRun explain_code',
    ['Fix Bugs'] = 'ChatGPTRun fix_bugs',
    ['Grammar Correct'] = 'chatGPTRun grammar_correction',
    ['Keywords'] = 'ChatGPTRun keywords',
    ['Optmize Code'] = 'ChatGPTRun optimize_code',
    ['Readability Analysis'] = 'ChatGPTRun code_readability_analysis',
    ['Roxygen Edit'] = 'ChatGPTRun roxygen_edit',
    ['Summarize'] = 'ChatGPTRun summarize',
    ['Translate'] = 'ChatGPTRun translate',
  }

  local gpt_menu = function()
    rvim.create_select_menu(M.prompts['gpt'], M.options.gpt)() --> extra paren to execute!
  end

  map(
    { 'n', 'x' },
    '<leader>ar',
    gpt_menu,
    { desc = '[c]hatGPTRun [a]ctions: open menu for chatGPTRun actions' }
  )
end

--------------------------------------------------------------------------------
-- Command Palette
--------------------------------------------------------------------------------
local setreg = fn.setreg
local expand = fn.expand
M.options.command_palette = {
  ['Format Code'] = "lua require'ar.menus.lsp'.format_buf()",
  ['Toggle Profile'] = 'lua require"ar.menus.command_palette".toggle_profile()',
  ['Generate Plugins'] = 'lua require"ar.menus.command_palette".generate_plugins()',
  ['Open Buffer in Float'] = 'lua require"ar.menus.command_palette".open_in_centered_popup()',
  ['Close Invalid Buffers'] = 'lua require"ar.menus.command_palette".close_nonvisible_buffers()',
  ['Command History'] = 'Telescope command_history',
  ['Commands'] = 'Telescope commands',
  ['Find Files'] = 'Telescope find_files',
  ['Git Branches'] = 'Telescope git_branches',
  ['Git Commits'] = 'Telescope git_commits',
  ['Git Status'] = 'Telescope git_status',
  ['Keymaps'] = 'Telescope keymaps',
  ['Live Grep'] = 'Telescope live_grep',
  ['Maximize Window'] = 'lua require("windows.commands").maximize()',
  ['Recently Closed Buffers'] = 'Telescope oldfiles cwd_only=true',
  ['Seach History'] = 'Telescope search_history',
  ['Telescope Buffers'] = 'Telescope buffers',
  ['Telescope Marks'] = 'Telescope marks',
  ['Telescope Projects'] = 'Telescope projects',
  ['Telescope Resume'] = 'Telescope resume',
  ['Telescope Undo'] = 'Telescope undo',
  ['Trouble Diagnostics'] = 'TroubleToggle',
  ['Nerdy'] = 'Nerdy',
  ['Restart Editor'] = 'cq',
  ['Toggle Context Visualizer'] = 'NvimContextVtToggle',
  ['Share Code URL'] = 'NullPointer',
  ['Time Spent In Neovim'] = 'Fleeting',
  ['Days Without Configuring Neovim'] = 'OhneAccidents',
  ['Time Since Neovim Config'] = 'lua require"configpulse".find_time()',
  ['Generate Gitignore'] = 'Gitignore',
  ['Generate License'] = 'Licenses',
  ['Copy File Name'] = function() setreg('+', fn.expand('%:t')) end,
  ['Copy File Absolute Path'] = function() setreg('+', fn.expand('%:p')) end,
  ['Copy File Absolute Path (No File Name)'] = function()
    setreg('+', expand('%:p:h'))
  end,
  ['Copy File Home Path'] = function() setreg('+', expand('%:~')) end,
  ['Find And Replace'] = 'GrugFar',
  ['RenderMarkdown Toggle'] = 'RenderMarkdownToggle',
  ['Code Pad'] = 'QuickCodePad',
  ['Run Code'] = 'Build',
  ['Toggle Auto Pairs'] = function()
    if not rvim.is_available('mini.pairs') then
      vim.notify('mini.pairs is not available', 'error', { title = 'Error' })
      return
    end
    vim.g.minipairs_disable = not vim.g.minipairs_disable
    if vim.g.minipairs_disable then
      vim.notify('Disabled auto pairs')
    else
      vim.notify('Enabled auto pairs')
    end
  end,
}

local command_palette_menu = function()
  rvim.create_select_menu(
    M.prompts['command_palette'],
    M.options.command_palette
  )()
end

map(
  'n',
  '<leader>op',
  command_palette_menu,
  { desc = '[c]ommand [p]alette: open menu for command palette actions' }
)

for name, option in pairs(M.options) do
  for key, _ in pairs(option) do
    frecency.update_item(key, { prompt = M.prompts[name] })
  end
end
