return function()
  local status_ajk_ok, ajk = rvim.safe_require "accelerated-jk"
  if not status_ajk_ok then
    return
  end

  ajk.setup {
    -- equal to
    -- nmap <silent> j <cmd>lua require'accelerated-jk'.command('gj')<cr>
    -- nmap <silent> k <cmd>lua require'accelerated-jk'.command('gk')<cr>
    mappings = { n = "gj", k = "gk" },
    -- If the interval of key-repeat takes more than `acceleration_limit` ms, the step is reset
    acceleration_limit = 150,
    -- acceleration steps
    acceleration_table = { 7, 12, 17, 21, 24, 26, 28, 30 },
    -- If you want to decelerate a cursor moving by time instead of reset. set it
    -- exampe:
    -- {
    --   { 200, 3 },
    --   { 300, 7 },
    --   { 450, 11 },
    --   { 600, 15 },
    --   { 750, 21 },
    --   { 900, 9999 },
    -- }
    deceleration_table = { { 150, 9999 } },
  }
end
