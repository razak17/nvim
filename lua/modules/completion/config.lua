local G = require 'core.global'
local config = {}

function config.which_key()
  require 'keymap.which_key'
end

function config.nvim_compe()
  require('compe').setup {
    enabled = true,
    debug = false,
    min_length = 1,
    preselect = "always",
    source = {
      nvim_lsp = {kind = "   (LSP)"},
      vsnip = {kind = "   (Snippet)"},
      path = {kind = "   (Path)"},
      buffer = {kind = "   (Buffer)"},
      spell = {kind = "   (Spell)"},
      calc = {kind = "   (Calc)"},
      vim_dadbod_completion = true,
      emoji = {kind = " ﲃ  (Emoji)", filetypes = {"markdown", "text"}},
      tags = true,
      nvim_lua = false
    }
  }
end

function config.vim_vsnip()
  vim.g["vsnip_snippet_dir"] = G.vim_path .. "/snippets"
end

function config.emmet()
  vim.g.user_emmet_complete_tag = 0
  vim.g.user_emmet_install_global = 0
  vim.g.user_emmet_install_command = 0
  vim.g.user_emmet_mode = 'i'
end

function config.telescope()
  -- require('modules.completion.telescope')
  local actions = require('telescope.actions')

  if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd popup.nvim]]
    vim.cmd [[packadd plenary.nvim]]
    vim.cmd [[packadd telescope-fzy-native.nvim]]
    vim.cmd [[packadd telescope-media-files.nvim]]
    vim.cmd [[packadd telescope-project.nvim]]
  end

  require('telescope').setup({
    defaults = {
      prompt_prefix = "> ",
      selection_caret = " ",
      sorting_strategy = "ascending",
      file_ignore_patterns = {
        "target/*",
        "node_modules/*",
        "dist/*",
        ".git/*",
        ".venv/*"
      },
      borderchars = {'─', '│', '─', '│', '┌', '┐', '┘', '└'},
      file_sorter = require'telescope.sorters'.get_fzy_sorter,
      file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
      grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
      qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
      mappings = {i = {["<C-e>"] = actions.send_to_qflist}},
      file_browser = {hidden = true},
      extensions = {
        fzy_native = {
          override_generic_sorter = false,
          override_file_sorter = true
        },
        media_files = {
          filetypes = {"png", "webp", "jpg", "jpeg"},
          find_cmd = "rg"
        }
      }
    }
  })

  require'telescope'.load_extension('media_files')
  require'telescope'.load_extension('fzy_native')
  require'telescope'.load_extension('project')
  require'telescope'.load_extension('nvim_files')
  require'telescope'.load_extension('dotfiles')
  require'telescope'.load_extension('grep_string_prompt')
  require'telescope'.load_extension('bg_selector')
end

return config
