local enabled = ar.config.plugin.custom.remote_sync.enable

if not ar or ar.none or not enabled then return end

ar.augroup('remote_sync', {
  event = 'BufWritePost',
  pattern = {
    '*/<project dir>/*',
  },
  command = function()
    local remote_host = 'user@server'

    local full_path = vim.fn.expand('%:p')
    local relative_to_home = string.gsub(full_path, vim.env.HOME, '')

    -- I flatten my paths on remote machines
    -- just use relative_to_home as remote_path if you don't
    local remote_path = string.gsub(relative_to_home, '/projects', '')

    local remote = remote_host .. ':~' .. remote_path
    local cmd = 'scp ' .. full_path .. ' ' .. remote

    vim.fn.jobstart(cmd, {
      on_exit = function(_, code)
        if code == 0 then
          vim.notify('File copied to ' .. remote, vim.log.levels.INFO)
        else
          vim.notify('Failed to copy file to ' .. remote, vim.log.levels.ERROR)
        end
      end,
    })
  end,
})
