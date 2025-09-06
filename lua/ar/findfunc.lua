local M = {}

-- https://www.reddit.com/r/neovim/comments/1n92i8w/fuzzy_finder_without_plugins_but_make_it_async/

local fnames = {} ---@type string[]
local handle ---@type vim.SystemObj?
local needs_refresh = true

function M.refresh()
  if handle ~= nil or not needs_refresh then return end

  needs_refresh = false

  fnames = {}

  local prev

  handle = vim.system(
    { 'fd', '-t', 'f', '--hidden', '--color=never', '-E', '.git' },
    {
      stdout = function(err, data)
        assert(not err, err)
        if not data then return end

        if prev then data = prev .. data end

        if data[#data] == '\n' then
          vim.list_extend(fnames, vim.split(data, '\n', { trimempty = true }))
        else
          local parts = vim.split(data, '\n', { trimempty = true })
          prev = parts[#parts]
          parts[#parts] = nil
          vim.list_extend(fnames, parts)
        end
      end,
    },
    function(obj)
      if obj.code ~= 0 then print('Command failed') end
      handle = nil
    end
  )

  vim.api.nvim_create_autocmd('CmdlineLeave', {
    once = true,
    callback = function()
      needs_refresh = true
      if handle then
        handle:wait(0)
        handle = nil
      end
    end,
  })
end

function M.fd_findfunc(cmdarg, _cmdcomplete)
  if #cmdarg == 0 then
    M.refresh()
    vim.wait(200, function() return #fnames > 0 end)
    return fnames
  else
    return vim.fn.matchfuzzy(fnames, cmdarg, { matchseq = 1, limit = 100 })
  end
end

return M
