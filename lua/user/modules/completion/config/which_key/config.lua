rvim.wk = {
  leader_mode = {
    ["?"] = "search word",
    S = "edit snippet",
    a = {
      name = "+Actions",
      [";"] = "open terminal",
      e = "turn off guides",
      F = { ":vertical resize 90<cr>", "vertical resize 90" },
      L = { ":vertical resize 40<cr>", "vertical resize 30%%" },
      o = "turn on guides",
      O = { ":<C-f>:resize 10<cr>", "open old commands" },
      R = "empty registers",
    },
    b = { name = "+Bufferline" },
    F = {
      name = "+Fold",
      l = "under curosr",
      r = "recursive cursor",
      o = "open all",
      O = "open top level",
      x = "close all",
      z = "refocus ",
    },
    L = {
      name = "+Rvim",
      [";"] = { ":Dashboard<cr>", "dashboard" },
      ["?"] = "search github",
      c = {
        "<cmd>lua vim.fn.execute('edit ' .. join_paths(rvim.get_user_dir(), 'config/init.lua'))<cr>",
        "open config file",
      },
      C = { ":checkhealth<cr>", "check health" },
      d = {
        "<cmd>lua vim.fn.execute('edit ' .. require('user.core.log').get_path())<cr>",
        "open rvim logfile",
      },
      g = {
        name = "git",
        c = { ':lua _G.__fterm_cmd("rvim_commit")<cr>', "commit" },
      },
      k = { ":lua require('user.utils.cheatsheet').cheatsheet()<cr>", "cheatsheet" },
      l = {
        "<cmd>lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<cr>",
        "lsp: open logfile",
      },
      M = { ":messages<cr>", "messages" },
      p = { "<cmd>exe 'edit '.stdpath('cache').'/packer.nvim.log'<cr>", "packer: open logfile" },
      s = {
        "<cmd>lua vim.fn.execute('edit ' .. join_paths(rvim.get_cache_dir(), 'prof.log'))<cr>",
        "open startuptime logs",
      },
      v = {
        ":e " .. join_paths(rvim.get_config_dir(), "init.lua<cr>"),
        "open vimrc",
      },
    },
    -- n = {
    --   name = "+New",
    -- },
    w = {
      name = "+Window",
    },
    z = {
      name = "+Utils",
      z = "refocus folds",
    },
  },
  visual_mode = {
    ["/"] = "comment",
    l = { name = "+Lsp" },
  },
  normal_mode = {
    ["]"] = {
      name = "+next",
      ["<space>"] = "add space below",
    },
    ["["] = {
      name = "+prev",
      ["<space>"] = "add space above",
    },
    ["g>"] = "show message history",
    ["gb"] = "lsp: go to buffer",
    ["ds"] = "surround: delete",
    ["z="] = "spell: correct an error",
  },
  plugin = {
    lsp = {
      name = "+Lsp",
      d = { ":Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "telescope: document diagnostics" },
      i = { ":LspInfo<cr>", "lsp: info" },
      I = { ":LspInstallInfo<cr>", "lspinstaller: info" },
      n = { ":NullLsInfo<cr>", "null-ls: info" },
      N = { ":NlspBufConfig<cr>", "nlsp: buffer config" },
      p = { name = "+Peek" },
      a = { ":Telescope lsp_code_actions<cr>", "telescope: code action" },
      A = { ":Telescope lsp_range_code_actions<cr>", "telescope: range code action" },
      R = { ":Telescope lsp_references<cr>", "telescope: references" },
      s = { ":Telescope lsp_document_symbols<cr>", "telescope: document symbols" },
      S = { ":Telescope lsp_dynamic_workspace_symbols<cr>", "telescope: workspace symbols" },
      w = { ":Telescope diagnostics theme=get_ivy<cr>", "telescope: workspace diagnostics" },
    },
    dap_ui = {
      toggle = {
        ':lua require"dapui".toggle()',
        "toggle ui",
      },
      inspect = {
        ':lua require"dap.ui.variables".hover()',
        "inspect",
      },
    },
    packer = {
      name = "+Plug",
      c = { ":PlugCompile<cr>", "compile" },
      C = { ":PlugClean<cr>", "clean" },
      d = { ":PlugCompiledDelete<cr>", "delete packer_compiled" },
      u = { ":PlugUpdate<cr>", "update" },
      e = { ":PlugCompiledEdit<cr>", "edit packer_compiled" },
      i = { ":PlugInstall<cr>", "install" },
      I = { ":PlugInvalidate<cr>", "invalidate" },
      s = { ":PlugSync<cr>", "sync" },
      S = { ":PlugStatus<cr>", "Status" },
    },
    git = {
      name = "+Git",
      b = { ":Telescope git_branches<cr>", "branch" },
      c = { ":Telescope git_commits<cr>", "commits" },
      C = {
        ":Telescope git_bcommits<cr>",
        "buffer commits",
      },
      d = {
        "<cmd>Gitsigns diffthis HEAD<cr>",
        "view diff",
      },
      f = { ":Telescope git_files<cr>", "files" },
      s = { ":Telescope git_status<cr>", "status" },
      o = { ":Telescope git_status<cr>", "open changed file" },
    },
  },
}
