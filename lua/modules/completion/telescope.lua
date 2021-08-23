return function()
  local actions = require "telescope.actions"
  local nnoremap = rvim.nnoremap

  rvim.telescope = {
    prompt_prefix = " ❯ ",
    layout_config = { height = 0.9, width = 0.9 },
    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
  }

  require("telescope").setup {
    defaults = {
      prompt_prefix = rvim.telescope.prompt_prefix,
      selection_caret = " ",
      sorting_strategy = "ascending",
      file_ignore_patterns = {
        "yarn.lock",
        "target/*",
        "node_modules/*",
        "dist/*",
        ".git/*",
        "venv/*",
        ".venv/*",
        "__pycache__/*",
      },
      layout_strategy = "horizontal",
      layout_config = rvim.telescope.layout_config,
      borderchars = rvim.telescope.borderchars,
      file_sorter = require("telescope.sorters").get_fzy_sorter,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      mappings = {
        i = {
          ["<c-c>"] = function()
            vim.cmd "stopinsert!"
          end,
          ["<esc>"] = actions.close,
          ["<c-s>"] = actions.select_horizontal,
          ["<C-e>"] = actions.send_to_qflist,
        },
      },
      file_browser = { hidden = true },
      extensions = {
        fzy_native = {
          override_generic_sorter = false,
          override_file_sorter = true,
        },
        media_files = {
          filetypes = { "png", "webp", "jpg", "jpeg" },
          find_cmd = "rg",
        },
      },
    },
  }

  if rvim.plugin_loaded "telescope-fzy-native.nvim" then
    vim.cmd [[packadd telescope-fzy-native.nvim]]
    require("telescope").load_extension "fzy_native"
  end

  if rvim.plugin_loaded "telescope-project.nvim" then
    vim.cmd [[packadd telescope-project.nvim]]
    require("telescope").load_extension "project"
    nnoremap("<leader>fep", ":Telescope project<CR>")
  end

  if rvim.plugin_loaded "telescope-media-files.nvim" then
    vim.cmd [[packadd telescope-media-files.nvim]]
    require("telescope").load_extension "media_files"
    nnoremap("<Leader>fem", ":Telescope media_files<CR>")
  end

  if rvim.plugin_loaded "project.nvim" then
    vim.cmd [[packadd project.nvim]]
    require("telescope").load_extension "projects"
    nnoremap("<Leader>fee", ":Telescope projects<CR>")
  end

  local extensions = {
    "grep_string_prompt",
    "bg_selector",
    "nvim_files",
    "dotfiles",
  }

  local function load_extensions(exps)
    for _, ext in ipairs(exps) do
      require("telescope").load_extension(ext)
    end
  end
  load_extensions(extensions)

  -- Mappings

  -- Telescope
  nnoremap("<Leader>ff", ":Telescope find_files<CR>")
  nnoremap("<Leader>fb", ":Telescope file_browser<CR>")
  nnoremap("<Leader>frr", ":Telescope oldfiles<CR>")
  nnoremap("<Leader>fre", ":Telescope projects<CR>")
  nnoremap("<Leader>fca", ":Telescope autocommands<CR>")
  nnoremap("<Leader>fcb", ":Telescope buffers<CR>")
  nnoremap("<Leader>fcc", ":Telescope commands<CR>")
  nnoremap("<Leader>fcf", ":Telescope builtin<CR>")
  nnoremap("<Leader>fch", ":Telescope help_tags<CR>")
  nnoremap("<Leader>fcH", ":Telescope command_history<CR>")
  nnoremap("<Leader>fck", ":Telescope keymaps<CR>")
  nnoremap("<Leader>fcl", ":Telescope loclist<CR>")
  nnoremap("<Leader>fce", ":Telescope quickfix<CR>")
  nnoremap("<Leader>fcr", ":Telescope registers<CR>")
  nnoremap("<Leader>fcT", ":Telescope treesitter<CR>")
  nnoremap("<Leader>fcv", ":Telescope vim_options<CR>")
  nnoremap("<Leader>fcz", ":Telescope current_buffer_fuzzy_find<CR>")
  nnoremap("<Leader>fC", ":e " .. vim.g.vim_path .. "/lua/core/config.lua<CR>")

  -- Telescope lsp
  nnoremap("<Leader>fva", ":Telescope lsp_range_code_actions<CR>")
  nnoremap("<Leader>fvr", ":Telescope lsp_references<CR>")
  nnoremap("<Leader>fvd", ":Telescope lsp_document_symbols<CR>")
  nnoremap("<Leader>fvw", ":Telescope lsp_workspace_symbols<CR>")

  -- Telescope grep
  nnoremap("<Leader>fle", ":Telescope grep_string_prompt<CR>")
  nnoremap("<Leader>flg", ":Telescope live_grep<CR>")
  nnoremap("<Leader>flw", ":Telescope grep_string<CR>")

  -- Telescope git
  nnoremap("<Leader>fgb", ":Telescope git_branches<CR>")
  nnoremap("<Leader>fgc", ":Telescope git_commits<CR>")
  nnoremap("<Leader>fgC", ":Telescope git_bcommits<CR>")
  nnoremap("<Leader>fgf", ":Telescope git_files<CR>")
  nnoremap("<Leader>fgs", ":Telescope git_status<CR>")

  -- Telescope extensions
  nnoremap("<Leader>frf", ":Telescope nvim_files files<CR>")
  nnoremap("<Leader>frg", ":Telescope nvim_files git_files<CR>")
  nnoremap("<Leader>frB", ":Telescope nvim_files bcommits<CR>")
  nnoremap("<Leader>frc", ":Telescope nvim_files commits<CR>")
  nnoremap("<Leader>frb", ":Telescope nvim_files branches<CR>")
  nnoremap("<Leader>frs", ":Telescope nvim_files status<CR>")

  nnoremap("<Leader>fdf", ":Telescope dotfiles git_files<CR>")
  nnoremap("<Leader>fdB", ":Telescope dotfiles bcommits<CR>")
  nnoremap("<Leader>fdc", ":Telescope dotfiles commits<CR>")
  nnoremap("<Leader>fdb", ":Telescope dotfiles branches<CR>")
  nnoremap("<Leader>fds", ":Telescope dotfiles status<CR>")

  nnoremap("<Leader>feb", ":Telescope bg_selector<CR>")
end
