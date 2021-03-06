local G = require "core.global"
local actions = require 'telescope.actions'
local config = {}

function config.compe()
  require('compe').setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = "enable";
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    documentation = true;
    allow_prefix_unmatch = false;
    source = {
      nvim_lsp = true;
      buffer = true,
      calc = true,
      vsnip = true;
      path = true;
      treesitter = true;
    };
  }
end

function config.saga()
  local opts =  {
    error_sign = '',
    warn_sign = '',
    hint_sign = '',
    infor_sign = '',
    use_saga_diagnostic_sign = true,
    dianostic_header_icon = '   ',
    code_action_icon = ' ',
    rename_prompt_prefix = '➤',
    finder_definition_icon = '  ',
    finder_reference_icon = '  ',
    definition_preview_icon = '  ',
    code_action_keys = { quit = 'q',exec = '<CR>' },
    max_preview_lines = 10,
    finder_action_keys = {
      open = 'o', vsplit = 's',split = 'i',quit = 'x',scroll_down = '<C-n>', scroll_up = '<C-b>'
    },
    -- 1: thin border | 2: rounded border | 3: thick border | 4: ascii border
    border_style = 1,
    rename_action_keys = { quit = '<C-c>',exec = '<CR>' },
  }
  return opts
end

function config.emmet()
  vim.g.user_emmet_leader_key='<C-y>'

  vim.g.user_emmet_complete_tag = 0
  vim.g.user_emmet_install_global = 0
  vim.g.user_emmet_mode = 'i'
  vim.cmd('autocmd FileType html,css EmmetInstall')
end

function config.vsnip()
  vim.g["vsnip_snippet_dir"] = G.vim_path .. "snippets"
end

function config.telescope()
  vim.cmd("hi TelescopeBorder guifg=#7ec0ee")

  require('telescope').setup({
    defaults = {
      prompt_prefix = ">",
      -- prompt_prefix = '🍔 ',
      sorting_strategy = "descending",
      layout_strategy = "horizontal",
      file_ignore_patterns = {"target/*", "node_modules/*", "dist/*"},
      width = 0.75,
      preview_cutoff = 120,
      results_height = 1,
      results_width = 0.8,
      border = {},
      borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰'},
      color_devicons = true,
      use_less = true,
      set_env = { ['COLORTERM'] = 'truecolor' },
      file_sorter =  require'telescope.sorters'.get_fzy_sorter,
      generic_sorter =  require'telescope.sorters'.get_generic_fuzzy_sorter,
      file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
      grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
      qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
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
    }
  })

  require('telescope').load_extension('fzy_native')
end

return config
