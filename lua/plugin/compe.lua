local mappings = require 'utils.map'
local inoremap = mappings.inoremap
local opts = { expr = true }

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

inoremap("<C-Space>", "compe#complete()", opts)
inoremap("<CR> ",     "compe#confirm('<CR>')", opts)
inoremap("<C-e>",     "compe#close('<C-e>')", opts)
inoremap("<C-f>",     "compe#scroll({ 'delta': +4 })", opts)
inoremap("<C-d>",     "compe#scroll({ 'delta': -4 })", opts)
