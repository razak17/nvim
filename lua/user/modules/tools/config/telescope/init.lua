return function()
  local telescope_ok, telescope = rvim.safe_require("telescope")
  if not telescope_ok then
    return
  end

  rvim.telescope = {}

  local previewers = require("telescope.previewers")
  local sorters = require("telescope.sorters")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local layout_actions = require("telescope.actions.layout")
  local themes = require("telescope.themes")
  local icons = rvim.style.icons
  local border = rvim.style.border

  rvim.augroup("TelescopePreviews", {
    {
      event = "User",
      pattern = "TelescopePreviewerLoaded",
      command = "setlocal number",
    },
  })

  -- https://github.com/nvim-telescope/telescope.nvim/issues/1048
  -- Ref: https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/telescope/init.lua
  local telescope_custom_actions = {}

  function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local num_selections = #picker:get_multi_selection()
    if not num_selections or num_selections <= 1 then
      actions.add_selection(prompt_bufnr)
    end
    actions.send_selected_to_qflist(prompt_bufnr)
    vim.cmd("cfdo " .. open_cmd)
  end

  function telescope_custom_actions.multi_selection_open(prompt_bufnr)
    telescope_custom_actions._multiopen(prompt_bufnr, "edit")
  end

  local function get_border(opts)
    return vim.tbl_deep_extend("force", opts or {}, {
      borderchars = border.telescope.ui_select,
    })
  end

  ---@param opts table
  ---@return table
  function rvim.telescope.dropdown(opts)
    return themes.get_dropdown(get_border(opts))
  end

  function rvim.telescope.ivy(opts)
    return require("telescope.themes").get_ivy(vim.tbl_deep_extend("keep", opts or {}, {
      borderchars = {
        preview = { "▔", "▕", "▁", "▏", "🭽", "🭾", "🭿", "🭼" },
      },
    }))
  end

  local dropdown = rvim.telescope.dropdown

  rvim.telescope.setup = {
    defaults = {
      prompt_prefix = " " .. icons.misc.chevron_right_alt .. " ",
      selection_caret = " " .. icons.misc.double_chevron_right .. " ", --  ,
      cycle_layout_list = { "flex", "horizontal", "vertical", "bottom_pane", "center" },
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      set_env = { ["TERM"] = vim.env.TERM },
      borderchars = border.telescope.prompt,
      file_browser = { hidden = true },
      color_devicons = true,
      dynamic_preview_title = true,
      layout_config = {
        height = 0.9,
        width = 0.9,
        preview_cutoff = 120,
        horizontal = {
          width_padding = 0.04,
          height_padding = 0.1,
          preview_width = 0.6,
        },
        vertical = {
          width_padding = 0.05,
          height_padding = 0.1,
          preview_height = 0.5,
        },
      },
      winblend = 5,
      history = {
        path = rvim.get_cache_dir() .. "/telescope/history.sqlite3",
      },
      file_ignore_patterns = {
        "%.jpg",
        "%.jpeg",
        "%.png",
        "%.otf",
        "%.ttf",
        "%.DS_Store",
        "%.lock",
        ".git/",
        "node_modules/",
        "dist/",
        "site-packages/",
      },
      path_display = { "smart", "absolute", "truncate" },
      file_sorter = sorters.get_fzy_sorter,
      file_previewer = previewers.vim_buffer_cat.new,
      grep_previewer = previewers.vim_buffer_vimgrep.new,
      qflist_previewer = previewers.vim_buffer_qflist.new,
      mappings = {
        i = {
          ["<C-w>"] = actions.send_selected_to_qflist,
          ["<c-c>"] = function()
            vim.cmd("stopinsert!")
          end,
          ["<esc>"] = actions.close,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          ["<c-s>"] = actions.select_horizontal,
          ["<CR>"] = actions.select_default,
          ["<c-e>"] = layout_actions.toggle_preview,
          ["<c-l>"] = layout_actions.cycle_layout_next,
          ["<C-A>"] = telescope_custom_actions.multi_selection_open,
          ["<Tab>"] = actions.toggle_selection,
        },
        n = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          ["<C-A>"] = telescope_custom_actions.multi_selection_open,
        },
      },
      extensions = {
        media_files = {
          -- filetypes whitelist
          -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
          filetypes = { "png", "webp", "jpg", "jpeg" },
          find_cmd = "rg", -- find command (defaults to `fd`)
        },
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        },
        ["ui-select"] = {
          themes.get_cursor(get_border({
            layout_config = {
              cursor = {
                width = 25,
              },
            },
          })),
        },
        file_browser = {
          theme = "ivy",
          mappings = {
            ["i"] = {
              i = {
                ["<C-h>"] = require("telescope").extensions.file_browser.actions.goto_home_dir,
              },
            },
            ["n"] = {
              n = {
                ["<C-h>"] = require("telescope").extensions.file_browser.actions.goto_home_dir,
                f = false,
              },
            },
          },
        },
        howdoi = rvim.telescope.ivy(),
      },
      pickers = {
        buffers = dropdown({
          sort_mru = true,
          sort_lastused = true,
          show_all_buffers = true,
          ignore_current_buffer = true,
          previewer = false,
          theme = "dropdown",
          mappings = {
            i = { ["<c-x>"] = "delete_buffer" },
            n = { ["<c-x>"] = "delete_buffer" },
          },
        }),
        find_files = {
          hidden = true,
        },
        keymaps = dropdown({
          layout_config = {
            height = 18,
            width = 0.5,
          },
        }),
        live_grep = {
          --@usage don't include the filename in the search results
          only_sort_text = true,
          -- NOTE: previewing html seems to cause some stalling/blocking whilst live grepping
          -- so filter out html.
          file_ignore_patterns = {
            ".git/",
            "%.html",
            "dotbot/.*",
            "zsh/plugins/.*",
          },
          max_results = 2000,
          on_input_filter_cb = function(prompt)
            -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
            return { prompt = prompt:gsub("%s", ".*") }
          end,
        },
        oldfiles = dropdown(),
        current_buffer_fuzzy_find = dropdown({
          previewer = false,
          shorten_path = false,
        }),
        colorscheme = {
          enable_preview = true,
        },
        git_branches = dropdown(),
        git_bcommits = {
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
        },
        git_commits = {
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
        },
        reloader = dropdown(),
      },
    },
  }

  telescope.setup(rvim.telescope.setup)

  local plugins = {
    project = "projects",
    telescope_dap = "dap",
    telescope_fzf = "fzf",
    telescope_ui_select = "ui-select",
    telescope_tmux = "tmux",
    telescope_file_browser = "file_browser",
    telescope_media_files = "media_files",
    telescope_zoxide = "zoxide",
    telescope_smart_history = "smart_history",
    howdoi = "howdoi",
  }

  for config, plug in pairs(plugins) do
    if rvim.plugins.tools[config].active then
      require("telescope").load_extension(plug)
    end
  end

  --- NOTE: this must be required after setting up telescope
  --- otherwise the result will be cached without the updates
  --- from the setup call
  local builtins = require("telescope.builtin")

  local rvim_files = require("user.modules.tools.config.telescope.nvim_files")
  local bg_selector = require("user.modules.tools.config.telescope.bg_selector")

  local function notes()
    builtins.find_files({
      prompt_title = "Notes",
      cwd = vim.fn.expand("~/notes/src/"),
    })
  end

  local function installed_plugins()
    require("telescope.builtins").find_files({
      prompt_title = "Installed plugins",
      cwd = join_paths(rvim.get_runtime_dir(), "/site/pack/packer"),
    })
  end

  local function builtin()
    require("telescope.builtins").builtin({ include_extensions = true })
  end

  local function project_files(opts)
    if not pcall(builtins.git_files, opts) then
      builtins.find_files(opts)
    end
  end

  local function file_browser()
    telescope.extensions.file_browser.file_browser({})
  end

  local function media_files()
    telescope.extensions.media_files.media_files({})
  end

  local function zoxide_list()
    telescope.extensions.zoxide.list({})
  end

  local function MRU()
    require("mru").display_cache(rvim.telescope.dropdown({
      previewer = false,
    }))
  end

  local function MFU()
    require("mru").display_cache(
      vim.tbl_extend("keep", { algorithm = "mfu" }, rvim.telescope.dropdown({ previewer = false }))
    )
  end

  local function projects()
    telescope.extensions.projects.projects({})
  end

  local function delta_opts(opts, is_buf)
    local delta = previewers.new_termopen_previewer({
      get_command = function(entry)
        local args = {
          "git",
          "-c",
          "core.pager=delta",
          "-c",
          "delta.side-by-side=false",
          "diff",
          entry.value .. "^!",
        }
        if is_buf then
          vim.list_extend(args, { "--", entry.current_file })
        end
        return args
      end,
    })
    opts = opts or {}
    opts.previewer = {
      delta,
      previewers.git_commit_message.new(opts),
    }
    return opts
  end

  local function delta_git_commits(opts)
    require("telescope.builtins").git_commits(delta_opts(opts))
  end

  local function delta_git_bcommits(opts)
    require("telescope.builtins").git_bcommits(delta_opts(opts, true))
  end

  local function howdoi()
    telescope.extensions.howdoi.howdoi()
  end

  require("which-key").register({
    ["<c-p>"] = { project_files, "telescope: find files" },
    ["<leader>f"] = {
      name = "Telescope",
      a = { builtin, "builtins" },
      b = { builtins.current_buffer_fuzzy_find, "find in current buffer" },
      B = { file_browser, "find browser" },
      c = {
        name = "rVim config",
        b = { rvim_files.branches, "branches" },
        c = { rvim_files.commits, "commits" },
        f = { rvim_files.files, "nvim files" },
        g = { rvim_files.grep_files, "find in files" },
        i = { rvim_files.view_changelog, "view changelog" },
      },
      g = {
        name = "Git",
        b = { builtins.git_branches, "branch" },
        B = { delta_git_bcommits, "buffer commits" },
        c = { delta_git_commits, "commits" },
        f = { builtins.git_files, "files" },
        o = { builtins.git_status, "open changed file" },
        s = { builtins.git_status, "status" },
      },
      h = { MFU, "most frequently used files" },
      H = { howdoi, "howdoi" },
      m = { media_files, "media files" },
      n = { notes, "notes" },
      o = { builtins.oldfiles, "old files" },
      p = { projects, "recent projects" },
      P = { installed_plugins, "plugins" },
      r = { MRU, "most recently used files" },
      R = { builtins.reloader, "module reloader" },
      s = { builtins.live_grep, "find word" },
      v = {
        name = "vim",
        a = { builtins.autocommands, "autocommands" },
        h = { builtins.highlights, "highlights" },
        o = { builtins.vim_options, "options" },
        r = { builtins.resume, "resume last picker" },
      },
      w = { builtins.grep_string, "find current word" },
      W = { bg_selector.set_bg_image, "change background" },
      z = { zoxide_list, "zoxide list" },
    },
  })

  vim.api.nvim_exec_autocmds("User", { pattern = "TelescopeConfigComplete", modeline = false })
end
