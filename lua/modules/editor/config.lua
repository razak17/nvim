local config = {}

function config.delimimate()
  vim.g.delimitMate_expand_cr = 0
  vim.g.delimitMate_expand_space = 1
  vim.g.delimitMate_smart_quotes = 1
  vim.g.delimitMate_expand_inside_quotes = 0
  vim.api.nvim_command(
    'au FileType markdown let b:delimitMate_nesting_quotes = ["`"]')
end

function config.dial()
  vim.cmd([[
    nmap <C-a> <Plug>(dial-increment)
    nmap <C-x> <Plug>(dial-decrement)
    vmap <C-a> <Plug>(dial-increment)
    vmap <C-x> <Plug>(dial-decrement)
    vmap g<C-a> <Plug>(dial-increment-additional)
    vmap g<C-x> <Plug>(dial-decrement-additional)
  ]])
end

function config.nvim_colorizer()
  require'colorizer'.setup({
    '*',
    css = {rgb_fn = true, hsl_fn = true, names = true},
    scss = {rgb_fn = true, hsl_fn = true, names = true},
    sass = {rgb_fn = true, names = true},
    vim = {names = true},
    html = {mode = 'foreground'},
  }, {names = false, mode = 'background'})
end

function config.kommentary()
  require('kommentary.config').configure_language('default', {
    prefer_single_line_comments = true,
  })
  local fts = {'zsh', 'sh', 'yaml'}
  for _, f in pairs(fts) do
    require('kommentary.config').configure_language(f, {
      single_line_comment_string = "#",
    })
  end
end

function config.vim_cursorword()
  core.augroup("CursorWordMode", {
    {
      events = {"FileType"},
      targets = {
        "NvimTree",
        "lspsagafinder",
        "dashboard",
        "outline",
        "telescope",
      },
      command = "let b:cursorword = 0",
    },
    {
      events = {"WinEnter"},
      targets = {"which_key"},
      command = [[if &diff || &pvw | let b:cursorword = 0  | endif]],
    },
    {
      events = {"InsertEnter"},
      targets = {"which_key"},
      command = "let b:cursorword = 0",
    },
    {
      events = {"InsertLeave"},
      targets = {"which_key"},
      command = "let b:cursorword = 1",
    },
  })
end

return config
