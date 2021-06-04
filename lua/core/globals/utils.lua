_GlobalCallbacks = _GlobalCallbacks or {}

_G.r17 = {_store = _GlobalCallbacks}

function r17._create(f)
  table.insert(r17._store, f)
  return #r17._store
end

function r17._execute(id, args)
  r17._store[id](args)
end

function r17.echomsg(msg, hl)
  hl = hl or "Title"
  local msg_type = type(msg)
  if msg_type ~= "string" or "table" then
    return
  end
  if msg_type == "string" then
    msg = {{msg, hl}}
  end
  vim.api.nvim_echo(msg, true, {})
end

local fmt = string.format

function r17.augroup(name, commands)
  vim.cmd("augroup " .. name)
  vim.cmd("autocmd!")
  for _, c in ipairs(commands) do
    local command = c.command
    if type(command) == "function" then
      local fn_id = r17._create(command)
      command = fmt("lua as._execute(%s)", fn_id)
    end
    vim.cmd(string.format("autocmd %s %s %s %s", table.concat(c.events, ","),
                          table.concat(c.targets or {}, ","),
                          table.concat(c.modifiers or {}, " "), command))
  end
  vim.cmd("augroup END")
end

