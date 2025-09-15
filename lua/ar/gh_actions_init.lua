-- https://github.com/jugarpeupv/dotfiles/blob/535e69fdfb0590fb5aeca5f7dc5f0f7decdee651/nvim/.config/nvim/lua/jg/custom/lsp-utils.lua#L183
local function fetch_github_repo(repo_name, token, org, workspace_path)
  local cmd = {
    'curl',
    '-H',
    'Authorization: Bearer ' .. token,
    '-H',
    'User-Agent: Neovim',
    'https://api.github.com/repos/' .. org .. '/' .. repo_name,
  }

  local result = vim.system(cmd):wait()
  if not result or not result.stdout then
    print('No result from GitHub API')
    return {}
  end

  local raw_json = result.stdout
  if raw_json == '' then
    print('Empty JSON from GitHub API')
    return {}
  end

  local ok, data = pcall(vim.json.decode, raw_json)
  if not ok or type(data) ~= 'table' then
    print('Failed to decode JSON from GitHub API')
    return {}
  end

  local repo_info = {
    id = data.id,
    owner = org,
    name = repo_name,
    workspaceUri = 'file://' .. workspace_path,
    organizationOwned = true,
  }
  return repo_info
end

return function(org, workspace_path, session_token)
  org = org or 'razak17'
  workspace_path = workspace_path or vim.fn.getcwd()
  session_token = session_token or vim.env.GH_ACTIONS_PAT

  local function get_repo_name()
    local handle = io.popen('git remote get-url origin 2>/dev/null')
    if not handle then return nil end
    local result = handle:read('*a')
    handle:close()
    if not result or result == '' then return nil end
    -- Remove trailing newline
    result = result:gsub('%s+$', '')
    -- Extract repo name from URL
    local repo = result:match('([^/:]+)%.git$')
    return repo
  end

  local repo_name = get_repo_name()

  if repo_name == nil then return {} end

  local repo_info =
    fetch_github_repo(repo_name, session_token, org, workspace_path)
  return {
    sessionToken = session_token,
    repos = {
      repo_info,
    },
  }
end
