local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  ------------------------------------------------------------------------------
  -- Config Time
  { 'sammce/fleeting.nvim', cond = not minimal and niceties, lazy = false },
  {
    'mrquantumcodes/configpulse',
    cond = not minimal and niceties,
    lazy = false,
  },
  {
    'blumaa/ohne-accidents',
    cond = not minimal and niceties,
    cmd = { 'OhneAccidents' },
    opts = { welcomeOnStartup = false },
  },
}
