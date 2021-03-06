local M = {}

function M.plug_config(use, item)
  local conf, cmd, branch, opt, requires, run, ft, event = nil, nil, nil, nil, nil, nil, nil, nil
  if item.config then
    conf = item.config
  end
  if item.cmd then
    cmd = item.cmd
  end
  if item.branch then
    branch = item.branch
  end
  if item.opt then
    opt = item.opt
  end
  if item.requires then
    requires = item.requires
  end
  if item.run then
    run = item.run
  end
  if item.ft then
    ft = item.ft
  end
  if item.event then
    event = item.event
  end
  use {
    item.repo,
    config = conf,
    cmd = cmd,
    branch = branch,
    opt = opt,
    requires = requires,
    run = run,
    ft = ft,
    event = event
  }
end

return M
