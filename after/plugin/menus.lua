local enabled = ar_config.plugin.main.menus.enable

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
    ['Stash Changes'] = "lua require'ar.menus.git'.do_stash()",
    ['Pull Latest Changes'] = "lua require'ar.menus.git'.git_pull()",
    ['Fetch Orign'] = "lua require'ar.menus.git'.fetch_origin()",
    ['Abort Merge'] = "lua require'ar.menus.git'.abort_merge()",
    ['Continue Merge'] = "lua require'ar.menus.git'.continue_merge()",
    ['List Branches'] = "lua require'ar.menus.git'.list_branches()",
  })
  if ar.is_available('telescope.nvim') then
    ar.add_to_menu('git', {
      ['Browse Branches'] = "lua require'ar.menus.git'.browse_branches()",
      ['Browse Commits'] = "lua require'ar.menus.git'.browse_commits()",
      ['Show Buffer Commits'] = "lua require'ar.menus.git'.browse_bcommits()",
      ['Browse Stashes'] = "lua require'ar.menus.git'.list_stashes()",
    })
  end

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
    ['Eslint Fix'] = "lua require'ar.menus.lsp'.eslint_fix()",
    ['Toggle Virtual Text'] = "lua require'ar.menus.lsp'.toggle_virtual_text()",
    ['Toggle Virtual Lines'] = "lua require'ar.menus.lsp'.toggle_virtual_lines()",
    ['Toggle Diagnostic Signs'] = "lua require'ar.menus.lsp'.toggle_signs()",
    ['Toggle Diagnostics'] = "lua require'ar.menus.lsp'.toggle_diagnostics()",
    ['Toggle Hover Diagnostics'] = "lua require'ar.menus.lsp'.toggle_hover_diagnostics()",
    ['Toggle Hover Diagnostics (go_to)'] = "lua require'ar.menus.lsp'.toggle_hover_diagnostics_go_to()",
    ['Toggle Linting Globally'] = "lua require'ar.menus.lsp'.toggle_linting()",
    ['Toggle Format On Save'] = "lua require'ar.menus.lsp'.toggle_format_on_save()",
    ['Organize Imports'] = "lua require'ar.menus.lsp'.organize_imports()",
    ['Restart All LSPs'] = "lua require'ar.menus.lsp'.lsp_restart_all()",
    ['Add Missing Imports (ts)'] = "lua require'ar.menus.lsp'.add_missing_imports()",
    ['Remove Unused Imports (ts)'] = "lua require'ar.menus.lsp'.remove_unused_imports()",
    ['Remove Unused (ts)'] = "lua require'ar.menus.lsp'.remove_unused()",
    ['Fix All (ts)'] = "lua require'ar.menus.lsp'.fix_all()",
  })
  if ar.is_available('telescope.nvim') then
    ar.add_to_menu('lsp', {
      ['LSP references'] = "lua require'ar.menus.lsp'.display_lsp_references()",
      ['Call Heirarchy'] = "lua require'ar.menus.lsp'.display_call_hierarchy()",
      ['Goto Workspace Symbol'] = "lua require'ar.menus.lsp'.filter_lsp_workspace_symbols()",
      ['Goto Workspace Symbol Under Cursor'] = "lua require'ar.menus.lsp'.ws_symbol_under_cursor()",
    })
  end

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
if ar_config.ai.enable then
  -- local function execute_if_available(plugin, command, visual)
  --   if not ar.plugin_available(plugin) then return end
  --   if visual then
  --     ar.visual_cmd(command)
  --   else
  --     vim.cmd(command)
  --   end
  -- end

  -- ar.add_to_menu('ai', {})

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
  ['Toggle Autosave'] = "lua require'ar.menus.command_palette'.toggle_autosave()",
  ['Toggle Large File'] = "lua require'ar.menus.command_palette'.toggle_large_file()",
  ['Change Filetype'] = "lua require'ar.menus.command_palette'.quick_set_ft()",
  ['Search Code Deps'] = "lua require'ar.menus.command_palette'.search_code_deps()",
  ['Toggle File Diff'] = "lua require'ar.menus.command_palette'.toggle_file_diff()",
  ['Yank Last Message'] = [[let @+=substitute(execute('messages'), '\n\+', '\n', 'g')]],
  ['Clear Messages'] = function() vim.cmd('messages clear') end,
  ['Yank Last Ex Command'] = 'let @+=@:',
  ['Restart Editor'] = 'cq',
  ['Lazy UI'] = 'Lazy',
})

map(
  'n',
  '<leader>ob',
  '<Cmd>lua require"ar.menus.command_palette".open_file_in_centered_popup()<CR>',
  { desc = 'open buffer in floating window' }
)

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
