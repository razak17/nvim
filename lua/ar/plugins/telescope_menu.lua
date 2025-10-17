return {
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    opts = function()
      local function get_params(with_children)
        local folder = vim.fn.expand('%:h')
        local params = {}
        if with_children then
          params.search_dirs = { folder }
        else
          params.find_command = { 'rg', '--max-depth', '1', '--files', folder }
        end
        return params
      end

      --- Find files or word or grep in current directory
      ---@param which string
      ---@param with_children boolean
      local function fuzzy_in_cur_dir(which, with_children)
        return function()
          local params = get_params(with_children)
          local which_map = {
            ['files'] = 'find_files',
            ['grep'] = 'live_grep',
            ['word'] = 'grep_string',
          }
          require('telescope.builtin')[which_map[which]](params)
        end
      end

      ar.add_to_select_menu('command_palette', {
        ['Command History'] = 'Telescope command_history',
        ['Commands'] = 'Telescope commands',
        ['Find Files'] = 'Telescope find_files',
        ['Autocommands'] = 'Telescope autocommands',
        ['Highlights'] = 'Telescope highlights',
        ['Vim Options'] = 'Telescope vim_options',
        ['Registers'] = 'Telescope registers',
        ['Colorschemes'] = 'Telescope colorscheme',
        ['Keymaps'] = 'Telescope keymaps',
        ['Live Grep'] = 'Telescope live_grep',
        ['Seach History'] = 'Telescope search_history',
        ['Telescope Buffers'] = 'Telescope buffers',
        ['Telescope Marks'] = 'Telescope marks',
        ['Telescope Projects'] = 'Telescope projects',
        ['Telescope Resume'] = 'Telescope resume',
        ['Telescope Undo'] = 'Telescope undo',
        ['Recently Closed Buffers'] = 'Telescope oldfiles cwd_only=true',
        ['Find Files In Dir'] = fuzzy_in_cur_dir('files', false),
        ['Find Files In Dir & Children'] = fuzzy_in_cur_dir('files', true),
        ['Live Grep In Dir'] = fuzzy_in_cur_dir('grep', true),
        ['Find Word In Dir'] = fuzzy_in_cur_dir('word', true),
      })
    end,
  },
}
