local enabled = ar.config.plugin.custom.advanced_new_file.enable

if not ar or ar.none or not enabled then return end

-- create a new file in the same directory
local function new_file_in_current_dir()
  vim.ui.input({
    prompt = 'New file name: ',
    default = '',
    completion = 'file',
  }, function(file)
    if not file or file == '' then return end
    vim.defer_fn(function()
      ar.open_with_window_picker(
        function() vim.cmd('e ' .. vim.fn.expand('%:p:h') .. '/' .. file) end
      )
    end, 100)
  end)
end

map('n', '<leader>nf', new_file_in_current_dir, { desc = 'create new file' })
