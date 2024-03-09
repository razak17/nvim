local enabled = rvim.plugin.ui_select.enable

if not rvim or rvim.none or not rvim.plugins.enable or not enabled then
  return
end

--------------------------------------------------------------------------------
-- Toggles
--------------------------------------------------------------------------------
local toggle_options = {
  ['Toggle Wrap'] = 'lua require"rm.menus.toggle_select".toggle_opt("wrap")',
  ['Toggle Cursorline'] = 'lua require"rm.menus.toggle_select".toggle_opt("cursorline")',
  ['Toggle Spell'] = 'lua require"rm.menus.toggle_select".toggle_opt("spell")',
  ['Toggle Conceal Level'] = 'lua require"rm.menus.toggle_select".toggle_conceal_level()',
  ['Toggle Conceal Cursor'] = 'lua require"rm.menus.toggle_select".toggle_conceal_cursor()',
  ['Toggle Statusline'] = 'lua require"rm.menus.toggle_select".toggle_statusline()',
  ['Toggle Aerial'] = 'AerialToggle',
  ['Toggle Ccc'] = 'CccHighlighterToggle',
  ['Toggle Pick'] = 'CccPick',
  ['Toggle Cloak'] = 'CloakToggle',
  ['Toggle SpOnGeBoB'] = 'SpOnGeBoBiFy',
  ['Toggle Lengthmatters'] = 'LengthmattersToggle',
  ['Toggle Twilight'] = 'Twilight',
  ['Toggle ZenMode'] = 'ZenMode',
  ['Toggle Sunglasses'] = 'lua require"rm.toggle_select".toggle_sunglasses()',
  ['Toggle Zoom'] = 'lua require("mini.misc").zoom()',
  ['Toggle Relative Number'] = 'ToggleRelativeNumber',
  ['Toggle Undo Tree'] = 'UndotreeToggle',
}

local toggle_menu = function()
  rvim.create_select_menu('Toggle actions', toggle_options)() --> extra paren to execute!
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
local custom_options = {
  ['Open Local Postgres DB'] = 'lua require("rm.menus.database").pick_local_pg_db()',
  ['Open Saved Query'] = 'lua require("rm.menus.database").open_saved_query()',
  ['Open Json'] = 'lua require("rm.menus.database").open_json()',
}

local custom_menu = function()
  rvim.create_select_menu('Custom actions', custom_options)() --> extra paren to execute!
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
local file_options = {
  ['Open File From Current Dir'] = "lua require'rm.menus.file_select'.open_file_cur_dir(false)",
  ['Open File From Current Dir And Children'] = "lua require'rm.file_select'.open_file_cur_dir(true)",
  ['Reload All Files From Disk'] = 'lua rvim.reload_all()',
  ['Copy File Path'] = "lua require'rm.menus.file_select'.copy_file_path()",
  ['Copy Full File Path'] = 'let @+ = expand("%:p")',
  ['Yank Last Ex Command'] = 'let @+=@:',
  ['Yank Last Message'] = [[let @+=substitute(execute('messages'), '\n\+', '\n', 'g')]],
  ['Change Filetype'] = "lua require'rm.menus.file_select'.quick_set_ft()",
  ['Search Code Deps'] = "lua require'rm.menus.file_select'.search_code_deps()",
  ['Toggle File Diff'] = "lua require'rm.menus.file_select'.toggle_file_diff()",
  ['Toggle Interceptor'] = 'InterceptToggle',
  ['Re-open File With Sudo Permissions'] = 'SudaRead',
  ['Write File With Sudo Permissions'] = 'SudaWrite',
}

local file_menu = function()
  rvim.create_select_menu('File actions', file_options)()
end

map(
  'n',
  '<leader>of',
  file_menu,
  { desc = '[f]ile [a]ctions: open menu for file actions' }
)
map(
  'n',
  '<leader>Ff',
  ":lua require'rm.menus.file_select'.open_file_cur_dir(true)<CR>",
  { desc = 'find files' }
)
map(
  'n',
  '<leader>Fs',
  ":lua require'rm.menus.file_select'.live_grep_in_cur_dir(true)<CR>",
  { desc = 'live grep' }
)
map(
  'n',
  '<leader>Fw',
  ":lua require'rm.menus.file_select'.find_word_in_cur_dir(true)<CR>",
  { desc = 'find word' }
)

--------------------------------------------------------------------------------
-- Git
--------------------------------------------------------------------------------
if rvim.is_git_repo() then
  local git_options = {
    ['Browse Branches'] = "lua require'rm.menus.git_select'.browse_branches()",
    ['Stash Changes'] = "lua require'rm.menus.git_select'.do_stash()",
    ['Browse Stashes'] = "lua require'rm.menus.git_select'.list_stashes()",
    ['Browse Commits'] = "lua require'rm.menus.git_select'.browse_commits()",
    ['Show Buffer Commits'] = "lua require'rm.menus.git_select'.browse_bcommits()",
    ['Show Commit At Line'] = "lua require'rm.menus.git_select'.show_commit_at_line()",
    ['Show Commit From Hash'] = "lua require'rm.menus.git_select'.display_commit_from_hash()",
    ['Open File From Branch'] = "lua require'rm.menus.git_select'.open_file_git_branch()",
    ['Search In Another Branch'] = "lua require'rm.menus.git_select'.search_git_branch()",
    ['List Authors'] = 'CoAuthor',
    ['Time Machine'] = "lua require'rm.menus.git_select'.time_machine()",
    ['Browse Project History'] = "lua require'rm.menus.git_select'.project_history()",
    ['Browse File Commit History'] = 'DiffviewFileHistory %',
    ['Pull Latest Changes'] = "lua require'rm.menus.git_select'.git_pull()",
    ['Fetch Orign'] = "lua require'rm.menus.git_select'.fetch_origin()",
    ['Conflict Show Base'] = "lua require'rm.menus.git_select'.diffview_conflict('base')",
    ['Conflict Show Ours'] = "lua require'rm.menus.git_select'.diffview_conflict('ours')",
    ['Conflict Show Theirs'] = "lua require'rm.menus.git_select'.diffview_conflict('theirs')",
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
  }

  local git_menu = function()
    rvim.create_select_menu('Git Commands', git_options)()
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
  local lsp_options = {
    ['Format Code'] = "lua require'rm.menus.lsp_select'.format_buf()",
    ['Eslint Fix'] = "lua require'rm.menus.lsp_select'.eslint_fix()",
    ['LSP references'] = "lua require'rm.menus.lsp_select'.display_lsp_references()",
    ['Call Heirarchy'] = "lua require'rm.menus.lsp_select'.display_call_hierarchy()",
    ['Restart All LSPs'] = "lua require'rm.menus.lsp_select'.lsp_restart_all()",
    ['Toggle Linting Globally'] = "lua require'rm.menus.lsp_select'.toggle_linting()",
    ['Toggle Virtual Text'] = "lua require'rm.menus.lsp_select'.toggle_virtual_text()",
    ['Toggle Virtual Lines'] = "lua require'rm.menus.lsp_select'.toggle_virtual_lines()",
    ['Toggle Diagnostic Signs'] = "lua require'rm.menus.lsp_select'.toggle_signs()",
    ['Toggle Diagnostics'] = "lua require'rm.menus.lsp_select'.toggle_diagnostics()",
    ['Toggle Hover Diagnostics'] = "lua require'rm.menus.lsp_select'.toggle_hover_diagnostics()",
    ['Toggle Hover Diagnostics (go_to)'] = "lua require'rm.menus.lsp_select'.toggle_hover_diagnostics_go_to()",
    ['Toggle Format On Save'] = "lua require'rm.menus.lsp_select'.toggle_format_on_save()",
    ['Preview Code Actions'] = 'lua require("actions-preview").code_actions()',
  }

  local lsp_menu = function()
    if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
      vim.notify_once('there is no lsp server attached to the current buffer')
    else
      rvim.create_select_menu('Code/LSP actions', lsp_options)() --> extra paren to execute!
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
  local gpt_options = {
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
    rvim.create_select_menu('ChatGPTRun actions', gpt_options)() --> extra paren to execute!
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
local command_palette_options = {
  ['Command History'] = 'Telescope command_history',
  ['Commands'] = 'Telescope commands',
  ['Find Files'] = 'Telescope find_files',
  ['Git Branches'] = 'Telescope branches',
  ['Git Commits'] = 'Telescope git_commits',
  ['Git Status'] = 'Telescope status',
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
}

local command_palette_menu = function()
  rvim.create_select_menu('Command Palette actions', command_palette_options)()
end

map(
  'n',
  '<leader>op',
  command_palette_menu,
  { desc = '[c]ommand [p]alette: open menu for command palette actions' }
)
