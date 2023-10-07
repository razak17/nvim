local fn, uv, L = vim.fn, vim.uv, vim.log.levels
local cwd = fn.getcwd()

local disabled = not rvim
  or not rvim.lsp.enable
  or not rvim.lsp.timeout.enable
  or not rvim.plugins.enable
  or rvim.plugins.minimal
  or (cwd and rvim.dirs_match(rvim.lsp.disabled.directories, cwd))

if disabled then return end

rvim.lsp.timeout.start_timer = nil
rvim.lsp.timeout.stop_timer = nil
rvim.lsp.timeout.config = {
  stop = 1000 * 60 * 10, -- 10 minutes
  start = 1000 * 2, -- 2 seconds
  silent = false,
}

--------------------------------------------------------------------------------
-- Ref: https://github.com/hinell/lsp-timeout.nvim/blob/main/plugin/lsp-timeout.lua
--------------------------------------------------------------------------------

rvim.augroup('LspTimeout', {
  event = { 'FocusLost' },
  desc = "Stop LSP server if window isn't focused",
  command = function(args)
    if rvim.lsp.timeout.start_timer then
      rvim.lsp.timeout.start_timer:stop()
      rvim.lsp.timeout.start_timer:close()
      rvim.lsp.timeout.start_timer = nil
    end

    local active_servers = #vim.lsp.get_clients({ bufnr = args.buf })

    if not rvim.lsp.timeout.stop_timer and active_servers > 0 then
      local config = rvim.lsp.timeout.config
      local timeout = config.stop

      rvim.lsp.timeout.stop_timer = uv.new_timer()
      rvim.lsp.timeout.stop_timer:start(
        timeout,
        0,
        vim.schedule_wrap(function()
          rvim.lsp.timeout.enable = false
          vim.cmd('LspStop')
          if not config.silent then
            vim.notify(
              ('[[lsp-timeout.nvim]]: nvim has lost focus, stop %s language servers'):format(
                active_servers
              ),
              L.INFO
            )
          end
          rvim.lsp.timeout.stop_timer = nil
        end)
      )
    end
  end,
}, {
  event = { 'FocusGained' },
  desc = 'Restart LSP server if buffer is intered',
  command = function(args)
    if rvim.lsp.timeout.stop_timer then
      rvim.lsp.timeout.stop_timer:stop()
      rvim.lsp.timeout.stop_timer:close()
      rvim.lsp.timeout.stop_timer = nil
    end

    local active_servers = #vim.lsp.get_clients({ bufnr = args.buf })

    if not rvim.lsp.timeout.start_timer and active_servers < 1 then
      local config = rvim.lsp.timeout.config
      local timeout = config.start

      -- https://github.com/neovim/neovim/pull/22846
      rvim.lsp.timeout.start_timer = uv.new_timer()
      rvim.lsp.timeout.start_timer:start(
        timeout,
        0,
        vim.schedule_wrap(function()
          if rvim.lsp.timeout.start_timer then
            rvim.lsp.timeout.start_timer:stop()
            rvim.lsp.timeout.start_timer:close()
            rvim.lsp.timeout.start_timer = nil
          end

          vim.ui.input({
            prompt = 'Do you want to start LSP? (y/n) ',
          }, function(input)
            if input == 'y' then
              if active_servers < 1 then
                if not config.silent then
                  vim.notify(
                    ('[[lsp-timeout.nvim]]: %s servers found, restarting... '):format(
                      active_servers
                    ),
                    L.INFO
                  )
                end
                -- vim.cmd('LspStart')
                vim.cmd('edit | TSBufEnable highlight')
                rvim.lsp.timeout.enable = true
              end
            end
          end)
        end)
      )
    end
  end,
})
