local config = {}

function config.compe()
  require('compe').setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = "enable";
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    documentation = true;
    allow_prefix_unmatch = false;
    source = {
      nvim_lsp = true;
      buffer = true,
      calc = true,
      vsnip = true;
      path = true;
      treesitter = true;
    };
  }
end

function config.emmet()
  vim.g.user_emmet_leader_key='<C-y>'

  vim.g.user_emmet_mode='a'
  vim.g.user_emmet_install_global = 0
  vim.cmd('autocmd FileType html,css EmmetInstall')
end

return config
