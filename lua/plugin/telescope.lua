local actions = require 'telescope.actions'

vim.cmd("hi TelescopeBorder guifg=#7ec0ee")

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-x>"] = false,
        ["<C-e>"] = actions.select_tab,
        ["<CR>"] = actions.select_default,
        ["<C-b>"] = actions.move_selection_previous,
        ["<C-v>"] = actions.select_vertical,
        ["<C-i>"] = actions.select_horizontal,
      },
    },
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    extensions = {
      fzy_native = {
        override_generic_sorter = false,
        override_file_sorter = true,
      }
    },
    prompt_prefix = ">",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    file_ignore_patterns = {"target/*", "node_modules/*", "dist/*"},
    shorten_path = true,
    winblend = 0,
    width = 0.75,
    preview_cutoff = 120,
    results_height = 1,
    results_width = 0.8,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰'},
    -- borderchars = {'═', '║', '═', '║', '╔', '╗', '╝', '╚'},
    color_devicons = true,
    use_less = true,
    set_env = { ['COLORTERM'] = 'truecolor' },
    file_sorter =  require'telescope.sorters'.get_fzy_sorter,
    generic_sorter =  require'telescope.sorters'.get_generic_fuzzy_sorter,
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
  }
})

require('telescope').load_extension('fzy_native')

local M = {}
M.search_dotfiles = function()
    require("telescope.builtin").find_files({
        prompt_title = "< VimRC >",
        cwd = "$HOME/dots/.config/nvim",
    })
end

M.git_branches = function()
    require("telescope.builtin").git_branches({
        attach_mappings = function(prompt_bufnr, map)
            map('i', '<c-d>', actions.git_delete_branch)
            map('n', '<c-d>', actions.git_delete_branch)
            return true
        end
    })
end

-- return M

