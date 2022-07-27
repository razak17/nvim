rvim.ftplugin_conf('which-key', function(which_key)
  which_key.register({
    ['<localleader>r'] = {
      name = 'Rust',
      h = { '<cmd>RustToggleInlayHints<Cr>', 'Toggle Hints' },
      r = { '<cmd>RustRunnables<Cr>', 'Runnables' },
      t = { '<cmd>lua _CARGO_TEST()<cr>', 'Cargo Test' },
      m = { '<cmd>RustExpandMacro<Cr>', 'Expand Macro' },
      c = { '<cmd>RustOpenCargo<Cr>', 'Open Cargo' },
      p = { '<cmd>RustParentModule<Cr>', 'Parent Module' },
      d = { '<cmd>RustDebuggables<Cr>', 'Debuggables' },
      v = { '<cmd>RustViewCrateGraph<Cr>', 'View Crate Graph' },
      R = {
        "<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<Cr>",
        'Reload Workspace',
      },
      o = { '<cmd>RustOpenExternalDocs<Cr>', 'Open External Docs' },
    },
  })
end)
