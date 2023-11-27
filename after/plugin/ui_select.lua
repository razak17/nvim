if not rvim or rvim.none or not rvim.plugins.enable then return end

local file_select = require('rm.files_select')
local git_select = require('rm.git_select')
local lsp_select = require('rm.lsp_select')
local toggles_select = require('rm.toggles_select')

--------------------------------------------------------------------------------
-- Toggles
--------------------------------------------------------------------------------
---@param opt string
local function toggle_opt(opt)
  local prev = vim.api.nvim_get_option_value(opt, {})
  local value
  if type(prev) == 'boolean' then value = not prev end
  vim.wo[opt] = value
  toggles_select.mappings_notify(
    string.format('%s %s', opt, rvim.bool2str(vim.wo[opt]))
  )
end

local toggle_options = {
  ['Toggle Aerial'] = 'AerialToggle',
  ['Toggle Wrap'] = function() toggle_opt('wrap') end,
  ['Toggle Cursorline'] = function() toggle_opt('cursorline') end,
  ['Toggle Spell'] = function() toggle_opt('spell') end,
  ['Toggle Statusline'] = toggles_select.toggle_statusline,
  ['Toggle Ccc'] = 'CccHighlighterToggle',
  ['Toggle Pick'] = 'CccPick',
  ['Toggle Cloak'] = 'CloakToggle',
  ['Toggle SpOnGeBoB'] = 'SpOnGeBoBtOgGlE',
  ['Toggle Lengthmatters'] = 'LengthmattersToggle',
  ['Toggle Twilight'] = 'Twilight',
  ['Toggle ZenMode'] = 'ZenMode',
  ['Toggle Sunglasses'] = toggles_select.toggle_sunglasses,
  ['Toggle Zoom'] = 'lua require("mini.misc").zoom()',
}

local toggle_menu = function()
  rvim.create_select_menu('Toggle actions', toggle_options)() --> extra paren to execute!
end

-- stylua: ignore
map( 'n', '<leader>oo', toggle_menu, { desc = '[t]oggle [a]ctions: open menu for toggle actions' })

if not rvim.plugins.enable then return end

--------------------------------------------------------------------------------
-- Files
--------------------------------------------------------------------------------
local file_options = {
  ['Open File From Current Dir'] = function()
    file_select.open_file_cur_dir(false)
  end,
  ['Open File From Current Dir And Children'] = function()
    file_select.open_file_cur_dir(true)
  end,
  ['Reload All Files From Disk'] = 'lua rvim.reload_all()',
  ['Copy File Path'] = file_select.copy_file_path,
  ['Copy Full File Path'] = 'let @+ = expand("%:p")',
  ['Yank Last Ex Command'] = 'let @+=@:',
  ['Yank Last Message'] = [[let @+=substitute(execute('messages'), '\n\+', '\n', 'g')]],
  ['Change Filetype'] = file_select.quick_set_ft,
  ['Search Code Deps'] = file_select.search_code_deps,
  ['Toggle Diff'] = file_select.toggle_diff,
  ['Toggle Interceptor'] = 'InterceptToggle',
  ['Re-open File With Sudo Permissions'] = 'SudaRead',
  ['Write File With Sudo Permissions'] = 'SudaWrite',
}

local file_menu = function()
  rvim.create_select_menu('File actions', file_options)()
end

-- stylua: ignore
map( 'n', '<leader>of', file_menu, { desc = '[f]ile [a]ctions: open menu for file actions' })

--------------------------------------------------------------------------------
-- Git
--------------------------------------------------------------------------------
if rvim.is_git_repo() then
  local git_options = {
    ['Show Branches'] = "lua require'telescope.builtin'.git_branches()",
    ['Browse Branches'] = git_select.browse_branches,
    ['Stash Changes'] = git_select.do_stash,
    ['Browse Stashes'] = git_select.list_stashes,
    ['Browse Commits'] = git_select.browse_commits,
    ['Show Buffer Commits'] = git_select.browse_bcommits,
    ['Show Commit At Line'] = git_select.show_commit_at_line,
    ['Show Commit From Hash'] = git_select.display_commit_from_hash,
    ['Open File From Branch'] = "lua require'agitator'.open_file_git_branch()",
    ['Search In Another Branch'] = "lua require'agitator'.search_git_branch()",
    ['Open Co Authors'] = 'GitCoAuthors',
    ['Time Machine'] = git_select.time_machine,
    ['Browse Project History'] = git_select.project_history,
    ['Browse File Commit History'] = 'DiffviewFileHistory %',
    ['Pull Latest Changes'] = git_select.git_pull,
    ['Fetch Orign'] = git_select.fetch_origin,
    ['Conflict Show Base'] = function() git_select.diffview_conflict('base') end,
    ['Conflict Show Ours'] = function() git_select.diffview_conflict('ours') end,
    ['Conflict Show Theirs'] = function()
      git_select.diffview_conflict('theirs')
    end,
  }

  local git_menu = function()
    rvim.create_select_menu('Git Commands', git_options)()
  end

  -- stylua: ignore
  map( 'n', '<leader>og', git_menu, { desc = '[g]it [a]ctions: open menu for git commands' })
end

--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------
if rvim.lsp.enable then
  local lsp_options = {
    ['Code Format'] = lsp_select.format_buf,
    ['Eslint Fix'] = lsp_select.eslint_fix,
    ['LSP references'] = lsp_select.display_lsp_references,
    ['Call Heirarchy'] = lsp_select.display_call_hierarchy,
    ['Restart All LSPs'] = lsp_select.lsp_restart_all,
    ['Toggle Linting Globally'] = lsp_select.toggle_linting,
    ['Toggle Virtual Text'] = lsp_select.toggle_virtual_text,
    ['Toggle Virtual Lines'] = lsp_select.toggle_virtual_lines,
    ['Toggle Diagnostic Signs'] = lsp_select.toggle_signs,
    ['Toggle Hover Diagnostics'] = lsp_select.toggle_hover_diagnostics,
    ['Toggle Hover Diagnostics (go_to)'] = lsp_select.toggle_hover_diagnostics_go_to,
    ['Toggle Format On Save'] = lsp_select.toggle_format_on_save,
    ['Toggle JS Arrow Function'] = 'lua require("nvim-js-actions/js-arrow-fn").toggle()',
    ['Preview Code Actions'] = 'lua require("actions-preview").code_actions()',
  }

  local lsp_menu = function()
    if #lsp_select.lsp_clients(0) == 0 then
      vim.notify_once('there is no lsp server attached to the current buffer')
    else
      rvim.create_select_menu('Code/LSP actions', lsp_options)() --> extra paren to execute!
    end
  end

  -- stylua: ignore
  map( 'n', '<leader>ol', lsp_menu, { desc = '[l]sp [a]ctions: open menu for lsp features' })
end
