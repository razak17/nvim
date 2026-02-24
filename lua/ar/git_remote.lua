local api = vim.api

local M = {}

-- https://github.com/matthis-k/nvim-flake/blob/main/lua/ui/statusline.lua?plain=1#L100
local git_cache = {}

-- Use a set (table with keys) instead of array for O(1) lookup
local fetched = {}

local function get_ahead_behind(git)
  local ok, res = pcall(function()
    -- stylua: ignore
    local line = vim.fn.system({
        'git', 'rev-list', '--left-right', '--count', git.head .. '...origin/' .. git.head,
      },
      git.root
    )
    local ahead, behind = line:match('(%d+)%s+(%d+)')
    return { ahead = tonumber(ahead) or 0, behind = tonumber(behind) or 0 }
  end)
  return ok and res or { error = 'No remote' }
end

-- Helper function to update git cache for a single root
local function update_git_root(git, refetch)
  if not git or not git.root then return false end
  -- Skip if already cached and not refetching
  if not refetch and git_cache[git.root] then return false end
  -- Skip if already fetched and not refetching
  if fetched[git.root] and not refetch then return false end

  git_cache[git.root] = get_ahead_behind(git)
  fetched[git.root] = true
  vim.schedule(
    function() api.nvim_exec_autocmds('User', { pattern = 'GitStatusChanged' }) end
  )
  return true
end

function M.update_ahead_behind(refetch, fast)
  if fast then
    local git = vim.b[0].gitsigns_status_dict
    update_git_root(git, refetch)
    return
  end

  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(bufnr) then
      local git = vim.b[bufnr].gitsigns_status_dict
      update_git_root(git, refetch)
    end
  end
end
ar.command('GitRemoteSync', function() M.update_ahead_behind(true) end)

function M.remote_counter()
  local gs = vim.b[vim.api.nvim_get_current_buf()].gitsigns_status_dict
  if not gs then return '' end
  if not git_cache[gs.root] then M.update_ahead_behind() end
  return git_cache[gs.root]
end

return M
