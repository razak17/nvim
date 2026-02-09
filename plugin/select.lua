if not ar then return end

local enabled = ar.config.plugin.main.select.enable

if ar.none or not ar.plugins.enable or not enabled then return end

--------------------------------------------------------------------------------
-- Toggles
--------------------------------------------------------------------------------
ar.add_to_select('toggle', {
  ['Toggle Wrap'] = 'lua require"ar.select.toggle".toggle_opt("wrap")',
  ['Toggle Cursorline'] = 'lua require"ar.select.toggle".toggle_opt("cursorline")',
  ['Toggle Spell'] = 'lua require"ar.select.toggle".toggle_opt("spell")',
  ['Toggle Conceal Level'] = 'lua require"ar.select.toggle".toggle_conceal_level()',
  ['Toggle Conceal Cursor'] = 'lua require"ar.select.toggle".toggle_conceal_cursor()',
  ['Toggle Statusline'] = 'lua require"ar.select.toggle".toggle_statusline()',
  ['Toggle Color Pencils'] = 'lua require"ar.select.toggle".color_my_pencils()',
  ['Toggle Alpha Green'] = 'lua require"ar.select.toggle".alpha_green()',
  ['Toggle Guides'] = 'lua require"ar.select.toggle".toggle_guides()',
})

local toggle_menu = function()
  ar.create_select_menu(ar.select['toggle'].title, ar.select['toggle'].options)()
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
  ar.add_to_select('git', {
    ['Stash Changes'] = "lua require'ar.select.git'.do_stash()",
    ['Stash All Changes'] = "lua require'ar.select.git'.do_stash_all()",
    ['Stash Staged Changes'] = "lua require'ar.select.git'.git_do_stash_staged()",
    ['Push Commits'] = "lua require'ar.select.git'.git_push()",
    ['Pull Latest Changes'] = "lua require'ar.select.git'.git_pull()",
    ['Fetch Orign'] = "lua require'ar.select.git'.fetch_origin()",
    ['Abort Merge'] = "lua require'ar.select.git'.abort_merge()",
    ['Continue Merge'] = "lua require'ar.select.git'.continue_merge()",
    ['Revert Commit'] = "lua require'ar.select.git'.revert_specific_commit()",
    ['Revert Last Commit'] = "lua require'ar.select.git'.revert_last_commit()",
    ['Undo Last Commit'] = "lua require'ar.select.git'.undo_last_commit()",
    ['List Branches'] = "lua require'ar.select.git'.list_branches()",
  })
  if ar.has('telescope.nvim') then
    ar.add_to_select('git', {
      ['Browse Branches'] = "lua require'ar.select.telescope_git'.browse_branches()",
      ['Browse Commits'] = "lua require'ar.select.telescope_git'.browse_commits()",
      ['Browse Buffer Commits'] = "lua require'ar.select.telescope_git'.browse_bcommits()",
      ['Browse Stashes'] = "lua require'ar.select.telescope_git'.list_stashes()",
    })
  end

  local git_menu = function()
    ar.create_select_menu(ar.select['git'].title, ar.select['git'].options)()
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
  ar.add_to_select('lsp', {
    ['Eslint Fix'] = "lua require'ar.select.lsp'.eslint_fix()",
    ['Toggle Virtual Text'] = "lua require'ar.select.lsp'.toggle_virtual_text()",
    ['Toggle Virtual Lines'] = "lua require'ar.select.lsp'.toggle_virtual_lines()",
    ['Toggle Diagnostic Signs'] = "lua require'ar.select.lsp'.toggle_signs()",
    ['Toggle Diagnostics'] = "lua require'ar.select.lsp'.toggle_diagnostics()",
    ['Toggle Inline Completion'] = "lua require'ar.select.lsp'.toggle_inline_completion()",
    ['Toggle Hover Diagnostics'] = "lua require'ar.select.lsp'.toggle_hover_diagnostics()",
    ['Toggle Hover Diagnostics (go_to)'] = "lua require'ar.select.lsp'.toggle_hover_diagnostics_go_to()",
    ['Toggle Linting Globally'] = "lua require'ar.select.lsp'.toggle_linting()",
    ['Toggle Format On Save'] = "lua require'ar.select.lsp'.toggle_format_on_save()",
    ['Organize Imports'] = "lua require'ar.select.lsp'.organize_imports()",
    ['Restart All LSPs'] = "lua require'ar.select.lsp'.lsp_restart_all()",
    ['Add Missing Imports (ts)'] = "lua require'ar.select.lsp'.add_missing_imports()",
    ['Remove Unused Imports (ts)'] = "lua require'ar.select.lsp'.remove_unused_imports()",
    ['Remove Unused (ts)'] = "lua require'ar.select.lsp'.remove_unused()",
    ['Fix All (ts)'] = "lua require'ar.select.lsp'.fix_all()",
  })
  if ar.has('telescope.nvim') then
    ar.add_to_select('lsp', {
      ['LSP references'] = "lua require'ar.select.lsp'.display_lsp_references()",
      ['Call Heirarchy'] = "lua require'ar.select.lsp'.display_call_hierarchy()",
      ['Goto Workspace Symbol'] = "lua require'ar.select.lsp'.filter_lsp_workspace_symbols()",
      ['Goto Workspace Symbol Under Cursor'] = "lua require'ar.select.lsp'.ws_symbol_under_cursor()",
    })
  end
  local is_biome = ar.config.lsp.lang.web.biome
    or vim.tbl_contains(ar.config.lsp.override, 'biome')
  if ar.lsp.enable and is_biome then
    ar.add_to_select('lsp', {
      ['Apply Biome Fixes'] = "lua require'ar.select.lsp'.apply_biome_fixes()",
    })
  end

  local lsp_menu = function()
    if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
      vim.notify_once('there is no lsp server attached to the current buffer')
    else
      ar.create_select_menu(ar.select['lsp'].title, ar.select['lsp'].options)() --> extra paren to execute!
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
  local ai_menu = function()
    ar.create_select_menu(ar.select['ai'].title, ar.select['ai'].options)()
  end

  map(
    { 'n', 'v' },
    '<leader>oa',
    ai_menu,
    { desc = '[A.I]. [a]ctions: open menu for A.I. actions' }
  )
end

--------------------------------------------------------------------------------
-- w3m
--------------------------------------------------------------------------------
if ar.has('w3m.vim') then
  local w3m_menu = function()
    ar.create_select_menu(ar.select['w3m'].title, ar.select['w3m'].options)()
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
ar.add_to_select('command_palette', {
  ['Copy File Path'] = "lua require'ar.select.command_palette'.copy_file_path()",
  ['Copy File Name'] = "lua require'ar.select.command_palette'.copy_path('file_name')",
  ['Copy File Absolute Path'] = "lua require'ar.select.command_palette'.copy_path('absolute_path')",
  ['Copy File Absolute Path (No File Name)'] = "lua require'ar.select.command_palette'.copy_path('absolute_path_no_file_name')",
  ['Copy File Home Path'] = "lua require'ar.select.command_palette'.copy_path('home_path')",
  ['Lint Project (Eslint)'] = "lua require'ar.lint_project'.lint_project()",
  ['Lint Project (Biome)'] = "lua require'ar.lint_project'.lint_project('biome')",
  ['Format Code'] = "lua require'ar.select.command_palette'.format_buf()",
  ['Generate Plugins'] = 'lua require"ar.select.command_palette".generate_plugins()',
  ['Update Schema & Docs'] = 'lua require"ar.update_schema".update()',
  ['Open Buffer in Float'] = 'lua require"ar.select.command_palette".open_file_in_centered_popup()',
  ['Close Invalid Buffers'] = 'lua require"ar.select.command_palette".close_nonvisible_buffers()',
  ['Toggle Autosave'] = "lua require'ar.select.command_palette'.toggle_autosave()",
  ['Toggle Large File'] = "lua require'ar.select.command_palette'.toggle_large_file()",
  ['Change Filetype'] = "lua require'ar.select.command_palette'.quick_set_ft()",
  ['Search Code Deps'] = "lua require'ar.select.command_palette'.search_code_deps()",
  ['Toggle File Diff'] = "lua require'ar.select.command_palette'.toggle_file_diff()",
  ['Yank Last Message'] = [[let @+=substitute(execute('messages'), '\n\+', '\n', 'g')]],
  ['Clear Messages'] = function() vim.cmd('messages clear') end,
  ['Yank Last Ex Command'] = 'let @+=@:',
  ['Restart Editor'] = 'cq',
  ['Lazy UI'] = 'Lazy',
})

map(
  'n',
  '<leader>ob',
  '<Cmd>lua require"ar.select.command_palette".open_file_in_centered_popup()<CR>',
  { desc = 'open buffer in floating window' }
)

local command_palette_menu = function()
  ar.create_select_menu(
    ar.select['command_palette'].title,
    ar.select['command_palette'].options
  )()
end

map(
  { 'n', 'x' },
  '<leader>op',
  command_palette_menu,
  { desc = '[c]ommand [p]alette: open menu for command palette actions' }
)
