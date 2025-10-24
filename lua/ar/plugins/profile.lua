local minimal = ar.plugins.minimal

return {
  { 'dundalek/bloat.nvim', cmd = 'Bloat' },
  {
    'stevearc/profile.nvim',
    cond = function() return ar.get_plugin_cond('profile.nvim', not minimal) end,
    lazy = false,
    init = function()
      local should_profile = vim.env.NVIM_PROFILE
      if should_profile then
        require('profile').instrument_autocmds()
        if should_profile:lower():match('^start') then
          require('profile').start('*')
        else
          require('profile').instrument('*')
        end
      end

      local function toggle_profile()
        local prof = require('profile')
        if prof.is_recording() then
          prof.stop()
          vim.ui.input({
            prompt = 'Save profile to:',
            completion = 'file',
            default = 'profile.json',
          }, function(filename)
            if filename then
              prof.export(filename)
              vim.notify(string.format('Wrote %s', filename))
            end
          end)
        else
          prof.start('*')
        end
      end
      ar.add_to_select_menu(
        'command_palette',
        { ['Toggle Profile'] = toggle_profile }
      )
    end,
  },
}
