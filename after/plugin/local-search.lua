if not ar then return end

local configured = ar.config.plugin.extra.local_search.enable

if ar.none or not configured then return end

local api, fn = vim.api, vim.fn
local enabled = true

local function save(buf)
  vim.b[buf].last_search_pattern = fn.getreg('/')
  vim.b[buf].last_search_forward = vim.v.searchforward
end

ar.augroup('BufferLocalSearch', {
  event = 'BufLeave',
  command = function(args)
    if enabled then save(args.buf) end
  end,
}, {
  event = 'BufEnter',
  command = function(args)
    if not enabled then return end

    local pattern = vim.b[args.buf].last_search_pattern

    -- A new buffer initially inherits the current search.
    if pattern == nil then
      save(args.buf)
      return
    end

    fn.setreg('/', pattern)

    -- Autocommands temporarily preserve v:searchforward, so restore it
    -- on the next event-loop iteration.
    vim.schedule(function()
      if
        enabled
        and api.nvim_buf_is_valid(args.buf)
        and api.nvim_get_current_buf() == args.buf
      then
        vim.v.searchforward = vim.b[args.buf].last_search_forward
      end
    end)
  end,
})

ar.command('LocalSearchToggle', function()
  -- Capture the active search before either pausing or resuming isolation.
  save(api.nvim_get_current_buf())
  enabled = not enabled

  vim.notify(
    ('buffer-local search %s'):format(enabled and 'enabled' or 'disabled'),
    vim.log.levels.INFO,
    { title = 'Local Search' }
  )
end, { desc = 'toggle buffer-local search' })
