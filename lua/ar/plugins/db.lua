return {
  { 'jsborjesson/vim-uppercase-sql', ft = { 'sql' } },
  {
    'kristijanhusak/vim-dadbod-ui',
    init = function()
      require('which-key').add({ { '<leader><leader>d', group = 'Dadbod' } })

      local function open_db_common(db_name)
        vim.cmd([[tabnew]])
        vim.fn['db_ui#reset_state']()
        vim.b.dbui_db_key_name = db_name .. '_g:dbs'

        pcall(vim.cmd, 'DBUIFindBuffer') -- pcall, for nice error handling if the DB does not exist
        vim.cmd('DBUI')
        -- open the tables list and get back where i was
        vim.cmd('norm jjojjjjokkkkkk')
        -- go twice up and select "new buffer". didn't find a nicer way
        vim.cmd('norm kko')
      end

      ---@param db_name string
      local function open_local_postgres_db(db_name)
        vim.g.dbs = {
          [db_name] = 'postgresql://postgres@localhost/' .. db_name,
        }
        vim.cmd([[tabnew]])
        vim.fn['db_ui#reset_state']()
        vim.b.dbui_db_key_name = db_name .. '_g:dbs'

        pcall(vim.cmd, 'DBUIFindBuffer') -- pcall, for nice error handling if the DB does not exist
        vim.cmd('DBUI')
        -- open the tables list and get back where i was
        vim.cmd('norm jjojjjjokkkkkk')
        -- go twice up and select "new buffer". didn't find a nicer way
        vim.cmd('norm kko')
      end

      local function pick_local_pg_db()
        local db_names = {}
        vim.fn.jobstart(
          { 'sh', '-c', "psql -l | grep $(whoami) | awk '{print $1}'" },
          {
            on_stdout = vim.schedule_wrap(function(_, output)
              for _, line in ipairs(output) do
                table.insert(db_names, line)
              end
            end),
            on_exit = vim.schedule_wrap(function(_, _)
              vim.ui.select(
                db_names,
                { prompt = 'Pick the database to open', kind = 'center_win' },
                function(choice)
                  if choice ~= nil then open_local_postgres_db(choice) end
                end
              )
            end),
          }
        )
      end

      local function open_saved_query()
        local uv = vim.uv
        local folder =
          string.gsub(vim.g.db_ui_save_location, '~', uv.os_homedir())
        local sd = uv.fs_scandir(folder)
        local saved_queries = {}
        while true do
          local name, type = uv.fs_scandir_next(sd)
          if name == nil then break end
          if type == 'directory' then
            local nested_path = folder .. '/' .. name
            local nested_sd = uv.fs_scandir(nested_path)
            while true do
              local nested_name, _ = uv.fs_scandir_next(nested_sd)
              if nested_name == nil then break end
              table.insert(saved_queries, name .. '/' .. nested_name)
            end
          end
        end

        local pickers = require('telescope.pickers')
        local previewers = require('telescope.previewers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local actions = require('telescope.actions')
        local actions_state = require('telescope.actions.state')
        local putils = require('telescope.previewers.utils')
        local opts = {}

        local function finder()
          return finders.new_table({
            results = saved_queries,
            entry_maker = function(val)
              local entry = {}
              entry.value = folder .. '/' .. val
              entry.ordinal = val
              entry.display = val
              return entry
            end,
          })
        end

        local function previewer()
          return previewers.new_buffer_previewer({
            title = 'Query',
            get_buffer_by_name = function(_, entry) return entry.value end,
            define_preview = function(self, entry)
              conf.buffer_previewer_maker(entry.value, self.state.bufnr, {
                bufname = self.state.bufname,
                winid = self.state.winid,
                callback = function(bufnr) putils.highlighter(bufnr, 'sql') end,
              })
            end,
          })
        end

        local function attach_mappings(_, map)
          map('i', '<Cr>', function(prompt_bufnr)
            local filename = actions_state.get_selected_entry().value
            local Path = require('plenary.path')
            actions.close(prompt_bufnr)
            -- copy to the clipboard
            vim.fn.setreg('+', Path.new(filename):read())
          end)
          map('i', '<C-o>', function()
            local filename = actions_state.get_selected_entry().value
            local Path = require('plenary.path')
            vim.fn.jobstart({ 'xdg-open', Path.new(filename):parent().filename })
          end)
          return true
        end

        pickers
          .new(opts, {
            prompt_title = 'Saved queries',
            finder = finder(),
            -- previewer = conf.file_previewer(opts),
            previewer = previewer(),
            sorter = conf.generic_sorter(opts),
            attach_mappings = attach_mappings,
          })
          :find()
      end

      local function open_json()
        local db_name = vim.fn.expand('%')
        vim.g.dbs = {
          [db_name] = 'jq:' .. db_name,
        }
        open_db_common(db_name)
      end

      ar.add_to_menu('command_palette', {
        ['Open Local Postgres DB'] = pick_local_pg_db,
        ['Open Saved Query'] = open_saved_query,
        ['Open Json'] = open_json,
      })
    end,
    dependencies = {
      'tpope/vim-dadbod',
      'kristijanhusak/vim-dadbod-completion',
      {
        'kristijanhusak/vim-dadbod-completion',
        ft = { 'sql', 'mysql', 'psql' },
      },
    },
    -- stylua: ignore
    keys = {
      { '<leader><leader>du', '<Cmd>DBUIToggle<CR>', desc = 'dadbod: toggle' },
      { '<leader><leader>da', '<Cmd>DBUIAddConnection<CR>', desc = 'dadbod: add connection' },
    },
    -- stylua: ignore
    cmd = {
      'DBUI', 'DBUIAddConnection', 'DBUIClose', 'DBUIToggle', 'DBUIFindBuffer',
      'DBUIRenameBuffer', 'DBUILastQueryInfo',
    },
    config = function()
      vim.g.db_ui_notification_width = 1
      vim.g.db_ui_debug = 1
      vim.g.db_ui_save_location = join_paths(vim.fn.stdpath('data'), 'db_ui')
      vim.g.db_ui_use_nerd_fonts = 1

      ar.augroup('dad-bod', {
        event = { 'FileType' },
        pattern = { 'sql' },
        command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
      }, {
        event = { 'FileType' },
        pattern = { 'sql', 'mysql', 'plsql' },
        command = function()
          vim.schedule(
            function()
              require('cmp').setup.buffer({
                sources = {
                  { name = 'vim-dadbod-completion' },
                  { name = 'buffer' },
                },
              })
            end
          )
        end,
      }, {
        event = { 'FileType' },
        pattern = { 'dbout' },
        command = function() vim.api.nvim_win_set_height(0, 40) end,
      })
    end,
  },
}
